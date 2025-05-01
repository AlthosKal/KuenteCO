--Esta vista agrupa las transacciones por categoría
--Tablas Relacionadas: Transaction - Category
CREATE OR REPLACE VIEW vw_transactions_by_category AS
SELECT
    c.name AS category_name,
    SUM(t.amount) AS total_amount,
    COUNT(t.id) AS transaction_count
FROM
    Transaction t
        JOIN
    Category c ON t.id_category = c.id
GROUP BY
    c.name;

--Esta vista compara el presupesto asignado con los gastos reales
--Tablas Relacionadas: Budget - Transaction
CREATE OR REPLACE VIEW vw_budget_vs_actual AS
SELECT
    c.id AS category_id,
    c.name AS category_name,
    c.assigned_budget AS assigned_amount,
    COALESCE(SUM(t.amount), 0) AS actual_spent,
    (c.assigned_budget - COALESCE(SUM(t.amount), 0)) AS remaining_amount
FROM
    category c
        LEFT JOIN transaction t ON c.id = t.id_category AND t.type = 'EXPENSE'
GROUP BY
    c.id, c.name, c.assigned_budget;
