# KuenteCO App ⚙️

<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/7/79/Spring_Boot.svg" alt="Spring Boot Logo" height="120">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Spring%20Boot-3.5.0-green?style=flat-square&logo=spring-boot" alt="Spring Boot">
  <img src="https://img.shields.io/badge/Java-17-orange?style=flat-square&logo=openjdk" alt="Java">
  <img src="https://img.shields.io/badge/Maven-3.8+-blue?style=flat-square&logo=apache-maven" alt="Maven">
  <img src="https://img.shields.io/badge/PostgreSQL-15+-blue?style=flat-square&logo=postgresql" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/Docker-Ready-blue?style=flat-square&logo=docker" alt="Docker">
  <img src="https://img.shields.io/badge/API-REST-green?style=flat-square" alt="REST API">
</p>

## 📝 Descripción

**API REST empresarial** de KuenteCO desarrollada con **Spring Boot 3.5.0**, diseñada siguiendo **principios SOLID** y **arquitectura de capas**. Proporciona servicios seguros, escalables y de alto rendimiento para la gestión financiera integral.

### ✨ Características Principales

- 🛡️ **Seguridad robusta** con JWT y Spring Security
- 📊 **Alta disponibilidad** con replicación de base de datos Master-Slave
- 🚀 **Performance optimizado** con HikariCP y pool de conexiones
- 📄 **Documentación automática** con OpenAPI 3.0 (Swagger)
- 🔄 **Resilencia** con Circuit Breaker y Rate Limiting (Resilience4j)
- 📧 **Notificaciones** vía SendGrid con templates dinámicos
- 🖼️ **Gestión de archivos** con Cloudinary CDN
- 🌐 **Tasas de cambio** actualizadas en tiempo real
- 💳 **Integración bancaria** con Bancolombia API
- 💰 **Pagos online** con MercadoPago SDK
- 📊 **Métricas y monitoring** con Spring Actuator
- 🧪 **Testing** exhaustivo con JUnit 5 y Mockito

---

## 🛠️ Stack Tecnológico

### Core Framework
- **Spring Boot 3.5.0** - Framework base con configuración automática
- **Java 21** - Versión LTS más reciente con características modernas
- **Maven 3.8+** - Gestión de dependencias y build automation

### Seguridad y Autenticación
- **Spring Security 6** - Framework de seguridad integral
- **JWT (JSON Web Tokens)** - Autenticación stateless
- **BCrypt** - Hash seguro de contraseñas
- **CORS** configurado para requests cross-origin

### Persistencia y Base de Datos
- **Spring Data JPA** - Capa de persistencia con Hibernate
- **PostgreSQL 15+** - Base de datos principal
- **Flyway** - Migraciones de esquema versionadas
- **HikariCP** - Pool de conexiones de alto rendimiento
- **Database Replication** - Master-Slave para escalabilidad

### Servicios Externos
- **SendGrid** - Servicio de email transaccional
- **Cloudinary** - CDN y procesamiento de imágenes
- **Bancolombia API** - Integración bancaria para transacciones
- **MercadoPago SDK** - Procesamiento de pagos y suscripciones

### Documentación y Testing
- **OpenAPI 2.7** - Especificación estándar de APIs
- **Swagger UI** - Interfaz interactiva de documentación
- **JUnit 5** - Framework de testing unitario
- **Mockito** - Mocking para tests
- **QuickPerf** - Análisis de performance
- **JaCoCo** - Cobertura de código
- **End-to-End Tests** - Tests de integración completos

### Resilencia y Monitoring
- **Resilience4j** - Circuit Breaker, Rate Limiter, Bulkhead
- **Spring Actuator** - Health checks y métricas
- **Logback** - Sistema de logging configurable
- **Micrometer** - Métricas de aplicación

### DevOps y Deployment
- **Docker** - Contenerización de la aplicación
- **Nginx** - Proxy inverso y load balancer
- **Spotless** - Formateo automático de código
- **Maven Enforcer** - Validación de dependencias

---

## 🏢 Arquitectura del Sistema

