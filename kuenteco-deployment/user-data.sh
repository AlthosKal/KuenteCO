#!/bin/bash
set -e

# Actualizar el sistema
apt-get update -y

# Instalar dependencias básicas
apt-get install -y curl wget git htop

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu

# Instalar Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Crear directorio para la aplicación
mkdir -p /opt/kuenteco
chown ubuntu:ubuntu /opt/kuenteco

# Habilitar Docker para que inicie automáticamente
systemctl enable docker
systemctl start docker

# Configurar logs de Docker para evitar que se llenen los discos
cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# Reiniciar Docker para aplicar configuración
systemctl restart docker

echo "Docker installation completed successfully!" > /opt/kuenteco/install.log
