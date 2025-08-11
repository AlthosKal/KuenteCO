#!/bin/bash
set -e

echo "🚀 Iniciando despliegue de KuenteCO..."

# Verificar que Docker esté funcionando
echo "📦 Verificando Docker..."
docker --version
docker-compose --version

# Limpiar cualquier contenedor previo
echo "🧹 Limpiando contenedores anteriores..."
docker-compose down -v || true

# Eliminar imágenes antiguas para forzar re-pull
echo "🔄 Actualizando imágenes Docker..."
docker-compose pull

# Verificar que las imágenes existan
echo "🔍 Verificando imágenes disponibles..."
docker pull yefff/image-frontend-kuenteco-ui:1.0.2
docker pull yefff/image-backend-kuenteco-app:1.0.2
docker pull yefff/image-backend-kuenteco-chat:1.0.2
docker pull yefff/image-master-kuenteco:1.1.1
docker pull yefff/image-slave-kuenteco:1.1.1
docker pull yefff/image-mongo-kuenteco:1.0.0

# Crear volúmenes necesarios
echo "💾 Creando volúmenes..."
docker volume create postgres-master-data || true
docker volume create postgres-replica-data || true
docker volume create mongo-kuenteco-data || true

# Iniciar las bases de datos primero
echo "🗄️ Iniciando bases de datos..."
docker-compose up -d postgres-master-database

# Esperar a que la base master esté lista
echo "⏳ Esperando que PostgreSQL Master esté listo..."
sleep 30

# Verificar que la base master esté healthy
until docker-compose ps postgres-master-database | grep -q "healthy"; do
  echo "Esperando PostgreSQL Master..."
  sleep 10
done

# Iniciar base replica
echo "🗄️ Iniciando PostgreSQL Replica..."
docker-compose up -d postgres-replica-database

# Esperar a que la replica esté lista
echo "⏳ Esperando que PostgreSQL Replica esté listo..."
sleep 30

until docker-compose ps postgres-replica-database | grep -q "healthy"; do
  echo "Esperando PostgreSQL Replica..."
  sleep 10
done

# Iniciar MongoDB
echo "🗄️ Iniciando MongoDB..."
docker-compose up -d mongo-database

# Esperar a que MongoDB esté listo
echo "⏳ Esperando que MongoDB esté listo..."
sleep 20

until docker-compose ps mongo-database | grep -q "healthy"; do
  echo "Esperando MongoDB..."
  sleep 10
done

# Iniciar backends
echo "🔧 Iniciando servicios backend..."
docker-compose up -d kuenteco-app
sleep 30

docker-compose up -d kuenteco-chat
sleep 30

# Finalmente iniciar frontend
echo "🎨 Iniciando frontend..."
docker-compose up -d kuenteco-ui

# Mostrar estado final
echo "📊 Estado de los servicios:"
docker-compose ps

echo ""
echo "✅ ¡Despliegue completado!"
echo "🌐 La aplicación debería estar disponible en:"
echo "   Frontend: http://$(curl -s ifconfig.me)"
echo "   Backend App: http://$(curl -s ifconfig.me):8080"
echo "   Backend Chat: http://$(curl -s ifconfig.me):7070"
echo ""
echo "📝 Para ver logs en tiempo real:"
echo "   docker-compose logs -f"
