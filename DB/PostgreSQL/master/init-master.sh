#!/bin/bash
set -e

# Solo realizar la configuración completa si es la primera vez
if [ ! -f "/var/lib/postgresql/data/PG_VERSION" ]; then
    echo "Initializing master database for the first time..."
    
    # Configuración inicial
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Crear usuario replicador y configurar extensiones
    CREATE USER replicator REPLICATION LOGIN ENCRYPTED PASSWORD '$REPLICATOR_PASSWORD';
    CREATE EXTENSION IF NOT EXISTS http;
    CREATE EXTENSION IF NOT EXISTS pg_cron;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO replicator;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO replicator;
EOSQL
else
    echo "Database already initialized, ensuring replicator user exists..."
    
    # Copiar archivos de configuración
    cp /etc/postgresql/postgresql.conf /var/lib/postgresql/data/postgresql.conf
    cp /etc/postgresql/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
    
    # Verificar y crear usuario replicador si no existe
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'replicator') THEN
            CREATE USER replicator REPLICATION LOGIN ENCRYPTED PASSWORD '$REPLICATOR_PASSWORD';
            GRANT SELECT ON ALL TABLES IN SCHEMA public TO replicator;
            ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO replicator;
        END IF;
    END
    \$\$;
EOSQL
    
    # Reiniciar PostgreSQL para aplicar la nueva configuración
    pg_ctl -D /var/lib/postgresql/data restart
fi

echo "Master node configuration completed!"