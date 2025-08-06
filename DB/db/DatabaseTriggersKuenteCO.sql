--Para actualizar automáticamente el saldo de la cuenta cuando se inserta, actualiza o elimina una transacción.
--Tabla Relacionada: Transaction
CREATE OR REPLACE FUNCTION update_balance_on_transaction()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
BEGIN
    -- Si es una inserción
    IF TG_OP = 'INSERT' THEN
        UPDATE Account
        SET balance = balance + NEW.amount
        WHERE id = NEW.idAccount;
    END IF;

    -- Si es una actualización
    IF TG_OP = 'UPDATE' THEN
        -- Revertir el saldo anterior
        UPDATE Account
        SET balance = balance - OLD.amount
        WHERE id = OLD.idAccount;

        -- Aplicar el nuevo saldo
        UPDATE Account
        SET balance = balance + NEW.amount
        WHERE id = NEW.idAccount;
    END IF;

    -- Si es una eliminación
    IF TG_OP = 'DELETE' THEN
        UPDATE Account
        SET balance = balance - OLD.amount
        WHERE id = OLD.idAccount;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_update_balance_on_transaction
AFTER INSERT OR UPDATE OR DELETE ON Transaction
FOR EACH ROW
EXECUTE FUNCTION update_balance_on_transaction();

--Este trigger debe estar en la base de datos para enviar notificaciones cuando se esté cerca o se haya excedido el presupuesto.
-- Esto es más eficiente que hacerlo en el backend, ya que la base de datos puede evaluar el estado del presupuesto en tiempo real.
--Tabla Relacionada: Budget

CREATE OR REPLACE FUNCTION check_budget_limit()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
DECLARE
    v_assigned_amount NUMERIC; -- Monto asignado al presupuesto
    v_total_spent NUMERIC;     -- Total gastado en la categoría
BEGIN
    -- Obtener el monto asignado al presupuesto
    SELECT assigned_amount INTO v_assigned_amount
    FROM Budget
    WHERE id_category = NEW.idCategory;

    -- Calcular el total gastado en la categoría
    SELECT COALESCE(SUM(amount), 0) INTO v_total_spent
    FROM Transaction
    WHERE id_category = NEW.idCategory;

    -- Verificar si se ha excedido el presupuesto
    IF v_total_spent > v_assigned_amount THEN
        -- Insertar una notificación
        INSERT INTO Notification (id_account, date_send, content)
        VALUES (
            NEW.idAccount,
            NOW(),
            jsonb_build_object(
                'message', 'Has excedido el presupuesto asignado para la categoría ' || (SELECT name FROM Category WHERE id = NEW.idCategory),
                'type', 'budget_exceeded'
            )
        );
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_budget_limit
AFTER INSERT OR UPDATE ON Transaction
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
    -- Verificar si la deuda está próxima a vencer (por ejemplo, en 3 días)
    IF NEW.expirationDate <= NOW() + INTERVAL '3 days' THEN
        -- Insertar una notificación
        INSERT INTO Notification (id_account, date_send, content)
        VALUES (
            NEW.idAccount,
            NOW(),
            jsonb_build_object(
                'message', 'Tu deuda "' || NEW.name || '" vence el ' || NEW.expirationDate || '. Por favor, realiza el pago.',
                'type', 'debt_reminder'
            )
        );
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_send_debt_reminder
AFTER INSERT OR UPDATE ON Debt
FOR EACH ROW
EXECUTE FUNCTION send_debt_reminder();

--Este trigger debe estar en la base de datos para registrar los intentos de acceso y cambios en los roles de los usuarios.
--Esto es crítico para la seguridad y el cumplimiento de auditorías.
--Tabla Relacionada: KuenteCOUser

CREATE OR REPLACE FUNCTION log_audit_user_changes()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
BEGIN
    -- Registrar el cambio en una tabla de auditoría
    INSERT INTO exchange_rate_logs (log_message, log_timestamp)
    VALUES (
        TG_OP || ' on KuenteCOUser: ' || NEW.id,
        NOW()
    );

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_log_audit_user_changes
AFTER INSERT OR UPDATE OR DELETE ON KuenteCOUser
FOR EACH ROW
EXECUTE FUNCTION log_audit_user_changes();