### 🎯 Arquitectura de Capas (MVC + Service Layer)

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  🌐 REST Controllers    📑 DTOs    📋 Resources    🔒 Security │
│     AuthController    TransactionDTO   AuthResource  JwtFilter │
│   ProfileController   CategoryDTO    ProfileResource  CORS     │
│ SubscriptionController  BudgetDTO   NotificationResource       │
├─────────────────────────────────────────────────────────────┤
│                      SERVICE LAYER                          │
│  💼 Business Services    🔄 External Services    📧 Email     │
│   TransactionService     BancolombiaService     SendGrid     │
│    CategoryService       MercadoPagoService     Templates    │
│     BudgetService        CloudinaryService      Notifications │
│      DebtService         ExchangeRateService    🔐 Security   │
├─────────────────────────────────────────────────────────────┤
│                   PERSISTENCE LAYER                         │
│  📊 Master DB (Write)    📑 Slave DB (Read)    🗃️ Repositories │
│    UserRepository        UserSlaveRepository    JPA/Hibernate │
│ TransactionRepository  TransactionSlaveRepository  HikariCP   │
│  CategoryRepository     CategorySlaveRepository   Connection   │
│   BudgetRepository      BudgetSlaveRepository      Pooling    │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                           │
│  🎨 Entities    📋 Enums    🔧 Utils    ⚙️ Configuration     │
│     User         Role      DateUtils    DatabaseConfig      │
│  Transaction   Status     SecurityUtils  SecurityConfig      │
│   Category    Currency   ValidationUtils  JwtConfig         │
│    Budget     Type       StringUtils     EmailConfig        │
│     Debt      State      JsonUtils      CloudinaryConfig    │
└─────────────────────────────────────────────────────────────┘
```

### 🔄 Flujo de Datos y Comunicación

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Client    │───▶│ Controller  │───▶│   Service   │───▶│ Repository  │
│             │    │             │    │             │    │             │
│ 🌐 Frontend │    │ 🎯 REST API │    │ 💼 Business │    │ 📊 Database │
│ 📱 Mobile   │    │ 🔒 Security │    │ 🔄 External │    │ 🗃️ Master   │
│ 🔧 Postman  │    │ 📋 Validation│    │ 📧 Email    │    │ 📑 Slave    │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Response  │◀───│   DTO       │◀───│   Entity    │◀───│   Query     │
│             │    │             │    │             │    │             │
│ 📄 JSON     │    │ 🔄 Mapping  │    │ 🎨 Domain   │    │ 📊 SQL      │
│ 🔒 Secured  │    │ ✅ Validated│    │ 💾 Persisted│    │ 🚀 Optimized│
│ 📊 Paginated│    │ 📋 Formatted│    │ 🔗 Relations│    │ 🔄 Replicated│
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### 📁 Estructura de Packages

```
src/main/java/org/kuenteco/backend/
├── 🎨 entity/                    # Entidades JPA
│   ├── User.java                # Entidad Usuario
│   ├── Transaction.java         # Entidad Transacción
│   ├── Category.java            # Entidad Categoría
│   ├── Budget.java              # Entidad Presupuesto
│   ├── Debt.java                # Entidad Deuda
│   └── Subscription.java        # Entidad Suscripción
├── 🏢 dto/                      # Data Transfer Objects
│   ├── auth/                    # DTOs de autenticación
│   ├── logic/                   # DTOs de lógica de negocio
│   ├── subscription/            # DTOs de suscripciones
│   └── notification/            # DTOs de notificaciones
├── 🔌 controller/               # Controladores REST
│   ├── auth/                    # Controladores de autenticación
│   ├── logic/                   # Controladores de lógica
│   ├── profile/                 # Controladores de perfil
│   └── subscription/            # Controladores de suscripciones
├── 🗃️ repository/               # Repositorios JPA
│   ├── master/                  # Repositorios de escritura
│   └── slave/                   # Repositorios de lectura
├── 🔧 service/                  # Servicios de negocio
│   ├── auth/                    # Servicios de autenticación
│   ├── logic/                   # Servicios de lógica
│   └── external/                # Servicios externos
├── 🛡️ security/                 # Configuración de seguridad
│   ├── jwt/                     # JWT Token handling
│   └── filter/                  # Filtros de seguridad
├── 📧 email/                    # Servicios de email
├── 🖼️ cloudinary/              # Servicios de Cloudinary
├── 🔄 job/                      # Trabajos programados
└── ⚙️ config/                   # Configuraciones
    ├── database/                # Configuración de BD
    ├── security/                # Configuración de seguridad
    └── external/                # Configuración de servicios externos
