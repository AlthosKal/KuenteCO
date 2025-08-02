# KuenteCO 💰

<p align="center">
  <img src="https://cdn.mcauto-images-production.sendgrid.net/6357b2503ba86bb8/276fd986-07c9-432b-a32a-ce059eae9a40/589x162.png" alt="Logo de KuenteCO" height="30%" width="50%">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Spring%20Boot-3.5.0-green?style=flat-square&logo=spring-boot" alt="Spring Boot">
  <img src="https://img.shields.io/badge/Flutter-3.0+-blue?style=flat-square&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/PostgreSQL-15+-blue?style=flat-square&logo=postgresql" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Docker-Container%20Ready-blue?style=flat-square&logo=docker" alt="Docker">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License">
</p>

## 📘 Introducción

**KuenteCO** es una solución integral de gestión financiera diseñada para democratizar el control financiero personal y empresarial. Esta plataforma multiplataforma combina la potencia de una arquitectura robusta con una interfaz intuitiva, permitiendo a usuarios particulares y pequeñas/medianas empresas tomar el control total de sus finanzas.

### 🎯 Misión del Proyecto

Transformar la manera en que las personas y negocios gestionan sus recursos financieros, proporcionando herramientas profesionales accesibles desde cualquier dispositivo, con la seguridad y escalabilidad que demanda el mundo moderno.

Este repositorio contiene el código fuente completo de KuenteCO, estructurado en una **arquitectura modular** que facilita el desarrollo, mantenimiento y escalabilidad del sistema.

---

## 🌐 Características Principales

### 💼 Gestión Financiera Integral
- ✅ **Registro intuitivo** de ingresos y egresos con categorización automática
- ✅ **Presupuestos inteligentes** con alertas y seguimiento en tiempo real
- ✅ **Metas de ahorro** con visualización de progreso y proyecciones
- ✅ **Informes financieros** con gráficos interactivos y análisis de tendencias
- ✅ **Gestión multi-cuenta** para el manejo de negocios
- ✅ **Importación automática** de transacciones bancarias
- ✅ **Análisis predictivo** para optimizar la toma de decisiones

### 🛡️ Seguridad y Escalabilidad
- 🔐 **Autenticación JWT** con tokens seguros y renovables
- 🌐 **Arquitectura DMZ** para máxima protección de datos
- 📊 **Replicación de base de datos** para alta disponibilidad
- 🔄 **Sincronización en tiempo real** entre dispositivos
- 🚀 **Escalabilidad horizontal** con contenedores Docker

## 🛠️ Stack Tecnológico

### Frontend
- **Flutter 3.0+** - Framework multiplataforma para desarrollo móvil y web
- **Dart** - Lenguaje de programación optimizado para UI
- **Provider** - Gestión de estado reactiva
- **Dio** - Cliente HTTP avanzado para comunicación con la API

### Backend
- **Spring Boot 3.5.0** - Framework Java enterprise con configuración automática
- **Spring Security** - Sistema de autenticación y autorización robusto
- **Spring Data JPA** - Capa de persistencia con Hibernate ORM
- **OpenAPI 3.0** - Documentación automática de la API REST
- **Resilience4j** - Patrones de resistencia (Circuit Breaker, Rate Limiter)

### Base de Datos
- **PostgreSQL 15+** - Base de datos relacional de código abierto
- **Replicación Master-Slave** - Para alta disponibilidad y rendimiento
- **Flyway** - Migraciones de base de datos versionadas
- **pg_cron & pg_http** - Automatización de tareas y integraciones externas

### Infraestructura y DevOps
- **Docker & Docker Compose** - Contenerización completa del stack
- **Nginx** - Proxy inverso y balanceador de carga
- **Maven** - Gestión de dependencias y construcción
- **JaCoCo** - Análisis de cobertura de código
- **Spotless** - Formateo automático de código

### Servicios Externos
- **SendGrid** - Sistema de notificaciones por email
- **Cloudinary** - Gestión y optimización de imágenes
- **OpenExchangeRate** - Tasas de cambio actualizadas
- **MercadoPago** - Procesamiento de pagos

---

## 🏢 Arquitectura del Sistema

### 🛡️ DMZ (Zona Desmilitarizada)

KuenteCO implementa una **arquitectura de tres capas** con DMZ para máxima seguridad:

