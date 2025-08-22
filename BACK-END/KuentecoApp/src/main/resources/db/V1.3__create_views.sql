-- Esta vista agrupa las transacciones por categoría con información del usuario propietario
-- Tablas Relacionadas: Transaction - Category - KuentecoUser - Profile
CREATE OR REPLACE VIEW vw_transactions_by_category AS
SELECT
    c.id AS category_id,
    COALESCE(c.name, 'Sin nombre') AS category_name,
    -- Agregar el owner_user_id basado en quien es el propietario de la transacción
    CASE
        WHEN t.id_user IS NOT NULL THEN t.id_user
        WHEN t.id_profile IS NOT NULL THEN p.id_user
        ELSE c.id_user -- Fallback al propietario de la categoría
        END AS owner_user_id,
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
        LEFT JOIN profile p ON t.id_profile = p.id
WHERE t.id IS NOT NULL
GROUP BY
    c.id,
    c.name,
    c.id_user,
    CASE
    WHEN t.id_user IS NOT NULL THEN t.id_user
    WHEN t.id_profile IS NOT NULL THEN p.id_user
    ELSE c.id_user
END
ORDER BY
    total_expenses DESC;

-- Esta vista compara el presupuesto asignado con los gastos reales
-- Tablas Relacionadas: Budget - Category - Transaction - KuentecoUser - Profile
CREATE OR REPLACE VIEW vw_budget_vs_actual AS
SELECT
    b.id_user AS owner_user_id,
    c.id AS category_id,
    b.id AS budget_id,
    COALESCE(c.name, 'Sin nombre') AS category_name,
    b.name AS budget_name,
    b.total_budget AS assigned_amount,
    b.remaining_budget,
    COALESCE(SUM(CASE WHEN t.description->>'type' = 'EXPENSE' THEN t.amount ELSE 0 END), 0) AS actual_spent,
    (COALESCE(b.total_budget, 0) - COALESCE(SUM(CASE WHEN t.description->>'type' = 'EXPENSE' THEN t.amount ELSE 0 END), 0)) AS calculated_remaining,
    CASE
        WHEN b.total_budget > 0 THEN
            ROUND((COALESCE(SUM(CASE WHEN t.description->>'type' = 'EXPENSE' THEN t.amount ELSE 0 END), 0) / b.total_budget * 100), 2)
        ELSE 0
        END AS percentage_used,
    CASE
        WHEN b.total_budget IS NULL OR b.total_budget = 0 THEN 'SIN_PRESUPUESTO'
        WHEN COALESCE(SUM(CASE WHEN t.description->>'type' = 'EXPENSE' THEN t.amount ELSE 0 END), 0) > b.total_budget THEN 'EXCEDIDO'
        WHEN COALESCE(SUM(CASE WHEN t.description->>'type' = 'EXPENSE' THEN t.amount ELSE 0 END), 0) > (b.total_budget * 0.9) THEN 'CERCA_LIMITE'
        ELSE 'NORMAL'
        END AS budget_status
FROM
    category c
        INNER JOIN budget b ON c.id_budget = b.id
        LEFT JOIN transaction t ON c.id = t.id_category
        LEFT JOIN profile p ON t.id_profile = p.id
WHERE
    b.total_budget IS NOT NULL AND b.total_budget > 0 AND b.id IS NOT NULL
GROUP BY
    c.id,
    c.name,
    b.id,
    b.name,
    b.total_budget,
    b.remaining_budget,
    b.id_user
ORDER BY
    percentage_used DESC;

-- Vista de resumen de presupuestos por usuario (ya tenía user_id correctamente)
CREATE OR REPLACE VIEW vw_budget_summary_by_user AS
SELECT
    u.id AS owner_user_id, -- Agregar para consistencia con otras vistas
    u.username,
    COUNT(DISTINCT b.id) AS total_budgets,
    SUM(b.total_budget) AS total_budget_amount,
    SUM(b.remaining_budget) AS total_remaining_amount,
    SUM(b.total_budget - b.remaining_budget) AS total_spent_amount,
    CASE
        WHEN SUM(b.total_budget) > 0 THEN
            ROUND(((SUM(b.total_budget - b.remaining_budget) / SUM(b.total_budget)) * 100), 2)
        ELSE 0
        END AS overall_percentage_used
FROM
    kuentecouser u
        LEFT JOIN budget b ON u.id = b.id_user
GROUP BY
    u.id, u.username
ORDER BY
    total_budget_amount DESC;