```

---

## 🚀 Configuración del Entorno

### 📋 Requisitos Previos

- **Java 21+** (OpenJDK o Oracle JDK)
- **Maven 3.8+** para gestión de dependencias
- **PostgreSQL 15+** (puede usar Docker)
- **IDE recomendado**: IntelliJ IDEA o VS Code
- **Docker** (opcional, para base de datos)
- **Git** para control de versiones

---

## 📦 Instalación y Configuración

### 1️⃣ Clonar el Repositorio

```bash
git clone https://github.com/AlthosKal/KuenteCO.git
cd KuenteCO/BACK-END/KuentecoApp
```

### 2️⃣ Verificar Herramientas

```bash
# Verificar Java
java -version
# Debe mostrar: openjdk version "21.x.x" o superior

# Verificar Maven
mvn -version
# Debe mostrar: Apache Maven 3.8.x o superior

# Verificar Docker (opcional)
docker --version
```

### 3️⃣ Configurar Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto KuentecoApp:

```bash
# 📧 Configuración de SendGrid
SENDGRID_API_KEY=SG.your_sendgrid_api_key_here
EMAIL_SENDGRID=noreply@yourdomain.com
VERIFICATION_EMAIL=d-1234567890abcdef  # Template ID verificación
RESET_PASSWORD=d-0987654321fedcba   # Template ID reset password

# 🖼️ Configuración de Cloudinary
CLOUDINARY_NAME=your_cloud_name
CLOUDINARY_API_KEY=123456789012345
CLOUDINARY_API_SECRET=your_cloudinary_secret

# 🔐 JWT Security
JWT_SECRET=your_super_secret_jwt_key_minimum_32_characters_long

# 📊 Base de Datos Master (Escritura)
SPRING_DATASOURCE_URL_MASTER=jdbc:postgresql://localhost:5432/KuenteCO
SPRING_DATASOURCE_USERNAME_MASTER=master
SPRING_DATASOURCE_PASSWORD_MASTER=secure_password

# 📑 Base de Datos Slave (Lectura)
SPRING_DATASOURCE_URL_SLAVE=jdbc:postgresql://localhost:5433/KuenteCO
SPRING_DATASOURCE_USERNAME_SLAVE=replicator
SPRING_DATASOURCE_PASSWORD_SLAVE=secure_password

# 🏦 Bancolombia API
BANCOLOMBIA_BASE_URL=https://api.bancolombia.com
BANCOLOMBIA_CLIENT_ID=your_bancolombia_client_id
BANCOLOMBIA_CLIENT_SECRET=your_bancolombia_client_secret

# 💳 MercadoPago
MERCADOPAGO_ACCESS_TOKEN=your_mp_access_token
MERCADOPAGO_PUBLIC_KEY=your_mp_public_key
```

### 4️⃣ Preparar Base de Datos

#### Opción A: Usar Docker (Recomendado)
```bash
# Desde la raíz del proyecto KuenteCO
cd ../../../KuenteCO/Database
docker compose up -d

# Verificar que las bases estén funcionando
docker compose ps
```

#### Opción B: PostgreSQL Local
```bash
# Conectarse a PostgreSQL
psql -U postgres

# Crear base de datos
CREATE DATABASE "KuenteCO";

# Crear usuario master
CREATE USER master WITH ENCRYPTED PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE "KuenteCO" TO master;
```

### 5️⃣ Instalar Dependencias

```bash
# Limpiar y compilar
mvn clean compile

# Instalar dependencias
mvn dependency:resolve

# Ejecutar tests (opcional)
mvn test
```

### 6️⃣ Ejecutar la Aplicación

```bash
# Modo desarrollo (recomendado)
mvn spring-boot:run

# O usando el wrapper
./mvnw spring-boot:run

# Modo producción
mvn clean package
java -jar target/KuentecoApp-0.0.1-SNAPSHOT.jar
```

### 7️⃣ Configuración Inicial de Datos

Una vez que la aplicación esté ejecutándose, insertar roles iniciales:

```sql
-- Conectarse a la base de datos
psql -U master -d KuenteCO

-- Insertar roles por defecto
INSERT INTO role (id, name) VALUES 
(0, 'ROLE_USER'), 
(1, 'ROLE_ADMIN')
ON CONFLICT (id) DO NOTHING;

