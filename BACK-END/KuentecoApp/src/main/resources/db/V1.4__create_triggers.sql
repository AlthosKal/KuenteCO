-- ==================================================
-- TRIGGERS CORREGIDOS PARA KUENTECO BACKEND
-- ==================================================

-- 1. TRIGGER PARA ACTUALIZAR PRESUPUESTO RESTANTE
-- Corregido: Usa amount directamente en lugar de description->>'type'
CREATE OR REPLACE FUNCTION update_remaining_budget_on_transaction()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
DECLARE
v_budget_id INTEGER;
    v_amount NUMERIC := 0;
    v_transaction_type TEXT;
BEGIN
    -- Obtener información de la transacción
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        v_budget_id := NEW.id_budget;
        v_amount := NEW.amount;
        v_transaction_type := NEW.description->>'type';
END IF;

    IF TG_OP = 'DELETE' THEN
        v_budget_id := OLD.id_budget;
        v_amount := OLD.amount;
        v_transaction_type := OLD.description->>'type';
END IF;

    -- Solo procesar si hay un presupuesto asociado
    IF v_budget_id IS NOT NULL THEN
        -- Para INSERT/UPDATE: aplicar la transacción
        IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
            IF v_transaction_type = 'EXPENSE' THEN
                -- Restar del presupuesto restante
UPDATE budget
SET remaining_budget = remaining_budget - v_amount
WHERE id = v_budget_id;
ELSIF v_transaction_type = 'INCOME' THEN
                -- Sumar al presupuesto restante
UPDATE budget
SET remaining_budget = remaining_budget + v_amount
WHERE id = v_budget_id;
END IF;
END IF;

        -- Para DELETE: revertir la operación
        IF TG_OP = 'DELETE' THEN
            IF v_transaction_type = 'EXPENSE' THEN
                -- Devolver al presupuesto restante
UPDATE budget
SET remaining_budget = remaining_budget + v_amount
WHERE id = v_budget_id;
ELSIF v_transaction_type = 'INCOME' THEN
                -- Quitar del presupuesto restante
UPDATE budget
SET remaining_budget = remaining_budget - v_amount
WHERE id = v_budget_id;
END IF;
END IF;

        -- Para UPDATE: si cambió el presupuesto, revertir en el anterior
        IF TG_OP = 'UPDATE' AND OLD.id_budget IS NOT NULL AND OLD.id_budget != NEW.id_budget THEN
            v_transaction_type := OLD.description->>'type';
            IF v_transaction_type = 'EXPENSE' THEN
UPDATE budget
SET remaining_budget = remaining_budget + OLD.amount
WHERE id = OLD.id_budget;
ELSIF v_transaction_type = 'INCOME' THEN
UPDATE budget
SET remaining_budget = remaining_budget - OLD.amount
WHERE id = OLD.id_budget;
END IF;
END IF;
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

-- ==================================================
-- 2. TRIGGER PARA VERIFICAR LÍMITE DE PRESUPUESTO
-- Corregido: Cambiado assigned_budget por total_budget y fixed relaciones
CREATE OR REPLACE FUNCTION check_budget_limit()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
DECLARE
v_category_budget NUMERIC;    -- Presupuesto asignado a la categoría
    v_total_spent NUMERIC;        -- Total gastado en la categoría
    v_category_name TEXT;         -- Nombre de la categoría
    v_owner_user_id TEXT;         -- ID del propietario usuario (UUID)
    v_budget_id INTEGER;          -- ID del presupuesto
BEGIN
    -- Solo procesar gastos
    IF (NEW.description->>'type')::text != 'EXPENSE' THEN
        RETURN NEW;
END IF;

    -- Verificar que existe una categoría
    IF NEW.id_category IS NULL THEN
        RETURN NEW;
END IF;

    -- Obtener información de la categoría y su presupuesto asociado
SELECT c.description->>'name',
    c.id_user,
    c.id_budget,
    b.total_budget
