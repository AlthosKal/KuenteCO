--Para actualizar automáticamente el saldo de la cuenta cuando se inserta, actualiza o elimina una transacción.
--Tabla Relacionada: Transaction
CREATE OR REPLACE FUNCTION update_remaining_budget_on_transaction()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
DECLARE
    v_budget_id INTEGER;
    v_expense_amount NUMERIC := 0;
    v_income_amount NUMERIC := 0;
BEGIN
    -- Obtener el ID del presupuesto desde la transacción
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        v_budget_id := NEW.id_budget;
        IF (NEW.description->>'type')::text = 'EXPENSE' THEN
            v_expense_amount := NEW.amount;
        ELSIF (NEW.description->>'type')::text = 'INCOME' THEN
            v_income_amount := NEW.amount;
        END IF;
    END IF;

    IF TG_OP = 'DELETE' THEN
        v_budget_id := OLD.id_budget;
        -- Revertir la operación anterior
        IF (OLD.description->>'type')::text = 'EXPENSE' THEN
            v_expense_amount := -OLD.amount; -- Devolver al presupuesto
        ELSIF (OLD.description->>'type')::text = 'INCOME' THEN
            v_income_amount := -OLD.amount; -- Quitar del presupuesto
        END IF;
    END IF;

    -- Solo procesar si hay un presupuesto asociado
    IF v_budget_id IS NOT NULL THEN
        -- Actualizar el presupuesto restante
        UPDATE budget
        SET remaining_budget = remaining_budget + v_income_amount - v_expense_amount
        WHERE id = v_budget_id;
    END IF;

    -- Si es UPDATE, también procesar el valor anterior
    IF TG_OP = 'UPDATE' AND OLD.id_budget IS NOT NULL AND OLD.id_budget != NEW.id_budget THEN
        -- Revertir el efecto en el presupuesto anterior
        UPDATE budget
        SET remaining_budget = remaining_budget +
                               CASE
                                   WHEN (OLD.description->>'type')::text = 'EXPENSE' THEN OLD.amount
                                   WHEN (OLD.description->>'type')::text = 'INCOME' THEN -OLD.amount
                                   ELSE 0
                                   END
        WHERE id = OLD.id_budget;
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_update_remaining_budget_on_transaction ON transaction;
CREATE TRIGGER trg_update_remaining_budget_on_transaction
    AFTER INSERT OR UPDATE OR DELETE ON transaction
    FOR EACH ROW
EXECUTE FUNCTION update_remaining_budget_on_transaction();

--Este trigger debe estar en la base de datos para enviar notificaciones cuando se esté cerca o se haya excedido el presupuesto.
-- Esto es más eficiente que hacerlo en el backend, ya que la base de datos puede evaluar el estado del presupuesto en tiempo real.
--Tabla Relacionada: Budget

CREATE OR REPLACE FUNCTION check_budget_limit()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
DECLARE
    v_assigned_amount NUMERIC; -- Monto asignado al presupuesto en la categoría
    v_total_spent NUMERIC;     -- Total gastado en la categoría
    v_category_name TEXT;      -- Nombre de la categoría
    v_owner_user_id TEXT;      -- ID del propietario usuario (UUID)
    v_owner_profile_id INTEGER; -- ID del propietario perfil
    v_is_profile BOOLEAN;      -- Indica si es perfil o usuario