-- Verificar inserción
SELECT * FROM role;
```

### 8️⃣ Verificar Instalación

```bash
# Health Check
curl http://localhost:8080/actuator/health

# Documentación API
open http://localhost:8080/swagger-ui.html

# Información de la aplicación
curl http://localhost:8080/actuator/info
```

---

## 📑 API REST Endpoints

### 📚 Documentación Interactiva

Todas las rutas están documentadas automáticamente con **OpenAPI 3.0**:

- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **OpenAPI JSON**: http://localhost:8080/v3/api-docs
- **OpenAPI YAML**: http://localhost:8080/v3/api-docs.yaml

### 🔐 Endpoints de Autenticación

| Método | Endpoint | Descripción | Auth Required |
|--------|----------|-------------|---------------|
| `POST` | `/api/auth/register` | Registro de nuevos usuarios | ❌ |
| `POST` | `/api/auth/login` | Inicio de sesión | ❌ |
| `POST` | `/api/auth/logout` | Cerrar sesión | ✅ |
| `POST` | `/api/auth/refresh` | Renovar token JWT | ✅ |
| `POST` | `/api/auth/forgot-password` | Solicitar reset de contraseña | ❌ |
| `POST` | `/api/auth/reset-password` | Confirmar nuevo password | ❌ |
| `GET` | `/api/auth/verify-email/{token}` | Verificar email | ❌ |

### 👥 Endpoints de Usuarios

| Método | Endpoint | Descripción | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/users/profile` | Obtener perfil del usuario | ✅ |
| `PUT` | `/api/users/profile` | Actualizar perfil | ✅ |
| `POST` | `/api/users/avatar` | Subir foto de perfil | ✅ |
| `DELETE` | `/api/users/account` | Eliminar cuenta | ✅ |
| `GET` | `/api/users/preferences` | Obtener preferencias | ✅ |
| `PUT` | `/api/users/preferences` | Actualizar preferencias | ✅ |

### 💰 Endpoints de Transacciones

| Método | Endpoint | Descripción | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/transactions` | Listar transacciones (paginado) | ✅ |
| `POST` | `/api/transactions` | Crear nueva transacción | ✅ |
| `GET` | `/api/transactions/{id}` | Obtener transacción por ID | ✅ |
| `PUT` | `/api/transactions/{id}` | Actualizar transacción | ✅ |
| `DELETE` | `/api/transactions/{id}` | Eliminar transacción | ✅ |
| `GET` | `/api/transactions/bancolombia` | Obtener transacciones de Bancolombia | ✅ |
| `GET` | `/api/transactions/export` | Exportar a Excel/PDF | ✅ |
| `POST` | `/api/transactions/import` | Importar desde archivo | ✅ |

### 📄 Endpoints de Categorías

| Método | Endpoint | Descripción | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/categories` | Listar categorías | ✅ |
| `POST` | `/api/categories` | Crear categoría | ✅ |
| `PUT` | `/api/categories/{id}` | Actualizar categoría | ✅ |
| `DELETE` | `/api/categories/{id}` | Eliminar categoría | ✅ |

### 💳 Endpoints de Suscripciones

| Método | Endpoint | Descripción | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/subscriptions` | Listar suscripciones | ✅ |
| `POST` | `/api/subscriptions` | Crear suscripción | ✅ |
| `PUT` | `/api/subscriptions/{id}` | Actualizar suscripción | ✅ |
| `DELETE` | `/api/subscriptions/{id}` | Cancelar suscripción | ✅ |

### 💰 Endpoints de Presupuestos

| Método | Endpoint | Descripción | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/budgets` | Listar presupuestos | ✅ |
| `POST` | `/api/budgets` | Crear presupuesto | ✅ |
| `PUT` | `/api/budgets/{id}` | Actualizar presupuesto | ✅ |
| `DELETE` | `/api/budgets/{id}` | Eliminar presupuesto | ✅ |

### 📊 Endpoints de Deudas

| Método | Endpoint | Descripción | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/debts` | Listar deudas | ✅ |
| `POST` | `/api/debts` | Crear deuda | ✅ |
| `PUT` | `/api/debts/{id}` | Actualizar deuda | ✅ |
| `DELETE` | `/api/debts/{id}` | Eliminar deuda | ✅ |

### 🔄 Endpoints de Tasas de Cambio

| Método | Endpoint | Descripción | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/exchange-rates` | Obtener tasas actuales | ✅ |
| `GET` | `/api/exchange-rates/history` | Historial de tasas | ✅ |