```
┌─────────────────────┐
│   INTERNET (Público)    │
└──────────┬───────────┘
             │
        [🌐 Nginx]
             │
┌────────────┴───────────┐
│        DMZ ZONE         │
│  [📱 Frontend]  [⚙️ Backend]  │
└────────────┬────────────┘
             │
┌────────────┴───────────┐
│    RED INTERNA (Segura) │
│   [📊 Master DB] [📑 Slave DB]  │
└───────────────────────┘
```

### 🔧 Beneficios de la Arquitectura
- ✨ **Separación de responsabilidades** entre capas
- 🔒 **Aislamiento de datos** críticos en red privada
- ⚙️ **Balanceo de carga** automático con Nginx
- 📊 **Alta disponibilidad** con replicación de BD
- 🚀 **Escalabilidad horizontal** mediante contenedores
- 🛡️ **Protección DDoS** en la capa de entrada

---

## 🗂️ Estructura del Proyecto

```
KuenteCO/
├── 📏 README.md                 # Documentación principal
├── 🐳 compose.yaml              # Orquestación completa del stack
├── 🔑 .env-docker               # Variables de entorno (template)
├── 📦 postman_collection.json   # Colección de pruebas API
│
├── 📁 FRONT-END/               # Aplicación Flutter
│   ├── 🎨 lib/                   # Código fuente Dart
│   ├── 🖼️ assets/                # Recursos multimedia
│   ├── 📱 android/               # Configuración Android
│   ├── 🍎 ios/                   # Configuración iOS
│   └── 📋 pubspec.yaml          # Dependencias Flutter
│
├── 📁 BACK-END/                # API REST Spring Boot
│   └── 📁 KuentecoApp/
│       ├── ⚙️ src/                  # Código fuente Java
│       ├── 📦 pom.xml              # Dependencias Maven
│       └── 🐳 Dockerfile          # Imagen del backend
│
├── 📁 Database/                # Sistema de bases de datos
│   ├── 📊 master/               # BD Principal (escritura)
│   ├── 📑 slave/                # BD Replica (lectura)
│   ├── 📄 db/                   # Scripts SQL
│   └── ⚙️ config/               # Configuraciones PostgreSQL
│
└── 📁 end-to-end-tests/        # Pruebas automatizadas E2E
    └── 🥂 src/test/             # Tests con Karate Framework
```

### 🔗 Componentes Principales

| Componente | Tecnología | Puerto | Descripción |
|------------|-------------|---------|-------------|
| **Frontend** | Flutter 3.0+ | :5000 | Interfaz multiplataforma (móvil/web) |
| **Backend** | Spring Boot 3.5 | :8080 | API REST con autenticación JWT |
| **DB Master** | PostgreSQL 15 | :5432 | Base de datos principal (R/W) |
| **DB Slave** | PostgreSQL 15 | :5433 | Réplica para lectura (R) |
| **Proxy** | Nginx | :80/:443 | Balanceador y SSL termination |

### 📚 Documentación Detallada

Cada componente incluye documentación especializada:

✅ **[📁 Frontend](./FRONT-END/README.md)** - Aplicación Flutter  
✅ **[📁 Backend](./BACK-END/KuentecoApp/README.md)** - API Spring Boot  
✅ **[📁 Database](./Database/README.md)** - PostgreSQL con replicación  
✅ **[Tests E2E](./end-to-end-tests/)** - Pruebas automatizadas

---

## 🚀 Guía de Despliegue

### 🔧 Requisitos Previos

- **Docker** 20.10+ y **Docker Compose** 2.0+
- **Git** para clonar el repositorio
- **4GB RAM** mínimo recomendado
- **Puertos disponibles**: 5432, 5433, 8080

### 📜 Configuración Rápida

#### 1️⃣ Clonar el repositorio
```bash
git clone https://github.com/AlthosKal/KuenteCO.git
cd KuenteCO
```

#### 2️⃣ Configurar variables de entorno
Crea un archivo `.env.docker` basado en la siguiente plantilla:

