# KuenteCO Database System 📊

<p align="center">
  <img src="https://www.postgresql.org/media/img/about/press/elephant.png" alt="PostgreSQL Logo" height="120">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/PostgreSQL-15+-blue?style=flat-square&logo=postgresql" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Docker-Ready-blue?style=flat-square&logo=docker" alt="Docker">
  <img src="https://img.shields.io/badge/Replication-Master%2FSlave-green?style=flat-square" alt="Replication">
  <img src="https://img.shields.io/badge/High%20Availability-99.9%25-green?style=flat-square" alt="HA">
</p>

## 📝 Descripción

Sistema de **alta disponibilidad** para KuenteCO basado en **PostgreSQL 15+** con arquitectura **Master-Slave** para garantizar escalabilidad, rendimiento y tolerancia a fallos. Implementado completamente con **Docker** para facilitar el despliegue y mantenimiento.

### ✨ Características Principales

- 📊 **Replicación en tiempo real** Master-Slave
- 🚀 **Alta disponibilidad** con failover automático
- 🐳 **Contenerización completa** con Docker
- 🔄 **Sincronización automática** de tasas de cambio
- 💾 **Backups automatizados** y versionados
- 🔐 **Seguridad robusta** con usuarios especializados
- 📊 **Extensiones avanzadas** (pg_cron, pg_http)
- 🔍 **Monitoring integrado** con health checks

