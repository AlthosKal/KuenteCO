#!/bin/bash
set -e

echo "🚀 Redespliegue limpio de KuenteCO..."

# Verificar que Docker esté funcionando
echo "📦 Verificando Docker..."
docker --version
docker-compose --version

# Crear volúmenes necesarios
echo "💾 Creando volúmenes..."
docker volume create postgres-master-data || true
docker volume create postgres-replica-data || true
docker volume create mongo-kuenteco-data || true

# Iniciar las bases de datos primero
echo "🗄️ Iniciando PostgreSQL Master..."
docker-compose up -d postgres-master-database

# Esperar que esté ready
echo "⏳ Esperando PostgreSQL Master..."
for i in {1..60}; do
    if docker-compose ps postgres-master-database | grep -q "healthy"; then
        echo "✅ PostgreSQL Master está listo"
        break
    fi
    echo "Esperando... ($i/60)"
    sleep 5
done

# Iniciar PostgreSQL Replica
echo "🗄️ Iniciando PostgreSQL Replica..."
docker-compose up -d postgres-replica-database

# Esperar que esté ready
echo "⏳ Esperando PostgreSQL Replica..."
for i in {1..60}; do
    if docker-compose ps postgres-replica-database | grep -q "healthy"; then
        echo "✅ PostgreSQL Replica está listo"
        break
    fi
    echo "Esperando... ($i/60)"
    sleep 5
done

# Iniciar MongoDB
echo "🗄️ Iniciando MongoDB..."
docker-compose up -d mongo-database

# Esperar que esté ready
echo "⏳ Esperando MongoDB..."
for i in {1..30}; do
    if docker-compose ps mongo-database | grep -q "healthy"; then
        echo "✅ MongoDB está listo"
        break
    fi
    echo "Esperando... ($i/30)"
    sleep 5
done

# Iniciar backends
echo "🔧 Iniciando Backend App..."
docker-compose up -d kuenteco-app
sleep 10

echo "🔧 Iniciando Backend Chat..."
docker-compose up -d kuenteco-chat
sleep 10

# Iniciar frontend
echo "🎨 Iniciando Frontend..."
docker-compose up -d kuenteco-ui

# Esperar un momento final
sleep 5

# Mostrar estado
echo "📊 Estado final de los servicios:"
docker-compose ps

echo ""
echo "✅ ¡Redespliegue completado!"
echo "🌐 Frontend: http://$(curl -s ifconfig.me)"
echo "🔧 Backend App: http://$(curl -s ifconfig.me):8080"
echo "💬 Backend Chat: http://$(curl -s ifconfig.me):7070"