-- Vista de resumen de deudas por usuario (ya tenía user_id correctamente)
CREATE OR REPLACE VIEW vw_debt_summary AS
SELECT
    u.id AS owner_user_id, -- Agregar para consistencia con otras vistas
    u.username,
    COUNT(*) AS total_debts,
    COUNT(CASE WHEN d.state = 'ACTIVE' THEN 1 END) AS active_debts,
    COUNT(CASE WHEN d.state = 'PAID' THEN 1 END) AS paid_debts,
    COUNT(CASE WHEN d.state = 'DEFEATED' THEN 1 END) AS overdue_debts,
    COUNT(CASE WHEN d.state = 'REFINANCED' THEN 1 END) AS refinanced_debts,
    COUNT(CASE WHEN d.state = 'IN_MORATIUM' THEN 1 END) AS in_moratium_debts,
    COUNT(CASE WHEN d.state = 'CANCELLED' THEN 1 END) AS cancelled_debts,
    SUM(d.total_amount) AS total_debt_amount,
    SUM(d.pending_amount) AS total_pending_amount,
    SUM(CASE WHEN d.state = 'ACTIVE' THEN d.pending_amount ELSE 0 END) AS active_pending_amount,
    MIN(CASE WHEN d.state = 'ACTIVE' THEN d.expiration_date END) AS next_due_date,
    COUNT(CASE WHEN d.state = 'ACTIVE' AND d.expiration_date < NOW() THEN 1 END) AS expired_active_debts
FROM
    kuentecouser u
        LEFT JOIN debt d ON u.id = d.id_user
GROUP BY
    u.id, u.username
ORDER BY
    active_pending_amount DESC;

-- Vista de transacciones por usuario/perfil con información completa
CREATE OR REPLACE VIEW vw_transactions_summary AS
SELECT
    CASE
        WHEN t.id_user IS NOT NULL THEN t.id_user
        WHEN t.id_profile IS NOT NULL THEN p.id_user
        ELSE NULL
        END AS owner_user_id,
    t.id_profile,
    t.id,
    CASE
        WHEN t.id_user IS NOT NULL THEN 'USER'
        WHEN t.id_profile IS NOT NULL THEN 'PROFILE'
        ELSE 'UNKNOWN'
        END AS transaction_owner_type,
    COALESCE(t.name, 'Sin nombre') AS transaction_name,
    COALESCE(c.name, 'Sin categoría') AS category_name,
    COALESCE(b.name, 'Sin presupuesto') AS budget_name,
    COALESCE(d.name, 'Sin deuda') AS debt_name,
    COUNT(*) AS transaction_count,
    COUNT(CASE WHEN t.description->>'type' = 'INCOME' THEN 1 END) AS income_count,
    COUNT(CASE WHEN t.description->>'type' = 'EXPENSE' THEN 1 END) AS expense_count,
    SUM(CASE WHEN t.description->>'type' = 'INCOME' THEN t.amount ELSE 0 END) AS total_income,
    SUM(CASE WHEN t.description->>'type' = 'EXPENSE' THEN t.amount ELSE 0 END) AS total_expenses,
    SUM(CASE WHEN t.description->>'type' = 'INCOME' THEN t.amount
             WHEN t.description->>'type' = 'EXPENSE' THEN -t.amount
             ELSE 0 END) AS net_amount,
    MIN(t.transaction_date) AS first_transaction_date,
    MAX(t.transaction_date) AS last_transaction_date
FROM
    transaction t
        LEFT JOIN profile p ON t.id_profile = p.id
        LEFT JOIN category c ON t.id_category = c.id
        LEFT JOIN budget b ON t.id_budget = b.id
        LEFT JOIN debt d ON t.id_debt = d.id
GROUP BY
    CASE
        WHEN t.id_user IS NOT NULL THEN t.id_user
        WHEN t.id_profile IS NOT NULL THEN p.id_user
        ELSE NULL
        END,
    CASE
        WHEN t.id_user IS NOT NULL THEN 'USER'
        WHEN t.id_profile IS NOT NULL THEN 'PROFILE'
        ELSE 'UNKNOWN'
        END,
    t.id_profile,
    t.id,
    t.name,
    c.name,
    b.name,
    d.name
ORDER BY
    net_amount DESC;

-- Vista de categorías con información de enrollments (ya tenía category_owner_id correctamente)
CREATE OR REPLACE VIEW vw_category_enrollments AS
SELECT
    ARRAY_AGG(ce.id) AS category_enrollment_ids,
    c.id_user AS owner_user_id,
    c.name AS category_name,
    COUNT(DISTINCT ce.id) AS total_enrollments,
    MIN(ce.enrollment_date) AS first_enrollment_date,
    MAX(ce.enrollment_date) AS last_enrollment_date,
    c.register_date AS category_register_date,
    (c.description->>'assignedBudget')::numeric AS assigned_budget,
    c.description->>'state' AS category_state,
    CASE
        WHEN c.description->>'state' = 'ACTIVE' THEN 'ACTIVA'
        WHEN c.description->>'state' IN ('INACTIVE', 'CANCELLED') THEN 'FINALIZADA'
        ELSE c.description->>'state'
        END AS category_status
FROM
    category c
        LEFT JOIN category_enrollment ce
                  ON c.id = ce.id_category
WHERE ce.id IS NOT NULL
GROUP BY
    c.id,
    c.name,
    c.description,
    c.id_user,
    c.register_date
ORDER BY
    total_enrollments DESC;
