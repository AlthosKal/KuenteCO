#!/bin/bash
set -e

# Verificar si ya está configurado como esclavo
if [ -f "/var/lib/postgresql/data/standby.signal" ]; then
    echo "Slave node already configured, skipping setup..."
    exit 0
fi

# Si hay datos pero no está configurado como esclavo, limpiar
if [ -f "/var/lib/postgresql/data/PG_VERSION" ]; then
    echo "Found existing data directory but not configured as slave. Cleaning..."
    rm -rf /var/lib/postgresql/data/*
fi

# Configurar archivo de contraseña temporal
cat > /tmp/pg_basebackup_password << EOF
$REPLICATOR_PASSWORD
EOF
chmod 600 /tmp/pg_basebackup_password

# Esperar a que el nodo maestro esté disponible
echo "Waiting for master node at $MASTER_HOST:$MASTER_PORT to be available..."
until pg_isready -h $MASTER_HOST -p $MASTER_PORT -U $REPLICATOR_USER; do
  echo "Waiting for master to be ready..."
  sleep 5
done

# Realizar la copia de seguridad base
PGPASSFILE=/tmp/pg_basebackup_password pg_basebackup \
  -D /var/lib/postgresql/data \
  -h $MASTER_HOST -p $MASTER_PORT \
  -X stream -c fast \
  -U $REPLICATOR_USER -w -R

# Asegurarse de que está en modo standby
touch /var/lib/postgresql/data/standby.signal

# Configuración adicional de réplica
cat >> /var/lib/postgresql/data/postgresql.auto.conf << EOF
primary_conninfo = 'host=$MASTER_HOST port=$MASTER_PORT user=$REPLICATOR_USER password=$REPLICATOR_PASSWORD application_name=DatabaseSlaveKuenteCO'
EOF

# Limpiar archivo temporal de contraseña
rm -f /tmp/pg_basebackup_password

echo "Slave node configuration completed successfully!"