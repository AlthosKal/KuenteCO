-- Esta vista agrupa las transacciones por categoría
-- Tablas Relacionadas: Transaction - Category
CREATE OR REPLACE VIEW vw_transactions_by_category AS
SELECT
    c.id AS category_id,
    COALESCE(c.description->>'name', 'Sin nombre') AS category_name,
    SUM(CASE WHEN t.description->>'type' = 'INCOME' THEN t.amount ELSE 0 END) AS total_income,
    SUM(CASE WHEN t.description->>'type' = 'EXPENSE' THEN t.amount ELSE 0 END) AS total_expenses,
    SUM(CASE WHEN t.description->>'type' = 'INCOME' THEN t.amount
             WHEN t.description->>'type' = 'EXPENSE' THEN -t.amount
             ELSE 0 END) AS net_amount,
    COUNT(t.id) AS transaction_count,
    COUNT(CASE WHEN t.description->>'type' = 'INCOME' THEN 1 END) AS income_count,
    COUNT(CASE WHEN t.description->>'type' = 'EXPENSE' THEN 1 END) AS expense_count
FROM
    category c
        LEFT JOIN transaction t ON c.id = t.id_category
GROUP BY
    c.id, c.description->>'name'
ORDER BY
    total_expenses DESC;

-- Esta vista compara el presupuesto asignado con los gastos reales
-- Tablas Relacionadas: Budget - Transaction
CREATE OR REPLACE VIEW vw_budget_vs_actual AS
SELECT
    c.id AS category_id,
    COALESCE(c.description->>'name', 'Sin nombre') AS category_name,
    c.assigned_budget AS assigned_amount,
    COALESCE(SUM(CASE WHEN t.description->>'type' = 'EXPENSE' THEN t.amount ELSE 0 END), 0) AS actual_spent,
    (c.assigned_budget - COALESCE(SUM(CASE WHEN t.description->>'type' = 'EXPENSE' THEN t.amount ELSE 0 END), 0)) AS remaining_amount,
    CASE
        WHEN c.assigned_budget > 0 THEN
            ROUND((COALESCE(SUM(CASE WHEN t.description->>'type' = 'EXPENSE' THEN t.amount ELSE 0 END), 0) / c.assigned_budget * 100), 2)
        ELSE 0
        END AS percentage_used,
    CASE
        WHEN c.assigned_budget IS NULL OR c.assigned_budget = 0 THEN 'SIN_PRESUPUESTO'
        WHEN COALESCE(SUM(CASE WHEN t.description->>'type' = 'EXPENSE' THEN t.amount ELSE 0 END), 0) > c.assigned_budget THEN 'EXCEDIDO'
        WHEN COALESCE(SUM(CASE WHEN t.description->>'type' = 'EXPENSE' THEN t.amount ELSE 0 END), 0) > (c.assigned_budget * 0.9) THEN 'CERCA_LIMITE'
        ELSE 'NORMAL'
        END AS budget_status
FROM
    category c
        LEFT JOIN transaction t ON c.id = t.id_category
WHERE
    c.assigned_budget IS NOT NULL AND c.assigned_budget > 0
GROUP BY
    c.id, c.description->>'name', c.assigned_budget
ORDER BY
    percentage_used DESC;

-- Vista adicional: Resumen de deudas por usuario/perfil
CREATE OR REPLACE VIEW vw_debt_summary AS
SELECT
    CASE
        WHEN d.id_user IS NOT NULL THEN d.id_user::TEXT
        WHEN d.id_profile IS NOT NULL THEN d.id_profile::TEXT
        ELSE 'UNKNOWN'
        END AS owner_id,
    CASE WHEN d.id_user IS NOT NULL THEN 'USER' ELSE 'PROFILE' END AS owner_type,
    COUNT(*) AS total_debts,
    COUNT(CASE WHEN d.state = 'ACTIVE' THEN 1 END) AS active_debts,
    COUNT(CASE WHEN d.state = 'PAID' THEN 1 END) AS paid_debts,
    COUNT(CASE WHEN d.state = 'DEFEATED' THEN 1 END) AS overdue_debts,
    SUM(d.total_amount) AS total_debt_amount,
    SUM(d.pending_amount) AS total_pending_amount,
    SUM(CASE WHEN d.state = 'ACTIVE' THEN d.pending_amount ELSE 0 END) AS active_pending_amount,
    MIN(CASE WHEN d.state = 'ACTIVE' THEN d.expiration_date END) AS next_due_date
FROM
    debt d
GROUP BY
    CASE
        WHEN d.id_user IS NOT NULL THEN d.id_user::TEXT
        WHEN d.id_profile IS NOT NULL THEN d.id_profile::TEXT
        ELSE 'UNKNOWN'
        END,
    CASE WHEN d.id_user IS NOT NULL THEN 'USER' ELSE 'PROFILE' END
ORDER BY
    active_pending_amount DESC;

-- Vista adicional: Notificaciones recientes
CREATE OR REPLACE VIEW vw_recent_notifications AS
SELECT
    n.id,
    CASE
        WHEN n.id_user IS NOT NULL THEN n.id_user::TEXT
        WHEN n.id_profile IS NOT NULL THEN n.id_profile::TEXT
        ELSE 'UNKNOWN'
        END AS owner_id,
    CASE WHEN n.id_user IS NOT NULL THEN 'USER' ELSE 'PROFILE' END AS owner_type,
    COALESCE(n.content->>'title', 'Sin título') AS title,
    COALESCE(n.content->>'body', 'Sin contenido') AS body,
    n.date_send,
    CASE
        WHEN n.date_send > NOW() - INTERVAL '1 day' THEN 'HOY'
    WHEN n.date_send > NOW() - INTERVAL '7 days' THEN 'ESTA_SEMANA'
    WHEN n.date_send > NOW() - INTERVAL '30 days' THEN 'ESTE_MES'
    ELSE 'ANTERIOR'
END AS time_category
FROM
    notification n
ORDER BY
    n.date_send DESC;