```bash
# 📧 Configuración de Email (SendGrid)
SENDGRID_API_KEY=SG.your_sendgrid_api_key_here
EMAIL_SENDGRID=noreply@tuemail.com
VERIFICATION_EMAIL=d-1234567890abcdef  # Template ID verificación
RESET_PASSWORD=d-0987654321fedcba   # Template ID reset password

# 🖼️ Gestión de Imágenes (Cloudinary)
CLOUDINARY_NAME=your_cloud_name
CLOUDINARY_API_KEY=123456789012345
CLOUDINARY_API_SECRET=your_cloudinary_secret

# 🔐 Seguridad JWT
JWT_SECRET=your_super_secret_jwt_key_minimum_32_characters_long

# 📊 Base de Datos Principal (Master)
SPRING_DATASOURCE_URL_MASTER=jdbc:postgresql://postgres-master-database:5432/KuenteCO
SPRING_DATASOURCE_USERNAME_MASTER=master
SPRING_DATASOURCE_PASSWORD_MASTER=secure_master_password

# 📑 Base de Datos Réplica (Slave)
SPRING_DATASOURCE_URL_SLAVE=jdbc:postgresql://postgres-replica-database:5432/KuenteCO
SPRING_DATASOURCE_USERNAME_SLAVE=replicator
SPRING_DATASOURCE_PASSWORD_SLAVE=secure_slave_password
```

#### 3️⃣ Desplegar el stack completo
```bash
# Levanta todos los servicios en background
docker compose --env-file .env.docker up -d

# Verificar el estado de los contenedores
docker compose ps

# Ver logs en tiempo real
docker compose logs -f
```

### 📊 Servicios Desplegados

| Servicio | URL Local | Estado | Descripción |
|----------|-----------|---------|-------------|
| **Backend API** | http://localhost:8080 | ✅ Activo | API REST + Swagger UI |
| **Base de Datos Master** | localhost:5432 | ✅ Activo | PostgreSQL Principal |
| **Base de Datos Slave** | localhost:5433 | ✅ Activo | PostgreSQL Réplica |
| **Frontend** | http://localhost:3000 | 🔄 Próximamente | Aplicación Flutter Web |
| **Nginx Proxy** | http://localhost:80 | 🔄 Próximamente | Balanceador de carga |

### 🚑 Health Checks

```bash
# Verificar salud de la API
curl http://localhost:8080/actuator/health

# Verificar conexión a BD Master
docker exec DatabaseMasterKuenteCO pg_isready -U master -d KuenteCO

# Verificar conexión a BD Slave
docker exec DatabaseSlaveKuenteCO pg_isready -U replicator -d KuenteCO
```

### 🔍 Documentación de la API
Una vez desplegado, puedes acceder a la documentación interactiva:
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **OpenAPI JSON**: http://localhost:8080/v3/api-docs

### 🛠️ Comandos Útiles

```bash
# Detener todos los servicios
docker compose down

# Reconstruir imágenes y reiniciar
docker compose down && docker compose up -d --build

# Ver logs de un servicio específico
docker compose logs -f backend
docker compose logs -f postgres-master-database

# Acceder a un contenedor
docker exec -it BackendKuenteCO bash
docker exec -it DatabaseMasterKuenteCO psql -U master -d KuenteCO

# Limpiar volúmenes (CUIDADO: borra datos)
docker compose down -v
```

---

## 🎯 Casos de Uso

### 👥 Para Usuarios Particulares
- 📈 **Control de gastos personales** con categorización inteligente
- 🎯 **Metas de ahorro** con seguimiento visual de progreso
- 📋 **Presupuestos mensuales** con alertas de límites
- 📊 **Análisis de hábitos** financieros con recomendaciones
- 📱 **Sincronización multi-dispositivo** para acceso ubicuo

### 🏢 Para Pequeños y Medianos Negocios
- 💼 **Gestión centralizada** de múltiples cuentas empresariales
- 📝 **Reportes contables** automatizados con exportación
- 🔄 **Automatización** de procesos financieros repetitivos
- 📊 **Dashboard ejecutivo** con KPIs en tiempo real
- 👥 **Gestión de equipos** con permisos granulares

---

## 📝 Roadmap

### 🔄 Versión Actual (v1.0)
- ✅ API REST completa con autenticación JWT
- ✅ Base de datos con replicación Master-Slave
- ✅ Aplicación móvil Flutter multiplataforma
- ✅ Integración con servicios externos (SendGrid, Cloudinary)

### 🔜 Próximas Funcionalidades (v1.1)
- 🔄 Frontend web responsivo
- 🔄 Proxy Nginx con SSL/TLS
- 🔄 Notificaciones push en tiempo real
- 🔄 Importación automática de transacciones bancarias

### 🔮 Futuro (v2.0+)
- 🤖 Inteligencia artificial para predicciones financieras
- 🌐 Multi-tenancy para empresas
- 🚫integrations con más plataformas de pago
- 📱 Aplicación de escritorio (Electron)
