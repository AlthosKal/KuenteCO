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
    b.id AS budget_id,
    b.name AS budget_name,
    b.assigned_amount AS assigned_amount,
    COALESCE(SUM(t.amount), 0) AS actual_spent,
    (b.assigned_amount - COALESCE(SUM(t.amount), 0)) AS remaining_amount
FROM
    Budget b
        LEFT JOIN
    Transaction t ON b.id_category = t.id_category
GROUP BY
    b.id, b.name, b.assigned_amount;