BEGIN
    -- Solo procesar gastos
    IF (NEW.description->>'type')::text != 'EXPENSE' THEN
        RETURN NEW;
    END IF;

    -- Verificar que existe una categoría
    IF NEW.id_category IS NULL THEN
        RETURN NEW;
    END IF;

    -- Obtener información de la categoría
    SELECT c.assigned_budget,
           c.description->>'name',
           c.id_user,
           c.id_profile
    INTO v_assigned_amount,
        v_category_name,
        v_owner_user_id,
        v_owner_profile_id
    FROM category c
    WHERE c.id = NEW.id_category;

    -- Si no hay presupuesto asignado, no hacer nada
    IF v_assigned_amount IS NULL OR v_assigned_amount = 0 THEN
        RETURN NEW;
    END IF;

    -- Determinar si es perfil o usuario
    v_is_profile := (v_owner_profile_id IS NOT NULL);

    -- Calcular el total gastado en la categoría (solo gastos)
    SELECT COALESCE(SUM(t.amount), 0) INTO v_total_spent
    FROM transaction t
    WHERE t.id_category = NEW.id_category
      AND (t.description->>'type')::text = 'EXPENSE';

    -- Verificar si se ha excedido el presupuesto
    IF v_total_spent > v_assigned_amount THEN
        -- Insertar una notificación
        INSERT INTO notification (id_user, id_profile, date_send, content)
        VALUES (
                   CASE WHEN v_is_profile THEN NULL ELSE v_owner_user_id END,
                   CASE WHEN v_is_profile THEN v_owner_profile_id ELSE NULL END,
                   NOW(),
                   jsonb_build_object(
                           'title', 'Presupuesto Excedido',
                           'body', 'Has excedido el presupuesto asignado para la categoría ' || COALESCE(v_category_name, 'Sin nombre') ||
                                   '. Gastado: $' || v_total_spent || ', Presupuesto: $' || v_assigned_amount,
                           'date', NOW()::text
                   )
               );
        -- Verificar si está cerca del límite (90%)
    ELSIF v_total_spent > (v_assigned_amount * 0.9) THEN
        INSERT INTO notification (id_user, id_profile, date_send, content)
        VALUES (
                   CASE WHEN v_is_profile THEN NULL ELSE v_owner_user_id END,
                   CASE WHEN v_is_profile THEN v_owner_profile_id ELSE NULL END,
                   NOW(),
                   jsonb_build_object(
                           'title', 'Presupuesto Casi Agotado',
                           'body', 'Has usado el 90% del presupuesto para la categoría ' || COALESCE(v_category_name, 'Sin nombre') ||
                                   '. Gastado: $' || v_total_spent || ', Presupuesto: $' || v_assigned_amount,
                           'date', NOW()::text
                   )
               );
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_check_budget_limit ON transaction;
CREATE TRIGGER trg_check_budget_limit
    AFTER INSERT OR UPDATE ON transaction
    FOR EACH ROW
EXECUTE FUNCTION check_budget_limit();

--Este trigger debe estar en la base de datos para enviar recordatorios de pago de deudas.
--La base de datos puede evaluar fechas de vencimiento y estados de deudas de manera más eficiente.
--Tabla Relacionada: Debt

