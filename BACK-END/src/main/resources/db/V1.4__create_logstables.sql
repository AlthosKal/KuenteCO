CREATE TABLE IF NOT EXISTS exchange_rate_logs (
id SERIAL PRIMARY KEY,
log_message TEXT,
log_timestamp TIMESTAMP DEFAULT now()
    );