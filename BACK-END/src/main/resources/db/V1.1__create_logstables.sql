CREATE TABLE IF NOT EXISTS exchange_rate_logs (
id SERIAL PRIMARY KEY,
log_message TEXT,
log_timestamp TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS audit_logs (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    record_id INTEGER,
    log_message TEXT,
    log_timestamp TIMESTAMP DEFAULT NOW()
    );

-- Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_audit_logs_table_name ON audit_logs(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp ON audit_logs(log_timestamp);
CREATE INDEX IF NOT EXISTS idx_audit_logs_record_id ON audit_logs(record_id);