### 📊 Endpoints de Reportes

| Método | Endpoint | Descripción | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/reports/summary` | Resumen financiero | ✅ |
| `GET` | `/api/reports/monthly` | Reporte mensual | ✅ |
| `GET` | `/api/reports/yearly` | Reporte anual | ✅ |
| `GET` | `/api/reports/categories` | Análisis por categorías | ✅ |
| `GET` | `/api/reports/trends` | Tendencias financieras | ✅ |

### 📬 Endpoints de Notificaciones

| Método | Endpoint | Descripción | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/api/notifications` | Listar notificaciones | ✅ |
| `POST` | `/api/notifications` | Crear notificación | ✅ |
| `PUT` | `/api/notifications/{id}/read` | Marcar como leída | ✅ |
| `DELETE` | `/api/notifications/{id}` | Eliminar notificación | ✅ |

### 🔧 Endpoints de Administración

| Método | Endpoint | Descripción | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/actuator/health` | Estado de la aplicación | ❌ |
| `GET` | `/actuator/info` | Información de la app | ❌ |
| `GET` | `/actuator/metrics` | Métricas del sistema | 🔒 Admin |
| `GET` | `/actuator/loggers` | Configuración de logs | 🔒 Admin |

---

## 🆕 Cambios Recientes

### Versión Actual (2025-01-09)
- ✅ **Integración con Bancolombia API** - Sincronización automática de transacciones
- ✅ **Mejoras en MercadoPago** - Soporte completo para suscripciones
- ✅ **Configuración Multi-Base** - Implementación Master-Slave optimizada
- ✅ **Jobs programados** - Mantenimiento automático de tokens
- ✅ **Tests End-to-End** - Cobertura completa de casos de uso
- ✅ **Migraciones Flyway** - Versionado de esquema con triggers y funciones
- ✅ **Optimización de Performance** - Configuración avanzada de HikariCP
- ✅ **Logging mejorado** - Sistema de logs estructurado con Logback

### Próximas Funcionalidades
- 🚧 **Dashboard Analytics** - Visualización avanzada de métricas
- 🚧 **Notificaciones Push** - Integración con Firebase
- 🚧 **API Mobile** - Endpoints optimizados para apps móviles
- 🚧 **Reportes PDF** - Generación automática de reportes
- 🚧 **Backup automático** - Respaldo programado de datos

---

## 🏗️ Arquitectura Específica

### 🔄 Replicación Master-Slave
La aplicación implementa un patrón de replicación para optimizar el rendimiento:

```yaml
# Configuración Master (Escritura)
spring:
  datasource:
    master:
      url: jdbc:postgresql://localhost:5432/KuenteCO
      username: master
      password: secure_password
      
# Configuración Slave (Lectura)
  datasource:
    slave:
      url: jdbc:postgresql://localhost:5433/KuenteCO
      username: replicator
      password: secure_password
```

### 🔐 Seguridad JWT
Implementación de autenticación stateless con JWT:

```java
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    // Filtro personalizado para validación de tokens
    // Integración con Spring Security
}
```

### 🏦 Integración Bancolombia
Conexión segura con la API de Bancolombia para sincronización de transacciones:

```java
@Service
public class BancolombiaService {
    // Autenticación OAuth2
    // Sincronización automática de transacciones
    // Manejo de tokens con renovación automática
}
```

---

## 🧪 Testing y Calidad

### 🔍 Ejecutar Tests

```bash
# Tests unitarios
mvn test

# Tests con cobertura
mvn clean test jacoco:report

# Tests de integración
mvn test -Dtest="*IntegrationTest"

# Tests de performance
mvn test -Dtest="*PerformanceTest"

# Verificar calidad de código
mvn spotless:check

# Formatear código automáticamente
mvn spotless:apply
```

### 📊 Métricas de Calidad

- **Cobertura de código**: > 80% (objetivo: 90%)
- **Complejidad ciclomática**: < 10 por método
- **Líneas por método**: < 30
- **Acoplamiento**: Mínimo entre capas
- **Tests por feature**: Mínimo 3 (unit, integration, e2e)

### 📁 Reportes Generados

```bash
# Reporte de cobertura
open target/site/jacoco/index.html