INTO v_category_name,
    v_owner_user_id,
    v_budget_id,
    v_category_budget
FROM category c
    LEFT JOIN budget b ON c.id_budget = b.id
WHERE c.id = NEW.id_category;

-- Si no hay presupuesto asignado o asociado, no hacer nada
IF v_category_budget IS NULL OR v_category_budget = 0 OR v_budget_id IS NULL THEN
        RETURN NEW;
END IF;

    -- Calcular el total gastado en la categoría (solo gastos)
SELECT COALESCE(SUM(t.amount), 0) INTO v_total_spent
FROM transaction t
WHERE t.id_category = NEW.id_category
  AND (t.description->>'type')::text = 'EXPENSE';

-- Verificar si se ha excedido el presupuesto
IF v_total_spent > v_category_budget THEN
        -- Insertar una notificación
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification') THEN
            INSERT INTO notification (id_user, id_profile, date_send, content)
            VALUES (
                v_owner_user_id,
                NULL,
                NOW(),
                jsonb_build_object(
                    'title', 'Presupuesto Excedido',
                    'body', 'Has excedido el presupuesto asignado para la categoría ' ||
                           COALESCE(v_category_name, 'Sin nombre') ||
                           '. Gastado: $' || v_total_spent ||
                           ', Presupuesto: $' || v_category_budget,
                    'date', NOW()::text
                )
            );
END IF;
    -- Verificar si está cerca del límite (90%)
    ELSIF v_total_spent > (v_category_budget * 0.9) THEN
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification') THEN
            INSERT INTO notification (id_user, id_profile, date_send, content)
            VALUES (
                v_owner_user_id,
                NULL,
                NOW(),
                jsonb_build_object(
                    'title', 'Presupuesto Casi Agotado',
                    'body', 'Has usado el 90% del presupuesto para la categoría ' ||
                           COALESCE(v_category_name, 'Sin nombre') ||
                           '. Gastado: $' || v_total_spent ||
                           ', Presupuesto: $' || v_category_budget,
                    'date', NOW()::text
                )
            );
END IF;
END IF;

RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_check_budget_limit ON transaction;
CREATE TRIGGER trg_check_budget_limit
    AFTER INSERT OR UPDATE ON transaction
                        FOR EACH ROW
                        EXECUTE FUNCTION check_budget_limit();

-- ==================================================
-- 3. TRIGGER PARA RECORDATORIOS DE DEUDA
-- Corregido: Eliminadas referencias a profile que no existen en la entidad Debt
CREATE OR REPLACE FUNCTION send_debt_reminder()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    -- Verificar si la deuda está próxima a vencer (en 3 días) y está activa
    IF NEW.expiration_date <= NOW() + INTERVAL '3 days'
        AND NEW.expiration_date > NOW()
        AND NEW.state = 'ACTIVE' THEN

        -- Insertar notificación solo para usuario (Debt solo tiene id_user)
        IF NEW.id_user IS NOT NULL THEN
            IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification') THEN
                INSERT INTO notification (id_user, id_profile, date_send, content)
                VALUES (
                    NEW.id_user,
                    NULL,
                    NOW(),
                    jsonb_build_object(
                        'title', 'Recordatorio de Deuda',
                        'body', 'Tu deuda "' || NEW.name || '" vence el ' ||
                               TO_CHAR(NEW.expiration_date, 'DD/MM/YYYY') ||
                               '. Monto pendiente: $' || NEW.pending_amount ||
                               '. Por favor, realiza el pago.',
                        'date', NOW()::text
                    )
                );
END IF;
END IF;
END IF;

    -- Verificar si la deuda ya venció
    IF NEW.expiration_date < NOW() AND NEW.state = 'ACTIVE' THEN
        -- Actualizar estado a vencida
UPDATE debt SET state = 'DEFEATED' WHERE id = NEW.id;

