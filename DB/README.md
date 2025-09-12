# KuenteCO Database System 📊

<p align="center">
  <img src="https://www.postgresql.org/media/img/about/press/elephant.png" alt="PostgreSQL Logo" height="100">
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://webassets.mongodb.com/_com_assets/cms/mongodb_logo1-76twgcu2dm.png" alt="MongoDB Logo" height="100">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/PostgreSQL-15+-blue?style=flat-square&logo=postgresql" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/MongoDB-7.0+-green?style=flat-square&logo=mongodb" alt="MongoDB">
  <img src="https://img.shields.io/badge/Docker-Ready-blue?style=flat-square&logo=docker" alt="Docker">
  <img src="https://img.shields.io/badge/Replication-Master%2FSlave-green?style=flat-square" alt="Replication">
  <img src="https://img.shields.io/badge/High%20Availability-99.9%25-green?style=flat-square" alt="HA">
</p>

## 📝 Descripción

Sistema de **bases de datos híbridas** para la arquitectura de microservicios de KuenteCO, combinando **PostgreSQL 15+** (datos financieros) y **MongoDB 7.0+** (IA y documentos). Diseñado con **alta disponibilidad**, replicación Master-Slave para PostgreSQL, y completamente contenerizado con **Docker**.

### ✨ Características Principales

#### 🐘 **PostgreSQL (KuentecoApp)**
- 📊 **Replicación en tiempo real** Master-Slave
- 🚀 **Alta disponibilidad** con failover automático
- 🔄 **Sincronización automática** de tasas de cambio
- 💾 **Backups automatizados** y versionados
- 📊 **Extensiones avanzadas** (pg_cron, pg_http)
- 🔐 **Seguridad robusta** con usuarios especializados

#### 🍃 **MongoDB (KuentecoChat)**
- 🤖 **Almacenamiento de IA** y historial de chat
- 📄 **Documentos JSON** nativos para flexibility
- 🚀 **Escalabilidad horizontal** optimizada
- 📊 **Índices inteligentes** para búsquedas rápidas
- 🔍 **Agregaciones complejas** para analytics

#### 🎯 **General**
- 🐳 **Contenerización completa** con Docker
- 🔍 **Monitoring integrado** con health checks
- 🔄 **Orquestación inteligente** con Docker Compose

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

### 🌐 Topología de Microservicios Híbridos

```
┌───────────────────────────────────────────────────────────────────┐
│                        ARQUITECTURA DE MICROSERVICIOS                        │
└────────────────────────────────┬───────────────────────────────────┘
                               │                                │
                     🏦 KuentecoApp                 🤖 KuentecoChat
                      (Core Financiero)              (Asistente IA)
                           :8080                           :7070
                               │                                │
                               ▼                                ▼

   ┌────────────────────────────────┐      ┌────────────────────────────────┐
   │         POSTGRESQL CLUSTER         │      │        MONGODB STANDALONE        │
   │                                │      │                                │
   │  ┌─────────────┐ ┌─────────────┐  │      │  ┌───────────────────────────┐  │
   │  │   MASTER    │ │   SLAVE     │  │      │  │       MONGO DB        │  │
   │  │  :5432     │ │  :5433     │  │      │  │        :27017          │  │
   │  │           │ │           │  │      │  │                        │  │
   │  │ • R/W      │ │ • R Only  │  │      │  │ • Chat History       │  │
   │  │ • Backup   │ │ • Replica │  │      │  │ • AI Models Data     │  │
   │  │ • Tasks    │ │ • LB      │  │      │  │ • Document Storage   │  │
   │  └────────┬─────┘ └─────────────┘  │      │  └───────────────────────────┘  │
   │           │         REPLICATION      │      └────────────────────────────────┘
   │           └──────▶◀───────────────┘      
   └────────────────────────────────┘      

   🐘 Datos Relacionales                     🍃 Documentos NoSQL
   • Usuarios, Perfiles, Finanzas            • Historial Conversacional
   • Transacciones, Presupuestos             • Respuestas IA, Analytics
   • Categorías, Deudas, Tipos Cambio         • Configuraciones ML
```
```

### 🔧 Beneficios de la Arquitectura Híbrida

| Componente | PostgreSQL Master | PostgreSQL Slave | MongoDB | Beneficio |
|------------|------------------|------------------|---------|----------|
| **Escritura** | ✅ Sí | ❌ No | ✅ Sí | Consistencia financiera + Flexibilidad IA |
| **Lectura** | ✅ Sí | ✅ Sí | ✅ Sí | Distribución óptima de carga |
| **Backup** | ✅ Sí | ✅ Sí | ✅ Sí | Redundancia completa |
| **Escalabilidad** | Vertical | Horizontal | Horizontal | Crecimiento adaptável |
| **Disponibilidad** | 99.9% | 99.9% | 99.9% | Tolerancia a fallos múltiple |
| **Especialización** | Finanzas | Analytics | IA/Docs | Rendimiento optimizado |

---

## 🚀 Instalación y Configuración

### 1️⃣ Clonar el Repositorio

```bash
git clone https://github.com/AlthosKal/KuenteCO.git
cd KuenteCO/DB
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