# Reporte de SpotBugs
open target/spotbugsXml.xml

# Métricas de Maven
mvn dependency:analyze
```

---

## 👨‍💻 Desarrollo

### 🛠️ Configuración del IDE

#### IntelliJ IDEA (Recomendado)
```bash
# Plugins recomendados
- Lombok Plugin
- MapStruct Support
- OpenAPI (Swagger) Editor
- Docker
- Database Navigator
```

#### VS Code
```bash
# Extensiones recomendadas
- Extension Pack for Java
- Spring Boot Extension Pack
- Lombok Annotations Support
- REST Client
- Database Client
```

### 📊 Perfiles de Aplicación

```yaml
# Desarrollo
spring:
  profiles:
    active: dev,master,slave
    
# Producción
spring:
  profiles:
    active: prod,master,slave
```

### 📝 Variables de Entorno por Ambiente

```bash
# Desarrollo (.env.dev)
JWT_SECRET=dev_secret_key_for_development_only
SPRING_DATASOURCE_URL_MASTER=jdbc:postgresql://localhost:5432/KuenteCO_dev

# Producción (.env.prod)
JWT_SECRET=production_super_secure_secret_key
SPRING_DATASOURCE_URL_MASTER=jdbc:postgresql://prod-db:5432/KuenteCO
```

### 📊 Monitoreo en Desarrollo

```bash
# Activar debug de consultas SQL
logging:
  level:
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
    
# Actuator endpoints habilitados
management:
  endpoints:
    web:
      exposure:
        include: "health,info,metrics,loggers,env"
```

---

## 🚀 Deployment y Producción

### 🐳 Docker Build

```bash
# Construir imagen
docker build -t kuenteco-backend:latest .

# Ejecutar contenedor
docker run -p 8080:8080 \
  --env-file .env \
  kuenteco-backend:latest

# Push a Docker Hub
docker tag kuenteco-backend:latest your-registry/kuenteco-backend:v1.0.0
docker push your-registry/kuenteco-backend:v1.0.0
```

### 🏗️ Build de Producción

```bash
# Compilar para producción
mvn clean package -Pprod

# Generar JAR optimizado
mvn clean package -DskipTests

# Ejecutar JAR
java -jar -Dspring.profiles.active=prod target/KuentecoApp-0.0.1-SNAPSHOT.jar
```

### 🌐 Configuración DMZ con Nginx

Para **producción**, configurar Nginx como proxy inverso:

```nginx
server {
    listen 80;
    server_name api.kuenteco.com;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
    }
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;
}
```

---

## 🛠️ Debugging y Monitoring

### 🔍 Logs y Debugging

```bash
# Ver logs en tiempo real
tail -f logs/application.log

# Debugging remoto
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 \
     -jar target/KuentecoApp-0.0.1-SNAPSHOT.jar

# Profiling con JProfiler
java -javaagent:jprofiler/bin/agent.jar -jar target/KuentecoApp-0.0.1-SNAPSHOT.jar
```

### 📊 Monitoring y Métricas

```bash
# Health checks
curl http://localhost:8080/actuator/health

# Métricas de JVM
curl http://localhost:8080/actuator/metrics/jvm.memory.used

# Métricas de base de datos
curl http://localhost:8080/actuator/metrics/hikaricp.connections.active

# Métricas HTTP
curl http://localhost:8080/actuator/metrics/http.server.requests
```

---

## 📄 Mejores Prácticas

### 🎨 Código Limpio
- ✅ Seguir principios SOLID
- ✅ Nomenclatura descriptiva en inglés
- ✅ Métodos pequeños (< 30 líneas)
- ✅ Clases cohesivas y bajo acoplamiento
- ✅ Documentación con JavaDoc

### 🛡️ Seguridad
- ✅ Validación de inputs en todos los endpoints
- ✅ Sanitización de datos de salida
- ✅ Rate limiting por IP
- ✅ HTTPS en producción
- ✅ Secrets en variables de entorno

### 📊 Performance
- ✅ Cache de consultas frecuentes
- ✅ Paginación en listados
- ✅ Índices de base de datos optimizados
- ✅ Pool de conexiones configurado
- ✅ Compression de respuestas