> 📍 **Imágenes Docker Oficiales**  
> 👉 [MasterKuenteCO](https://hub.docker.com/repository/docker/yefff/image-master-kuenteco/general)  
> 👉 [SlaveKuenteCO](https://hub.docker.com/repository/docker/yefff/image-slave-kuenteco/general)

### 📚 Referencias Técnicas
- 🔗 [PostgreSQL Replication Guide](https://kinsta.com/es/blog/postgresql-replicacion/)
- 🔗 [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- 🔗 [PostgreSQL High Availability](https://www.postgresql.org/docs/current/high-availability.html)

---

## ✅ Requisitos Previos

### 🛠️ Herramientas Necesarias
- **Docker** 20.10+ y **Docker Compose** 2.0+
- **4GB RAM** mínimo disponible
- **20GB** espacio en disco para datos
- **Puertos libres**: 5432, 5433

### 📚 Conocimientos Recomendados
- Comandos básicos de Docker
- SQL y administración de PostgreSQL
- Conceptos de replicación de bases de datos

---

## 🏢 Arquitectura del Sistema

### 📊 Topología Master-Slave

```
┌─────────────────────────────────────┐
│                APLICACIÓN                    │
│        (Spring Boot Backend)             │
└─────────────┬───────────────────────┘
             │                      │
             │                      │
         ESCRITURA                   LECTURA
             │                      │
             ▼                      ▼
┌──────────────────┐    ┌──────────────────┐
│   MASTER DATABASE   │    │   SLAVE DATABASE    │
│   PostgreSQL 15+    │    │   PostgreSQL 15+    │
│      :5432          │    │      :5433          │
│                    │    │                    │
│ • Escritura/Lectura │    │ • Solo Lectura     │
│ • Extensiones      │    │ • Réplica Síncrona │
│ • Backups          │    │ • Balanceo Carga   │
└──────────┬─────────┘    └──────────────────┘
           │
    REPLICACIÓN STREAMING
           │
    ┌───────▶◀───────────────────────────────────────┐
```

### 🔧 Beneficios de la Arquitectura

| Aspecto | Master | Slave | Beneficio |
|---------|--------|-------|----------|
| **Escritura** | ✅ Sí | ❌ No | Consistencia de datos |
| **Lectura** | ✅ Sí | ✅ Sí | Distribución de carga |
| **Backup** | ✅ Sí | ✅ Sí | Redundancia |
| **Escalabilidad** | Vertical | Horizontal | Más lecturas simultáneas |
| **Disponibilidad** | 99.9% | 99.9% | Tolerancia a fallos |

---

## 🚀 Instalación y Configuración

### 1️⃣ Clonar el Repositorio

```bash
git clone https://github.com/AlthosKal/KuenteCO.git
cd KuenteCO/Database
```

### 2️⃣ Verificar Docker

```bash
# Verificar versión de Docker
docker --version
docker compose version

# Verificar espacio disponible
df -h

# Verificar puertos libres
netstat -tuln | grep -E ':5432|:5433'
```

### 3️⃣ Desplegar el Stack de Bases de Datos

```bash
# Levantar servicios en background
docker compose up -d

# Verificar estado de contenedores
docker compose ps

# Ver logs en tiempo real
docker compose logs -f

# Ver logs de un servicio específico
docker compose logs -f postgres-master
```

---

## 🔄 Configuración de Replicación

### 🔧 Configuración Automática vs Manual

Las imágenes Docker de KuenteCO vienen **preconfiguradas** con replicación. Sin embargo, si necesitas configurarla manualmente o personalizar la configuración:

### 1️⃣ Crear Usuario Replicador (Master)

```bash
# Acceder al contenedor Master
docker exec -it MasterKuenteCO psql -U master -d KuenteCO
```

```sql
-- Crear usuario para replicación
CREATE USER replicator REPLICATION LOGIN ENCRYPTED PASSWORD 'secure_replication_password';

-- Otorgar permisos necesarios
GRANT CONNECT ON DATABASE "KuenteCO" TO replicator;
GRANT USAGE ON SCHEMA public TO replicator;

-- Verificar usuario
\du replicator
```

### 2️⃣ Configurar Archivos de Replicación

```bash
# Copiar configuraciones optimizadas
docker cp ./config/postgresql.conf MasterKuenteCO:/var/lib/postgresql/data/
docker cp ./config/pg_hba.conf MasterKuenteCO:/var/lib/postgresql/data/

# Reiniciar para aplicar cambios
docker restart MasterKuenteCO
```

### 3️⃣ Configurar Slave (Si es necesario)

```bash
# Detener slave
docker stop SlaveKuenteCO

# Limpiar datos existentes
docker exec SlaveKuenteCO rm -rf /var/lib/postgresql/data/*

# Inicializar réplica desde master
docker exec -it SlaveKuenteCO pg_basebackup \
  -D /var/lib/postgresql/data \
  -h MasterKuenteCO -p 5432 \
  -X stream -c fast \
  -U replicator -W -R

# Reiniciar slave
docker start SlaveKuenteCO
```

### 4️⃣ Verificar Replicación

```bash
# Estado de replicación en Master
docker exec -it MasterKuenteCO psql -U master -d KuenteCO -c \
  "SELECT client_addr, state, sync_state FROM pg_stat_replication;"

# Estado de réplica en Slave
docker exec -it SlaveKuenteCO psql -U replicator -d KuenteCO -c \
  "SELECT pg_is_in_recovery(), pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn();"
```

---

## 📁 Estructura de Archivos

```
Database/
├── 🐋 compose.yaml              # Orquestación de contenedores
├── 📝 README.md                # Esta documentación
├── 💾 backupMasterKuenteCO.sql.gz # Backup inicial
│
├── 🏗️ master/                   # Configuración Master
│   ├── Dockerfile               # Imagen personalizada
│   ├── init-master.sh           # Script de inicialización
│   ├── postgresql.conf          # Configuración PostgreSQL
│   └── pg_hba.conf              # Configuración de acceso
│
├── 📂 slave/                    # Configuración Slave
│   ├── Dockerfile               # Imagen personalizada
│   └── init-slave.sh            # Script de inicialización
│
├── ⚙️ config/                   # Configuraciones compartidas
│   ├── postgresql.conf          # Configuración optimizada
│   └── pg_hba.conf              # Reglas de autenticación
│
└── 📜 db/                       # Scripts SQL
    ├── schema.sql               # Esquema de base de datos
    ├── DatabaseFunctionsKuenteCO.sql # Funciones y triggers
    ├── DatabaseTriggersKuenteCO.sql  # Triggers específicos
    └── DatabaseViewsKuenteCO.sql     # Vistas materializadas
```

---

## 🚑 Health Checks y Monitoring

### 🔍 Verificar Estado del Sistema

```bash
# Estado general de contenedores
docker compose ps

# Health check de Master
docker exec MasterKuenteCO pg_isready -U master -d KuenteCO

# Health check de Slave
docker exec SlaveKuenteCO pg_isready -U replicator -d KuenteCO

# Ver métricas de conexiones
docker exec -it MasterKuenteCO psql -U master -d KuenteCO -c \
  "SELECT datname, numbackends, xact_commit, xact_rollback FROM pg_stat_database WHERE datname='KuenteCO';"
```

### 📊 Métricas de Rendimiento

```bash
# Tamaño de base de datos
docker exec -it MasterKuenteCO psql -U master -d KuenteCO -c \
  "SELECT pg_size_pretty(pg_database_size('KuenteCO'));"

# Consultas lentas
docker exec -it MasterKuenteCO psql -U master -d KuenteCO -c \
  "SELECT query, mean_exec_time, calls FROM pg_stat_statements ORDER BY mean_exec_time DESC LIMIT 5;"

# Estado de replicación
docker exec -it MasterKuenteCO psql -U master -d KuenteCO -c \
  "SELECT application_name, client_addr, state, sent_lsn, write_lsn, flush_lsn, replay_lsn FROM pg_stat_replication;"
```

---

## 🌐 Extensiones Avanzadas

### 🔄 Integración con OpenExchangeRate

KuenteCO incluye actualización automática de tasas de cambio mediante:

#### Extensiones Requeridas
- **pg_http** - Para realizar peticiones HTTP
- **pg_cron** - Para programar tareas automáticas

#### Instalación (si no están incluidas)

```bash
# Acceder al contenedor Master
docker exec -it MasterKuenteCO bash

# Instalar dependencias
apt update && apt install -y postgresql-server-dev-15 make gcc git

# Instalar pg_http
git clone https://github.com/pramsey/pgsql-http.git
cd pgsql-http && make && make install

# Instalar pg_cron
cd .. && git clone https://github.com/citusdata/pg_cron.git
cd pg_cron && make && make install

# Habilitar extensiones
psql -U master -d KuenteCO -c "CREATE EXTENSION IF NOT EXISTS http;"
psql -U master -d KuenteCO -c "CREATE EXTENSION IF NOT EXISTS pg_cron;"
```

#### Configurar Actualización Automática

```bash
# Cargar funciones de tasas de cambio
docker cp ./db/DatabaseFunctionsKuenteCO.sql MasterKuenteCO:/tmp/
docker exec -it MasterKuenteCO psql -U master -d KuenteCO -f /tmp/DatabaseFunctionsKuenteCO.sql

# Programar actualización cada 2 horas
docker exec -it MasterKuenteCO psql -U master -d KuenteCO -c \
  "SELECT cron.schedule('update-exchange-rates', '0 */2 * * *', 'SELECT update_exchange_rates();');"
```

---

## 🛠️ Troubleshooting

### ⚠️ Problemas Comunes

#### Problema: Contenedores no inician
```bash
# Verificar logs
docker compose logs

# Limpiar volúmenes y reiniciar
docker compose down -v
docker compose up -d
```

#### Problema: Replicación no funciona
```bash
# Verificar conectividad
docker exec MasterKuenteCO ping SlaveKuenteCO

# Revisar configuración de replicación
docker exec -it MasterKuenteCO psql -U master -d KuenteCO -c \
  "SELECT * FROM pg_stat_replication;"

# Reiniciar replicación
docker restart SlaveKuenteCO
```

#### Problema: Performance lenta
```bash
# Verificar memoria y CPU
docker stats

# Analizar consultas
docker exec -it MasterKuenteCO psql -U master -d KuenteCO -c \
  "SELECT query, total_exec_time, calls, mean_exec_time FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 10;"
```

### 🔧 Comandos Útiles

```bash
# Backup completo
docker exec MasterKuenteCO pg_dump -U master KuenteCO > backup_$(date +%Y%m%d).sql

# Restaurar backup
docker exec -i MasterKuenteCO psql -U master KuenteCO < backup_20240101.sql

# Limpiar datos de prueba
docker compose down -v && docker compose up -d

# Acceso directo a psql
docker exec -it MasterKuenteCO psql -U master -d KuenteCO

# Ver configuración actual
docker exec -it MasterKuenteCO psql -U master -d KuenteCO -c "SHOW ALL;"
```

---

## 📧 Contacto y Soporte

- 🐛 **Issues**: [GitHub Issues](https://github.com/AlthosKal/KuenteCO/issues)
- 📧 **Email**: database@kuenteco.com
- 📄 **Documentación PostgreSQL**: [Oficial](https://www.postgresql.org/docs/)
- 🐋 **Docker Hub**: [Imágenes KuenteCO](https://hub.docker.com/u/yefff)

---

<p align="center">
  <b>📊 Sistema de base de datos desarrollado con ❤️</b><br>
  <i>Alta disponibilidad y rendimiento para KuenteCO</i>
</p>