#### 🐘 PostgreSQL (KuentecoApp)
```bash
# Navegar al directorio PostgreSQL
cd PostgreSQL

# Levantar cluster PostgreSQL
docker compose up -d

# Verificar estado de contenedores
docker compose ps

# Ver logs en tiempo real
docker compose logs -f

# Ver logs de servicios específicos
docker compose logs -f postgres-master
docker compose logs -f postgres-slave
```

#### 🍃 MongoDB (KuentecoChat)
```bash
# Volver al directorio principal y navegar a MongoDB
cd ../MongoDB

# Construir y levantar MongoDB
docker build -t kuenteco-mongo .
docker run -d --name mongo-kuenteco \
  -p 27017:27017 \
  -v mongo-data:/data/db \
  kuenteco-mongo

# Verificar estado
docker ps | grep mongo-kuenteco

# Ver logs
docker logs mongo-kuenteco
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
DB/
├── 📝 README.md                    # Esta documentación
├── 🚫 .gitignore                   # Archivos ignorados
│
├── 🐘 PostgreSQL/                  # Cluster PostgreSQL
│   ├── 🐋 compose.yaml              # Orquestación Master-Slave
│   ├── 💾 backupMasterKuenteCO.sql.gz # Backup inicial
│   │
│   ├── 🏗️ master/                   # Configuración Master
│   │   ├── Dockerfile               # Imagen personalizada
│   │   ├── init-master.sh           # Script de inicialización
│   │   ├── postgresql.conf          # Configuración PostgreSQL
│   │   └── pg_hba.conf              # Configuración de acceso
│   │
│   ├── 📂 slave/                    # Configuración Slave
│   │   ├── Dockerfile               # Imagen personalizada
│   │   └── init-slave.sh            # Script de inicialización
│   │
│   ├── ⚙️ config/                   # Configuraciones compartidas
│   │   ├── postgresql.conf          # Configuración optimizada
│   │   └── pg_hba.conf              # Reglas de autenticación
│   │
│   └── 📜 db/                       # Scripts SQL
│       ├── kuenteco_schema_dump.sql     # Esquema completo
│       ├── DatabaseFunctionsKuenteCO.sql # Funciones y triggers
│       ├── DatabaseTriggersKuenteCO.sql  # Triggers específicos
│       └── DatabaseViewsKuenteCO.sql     # Vistas materializadas
│
└── 🍃 MongoDB/                     # Base NoSQL para IA
    └── Dockerfile                   # Imagen personalizada MongoDB
```

---

## 🚑 Health Checks y Monitoring

### 🔍 Verificar Estado del Sistema

#### 🐘 PostgreSQL Health Checks
```bash
# Estado general del cluster PostgreSQL
cd PostgreSQL
docker compose ps

# Health check de Master
docker exec MasterKuenteCO pg_isready -U master -d KuenteCO

# Health check de Slave
docker exec SlaveKuenteCO pg_isready -U replicator -d KuenteCO

# Ver métricas de conexiones
docker exec -it MasterKuenteCO psql -U master -d KuenteCO -c \
  "SELECT datname, numbackends, xact_commit, xact_rollback FROM pg_stat_database WHERE datname='KuenteCO';"
```