-- Insertar notificación de deuda vencida
IF NEW.id_user IS NOT NULL THEN
            IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification') THEN
                INSERT INTO notification (id_user, id_profile, date_send, content)
                VALUES (
                    NEW.id_user,
                    NULL,
                    NOW(),
                    jsonb_build_object(
                        'title', 'Deuda Vencida',
                        'body', 'Tu deuda "' || NEW.name || '" ha vencido. ' ||
                               'Monto pendiente: $' || NEW.pending_amount,
                        'date', NOW()::text
                    )
                );
END IF;
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

-- ==================================================
-- 4. TRIGGER PARA AUDITORÍA DE USUARIOS
-- Corregido: Manejo mejorado de UUID y logs de auditoría
CREATE OR REPLACE FUNCTION log_audit_user_changes()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
DECLARE
v_log_message TEXT;
    v_user_id TEXT; -- UUID como TEXT
    v_record_id INTEGER;
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
        IF TG_OP = 'UPDATE' THEN
            v_log_message := 'UPDATE on kuentecouser: ID=' || NEW.id ||
                           ', Email=' || COALESCE(NEW.email, 'NULL') ||
                           ', Username=' || COALESCE(NEW.username, 'NULL') ||
                           ', State=' || COALESCE(NEW.account_state::text, 'NULL') ||
                           ', Type=' || COALESCE(NEW.type::text, 'NULL');

            -- Agregar información de cambios específicos
            IF OLD.email != NEW.email THEN
                v_log_message := v_log_message || ', Email changed from ' ||
                               COALESCE(OLD.email, 'NULL') || ' to ' || COALESCE(NEW.email, 'NULL');
END IF;

            IF OLD.account_state != NEW.account_state THEN
                v_log_message := v_log_message || ', State changed from ' ||
                               COALESCE(OLD.account_state::text, 'NULL') || ' to ' ||
                               COALESCE(NEW.account_state::text, 'NULL');
END IF;
ELSE
            v_log_message := 'INSERT on kuentecouser: ID=' || NEW.id ||
                           ', Email=' || COALESCE(NEW.email, 'NULL') ||
                           ', Username=' || COALESCE(NEW.username, 'NULL') ||
                           ', State=' || COALESCE(NEW.account_state::text, 'NULL') ||
                           ', Type=' || COALESCE(NEW.type::text, 'NULL');
END IF;
END IF;

    -- Generar un ID entero basado en el hash del UUID
    v_record_id := abs(hashtext(v_user_id));

    -- Registrar el cambio en la tabla de auditoría