CREATE OR REPLACE FUNCTION send_debt_reminder()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    -- Verificar si la deuda está próxima a vencer (en 3 días) y está activa
    IF NEW.expiration_date <= NOW() + INTERVAL '3 days'
        AND NEW.expiration_date > NOW()
        AND NEW.state = 'ACTIVE' THEN

        -- Insertar notificación para usuario
        IF NEW.id_user IS NOT NULL THEN
            INSERT INTO notification (id_user, date_send, content)
            VALUES (
                       NEW.id_user,
                       NOW(),
                       jsonb_build_object(
                               'title', 'Recordatorio de Deuda',
                               'body', 'Tu deuda "' || NEW.name || '" vence el ' ||
                                       TO_CHAR(NEW.expiration_date, 'DD/MM/YYYY') ||
                                       '. Monto pendiente: $' || NEW.pending_amount || '. Por favor, realiza el pago.',
                               'date', NOW()::text
                       )
                   );
        END IF;

        -- Insertar notificación para perfil
        IF NEW.id_profile IS NOT NULL THEN
            INSERT INTO notification (id_profile, date_send, content)
            VALUES (
                       NEW.id_profile,
                       NOW(),
                       jsonb_build_object(
                               'title', 'Recordatorio de Deuda',
                               'body', 'Tu deuda "' || NEW.name || '" vence el ' ||
                                       TO_CHAR(NEW.expiration_date, 'DD/MM/YYYY') ||
                                       '. Monto pendiente: $' || NEW.pending_amount || '. Por favor, realiza el pago.',
                               'date', NOW()::text
                       )
                   );
        END IF;
    END IF;

    -- Verificar si la deuda ya venció
    IF NEW.expiration_date < NOW() AND NEW.state = 'ACTIVE' THEN
        -- Actualizar estado a vencida
        UPDATE debt SET state = 'DEFEATED' WHERE id = NEW.id;

        -- Insertar notificación de deuda vencida
        IF NEW.id_user IS NOT NULL THEN
            INSERT INTO notification (id_user, date_send, content)
            VALUES (
                       NEW.id_user,
                       NOW(),
                       jsonb_build_object(
                               'title', 'Deuda Vencida',
                               'body', 'Tu deuda "' || NEW.name || '" ha vencido. Monto pendiente: $' || NEW.pending_amount,
                               'date', NOW()::text
                       )
                   );
        END IF;

        IF NEW.id_profile IS NOT NULL THEN
            INSERT INTO notification (id_profile, date_send, content)
            VALUES (
                       NEW.id_profile,
                       NOW(),
                       jsonb_build_object(
                               'title', 'Deuda Vencida',
                               'body', 'Tu deuda "' || NEW.name || '" ha vencido. Monto pendiente: $' || NEW.pending_amount,
                               'date', NOW()::text
                       )
                   );
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_send_debt_reminder ON debt;
CREATE TRIGGER trg_send_debt_reminder
    AFTER INSERT OR UPDATE ON debt
    FOR EACH ROW
EXECUTE FUNCTION send_debt_reminder();

--Este trigger debe estar en la base de datos para registrar los intentos de acceso y cambios en los roles de los usuarios.
--Esto es crítico para la seguridad y el cumplimiento de auditorías.
--Tabla Relacionada: kuentecouser

CREATE OR REPLACE FUNCTION log_audit_user_changes()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
DECLARE
    v_log_message TEXT;
    v_user_id TEXT; -- UUID como TEXT
BEGIN
    -- Determinar el ID del usuario y construir mensaje
    IF TG_OP = 'DELETE' THEN
        v_user_id := OLD.id;
        v_log_message := 'DELETE on kuentecouser: ID=' || OLD.id ||
                         ', Email=' || COALESCE(OLD.email, 'NULL') ||
                         ', Username=' || COALESCE(OLD.username, 'NULL') ||
                         ', Action by: SYSTEM';
    ELSE
        v_user_id := NEW.id;
        v_log_message := TG_OP || ' on kuentecouser: ID=' || NEW.id ||
                         ', Email=' || COALESCE(NEW.email, 'NULL') ||
                         ', Username=' || COALESCE(NEW.username, 'NULL') ||
                         ', State=' || COALESCE(NEW.account_state::text, 'NULL') ||
                         ', Type=' || COALESCE(NEW.type::text, 'NULL') ||
                         ', Action by: SYSTEM';
    END IF;

    -- Registrar el cambio en una tabla de auditoría
    -- Nota: record_id es INTEGER pero User.id es UUID, se almacena como hash
    INSERT INTO audit_logs (table_name, operation, record_id, log_message, log_timestamp)
    VALUES (
               'kuentecouser',
               TG_OP,
               abs(hashtext(v_user_id)), -- Convertir UUID a INTEGER hash
               v_log_message,
               NOW()
           );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- En caso de error, registrar en logs pero no fallar la transacción principal
        RAISE WARNING 'Error en trigger de auditoría: %', SQLERRM;
        IF TG_OP = 'DELETE' THEN
            RETURN OLD;
        END IF;
        RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_log_audit_user_changes ON kuentecouser;
CREATE TRIGGER trg_log_audit_user_changes
    AFTER INSERT OR UPDATE OR DELETE ON kuentecouser
    FOR EACH ROW
EXECUTE FUNCTION log_audit_user_changes();