#### 🍃 MongoDB Health Checks
```bash
# Estado de MongoDB
docker ps | grep mongo-kuenteco

# Health check de MongoDB
docker exec mongo-kuenteco mongosh --eval "db.adminCommand('ping')"

# Ver métricas de MongoDB
docker exec mongo-kuenteco mongosh --eval \
  "db.adminCommand({serverStatus: 1}).connections"

# Ver bases de datos
docker exec mongo-kuenteco mongosh --eval "show dbs"
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

#### 🐘 PostgreSQL
```bash
# Backup completo
docker exec MasterKuenteCO pg_dump -U master KuenteCO > backup_$(date +%Y%m%d).sql

# Restaurar backup
docker exec -i MasterKuenteCO psql -U master KuenteCO < backup_20240101.sql

# Limpiar datos de prueba
cd PostgreSQL
docker compose down -v && docker compose up -d

# Acceso directo a psql
docker exec -it MasterKuenteCO psql -U master -d KuenteCO

# Ver configuración actual
docker exec -it MasterKuenteCO psql -U master -d KuenteCO -c "SHOW ALL;"
```

#### 🍃 MongoDB
```bash
# Backup de MongoDB
docker exec mongo-kuenteco mongodump --out /backup/$(date +%Y%m%d)

# Restaurar backup de MongoDB
docker exec mongo-kuenteco mongorestore /backup/20240101/

# Acceso directo a MongoDB shell
docker exec -it mongo-kuenteco mongosh

# Ver configuración de MongoDB
docker exec mongo-kuenteco mongosh --eval "db.adminCommand('getCmdLineOpts')"

# Limpiar datos de MongoDB
docker stop mongo-kuenteco
docker rm mongo-kuenteco
docker volume rm mongo-data
# Volver a crear
docker build -t kuenteco-mongo .
docker run -d --name mongo-kuenteco -p 27017:27017 -v mongo-data:/data/db kuenteco-mongo
```

---

## 🎯 Uso por Microservicio

### 🏦 KuentecoApp (Puerto :8080)
**Base de Datos:** PostgreSQL Master-Slave  
**Propósito:** Almacenamiento de datos financieros relacionales

**Tablas principales:**
- 👤 **Usuarios y Perfiles**: Autenticación, roles, configuraciones
- 💰 **Transacciones**: Movimientos financieros, categorias, presupuestos
- 📊 **Deudas**: Obligaciones, vencimientos, pagos
- 💱 **Tipos de Cambio**: Monedas, tasas actualizadas automáticamente
- 🔔 **Notificaciones**: Alertas de presupuesto, vencimientos

**Características:**
- 🔄 **ACID Compliance**: Transacciones consistentes
- 🔗 **Relaciones Complejas**: FK, joins optimizados
- 📈 **Agregaciones**: Reportes financieros complejos
- 🔐 **Seguridad**: Cifrado, roles granulares

### 🤖 KuentecoChat (Puerto :7070)
**Base de Datos:** MongoDB Standalone  
**Propósito:** Almacenamiento de documentos de IA y chat

**Colecciones principales:**
- 💬 **ChatHistory**: Historial completo de conversaciones
- 🤖 **AIResponses**: Respuestas generadas por modelos IA
- 📄 **DocumentAnalysis**: Análisis de documentos financieros
- ⚙️ **ModelConfigurations**: Configuraciones de modelos OpenAI/DeepSeek
- 📊 **Analytics**: Métricas de uso y rendimiento

**Características:**
- 🚀 **Esquema Flexible**: Documentos JSON dinámicos
- 📝 **Texto Completo**: Búsquedas en contenido de chat
- 📈 **Agregaciones**: Analytics complejos de conversaciones
- ⚡ **Alto Rendimiento**: Índices optimizados para IA

---

## 📧 Contacto y Soporte

- 🐛 **Issues**: [GitHub Issues](https://github.com/AlthosKal/KuenteCO/issues)
- 📧 **Email**: database@kuenteco.com
- 📄 **Documentación PostgreSQL**: [Oficial](https://www.postgresql.org/docs/)
- 🍃 **Documentación MongoDB**: [Oficial](https://www.mongodb.com/docs/)
- 🐋 **Docker Hub**: [Imágenes KuenteCO](https://hub.docker.com/u/yefff)

---

<p align="center">
  <b>📊 Sistema de bases de datos híbridas desarrollado con ❤️</b><br>
  <i>PostgreSQL + MongoDB - Alta disponibilidad y rendimiento para KuenteCO</i><br>
  <small>🐘 Datos relacionales financieros + 🍃 Documentos de IA</small>
</p>