INSERT INTO audit_logs (table_name, operation, record_id, log_message, log_timestamp)
VALUES (
           'kuentecouser',
           TG_OP,
           v_record_id,
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
        RAISE WARNING 'Error en trigger de auditoría para usuario %: %', v_user_id, SQLERRM;

        -- Intentar registrar el error en los logs
BEGIN
INSERT INTO audit_logs (table_name, operation, record_id, log_message, log_timestamp)
VALUES (
           'kuentecouser',
           'ERROR',
           COALESCE(v_record_id, 0),
           'Error en trigger de auditoría: ' || SQLERRM,
           NOW()
       );
EXCEPTION
            WHEN OTHERS THEN
                -- Si incluso esto falla, solo registrar el warning
                RAISE WARNING 'Error crítico en trigger de auditoría: %', SQLERRM;
END;

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

-- ==================================================
-- 5. TRIGGER PARA ACTUALIZAR PRESUPUESTO RESTANTE AL CAMBIAR CATEGORÍA
-- ==================================================
CREATE OR REPLACE FUNCTION update_remaining_budget_on_category()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
DECLARE
    v_old_budget_id INTEGER;
    v_new_budget_id INTEGER;
    v_category_expenses NUMERIC := 0;
BEGIN
    -- Obtener IDs de presupuesto anterior y nuevo
    IF TG_OP = 'DELETE' THEN
        v_old_budget_id := OLD.id_budget;
        v_new_budget_id := NULL;
    ELSIF TG_OP = 'INSERT' THEN
        v_old_budget_id := NULL;
        v_new_budget_id := NEW.id_budget;
    ELSE -- UPDATE
        v_old_budget_id := OLD.id_budget;
        v_new_budget_id := NEW.id_budget;
    END IF;

    -- Solo proceder si hay cambio en el presupuesto asociado
    IF v_old_budget_id = v_new_budget_id THEN
        IF TG_OP = 'DELETE' THEN
            RETURN OLD;
        END IF;
        RETURN NEW;
    END IF;

    -- Calcular gastos totales de la categoría
    IF TG_OP = 'DELETE' THEN
        -- Para DELETE, calcular gastos de la categoría eliminada
        SELECT COALESCE(SUM(t.amount), 0) INTO v_category_expenses
        FROM transaction t
        WHERE t.id_category = OLD.id
          AND (t.description->>'type')::text = 'EXPENSE';
    ELSE
        -- Para INSERT/UPDATE, calcular gastos de la categoría
        SELECT COALESCE(SUM(t.amount), 0) INTO v_category_expenses
        FROM transaction t
        WHERE t.id_category = NEW.id
          AND (t.description->>'type')::text = 'EXPENSE';
    END IF;

    -- Actualizar presupuesto anterior (devolver gastos)
    IF v_old_budget_id IS NOT NULL AND v_category_expenses > 0 THEN
        UPDATE budget
        SET remaining_budget = remaining_budget + v_category_expenses
        WHERE id = v_old_budget_id;
    END IF;

    -- Actualizar presupuesto nuevo (descontar gastos)
    IF v_new_budget_id IS NOT NULL AND v_category_expenses > 0 THEN
        UPDATE budget
        SET remaining_budget = remaining_budget - v_category_expenses
        WHERE id = v_new_budget_id;
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_update_remaining_budget_on_category ON category;
CREATE TRIGGER trg_update_remaining_budget_on_category
    AFTER INSERT OR UPDATE OR DELETE ON category
    FOR EACH ROW
    EXECUTE FUNCTION update_remaining_budget_on_category();

-- ==================================================
-- FUNCIONES AUXILIARES PARA VERIFICAR INTEGRIDAD
-- ==================================================

-- Función para verificar la integridad de presupuestos
CREATE OR REPLACE FUNCTION verify_budget_integrity()
    RETURNS TABLE(budget_id INTEGER, calculated_remaining NUMERIC, stored_remaining NUMERIC, difference NUMERIC) AS
$$
BEGIN
RETURN QUERY
SELECT
    b.id as budget_id,
    (b.total_budget - COALESCE(expense_sum.total_expenses, 0) + COALESCE(income_sum.total_income, 0)) as calculated_remaining,
    b.remaining_budget as stored_remaining,
    (b.remaining_budget - (b.total_budget - COALESCE(expense_sum.total_expenses, 0) + COALESCE(income_sum.total_income, 0))) as difference
FROM budget b
         LEFT JOIN (
    SELECT
        id_budget,
        SUM(amount) as total_expenses
    FROM transaction
    WHERE description->>'type' = 'EXPENSE'
      AND id_budget IS NOT NULL
    GROUP BY id_budget
) expense_sum ON b.id = expense_sum.id_budget
         LEFT JOIN (
    SELECT
        id_budget,
        SUM(amount) as total_income
    FROM transaction
    WHERE description->>'type' = 'INCOME'
      AND id_budget IS NOT NULL
    GROUP BY id_budget
) income_sum ON b.id = income_sum.id_budget
WHERE ABS(b.remaining_budget - (b.total_budget - COALESCE(expense_sum.total_expenses, 0) + COALESCE(income_sum.total_income, 0))) > 0.01;
END;
$$ LANGUAGE plpgsql;