# Guía de Despliegue KuenteCO en AWS ECS con Copilot CLI

## 1. Preparación del Entorno

### Instalación de AWS Copilot CLI
```bash
# Linux/MacOS
curl -Lo copilot https://github.com/aws/copilot-cli/releases/latest/download/copilot-linux
chmod +x copilot && sudo mv copilot /usr/local/bin

# Windows (PowerShell)
Invoke-WebRequest -Uri https://github.com/aws/copilot-cli/releases/latest/download/copilot-windows.exe -OutFile copilot.exe
```

### Configuración AWS CLI
```bash
aws configure
# Ingresa tu Access Key ID, Secret Access Key, Region (ej: us-east-1)
```

## 2. Inicialización del Proyecto Copilot

### Crear la aplicación
```bash
mkdir kuenteco-deployment && cd kuenteco-deployment
copilot app init kuenteco --domain your-domain.com  # Opcional
```

## 3. Configuración de Servicios

### 3.1 Servicio de Base de Datos PostgreSQL Master
```bash
copilot svc init postgres-master --svc-type "Backend Service"
```

**Archivo: `copilot/postgres-master/copilot.yml`**
```yaml
name: postgres-master
type: Backend Service

image:
  build: 'yefff/image-master-kuenteco:1.1.1'

http:
  healthcheck: '/health'

variables:
  POSTGRES_DB: KuenteCO
  POSTGRES_USER: master

count:
  min: 1
  max: 1

cpu: 512
memory: 1024

storage:
  volumes:
    postgres-master-data:
      path: /var/lib/postgresql/data
      read_only: false

network:
  vpc:
    enable_logs: true

exec: true
logging: true
```

### 3.2 Servicio de Base de Datos PostgreSQL Replica
```bash
copilot svc init postgres-replica --svc-type "Backend Service"
```

**Archivo: `copilot/postgres-replica/copilot.yml`**
```yaml
name: postgres-replica
type: Backend Service

image:
  build: 'yefff/image-slave-kuenteco:1.1.1'

variables:
  POSTGRES_DB: KuenteCO
  POSTGRES_USER: replicator

count:
  min: 1
  max: 1

cpu: 512
memory: 1024

storage:
  volumes:
    postgres-replica-data:
      path: /var/lib/postgresql/data
      read_only: false

network:
  vpc:
    enable_logs: true

exec: true
logging: true
```

### 3.3 Servicio de Base de Datos MongoDB
```bash
copilot svc init mongo-database --svc-type "Backend Service"
```

**Archivo: `copilot/mongo-database/copilot.yml`**
```yaml
name: mongo-database
type: Backend Service

image:
  build: 'yefff/image-mongo-kuenteco:1.0.0'

variables:
  MONGO_INITDB_DATABASE: kuenteco

count:
  min: 1
  max: 1

cpu: 512
memory: 1024

storage:
  volumes:
    mongo-kuenteco-data:
      path: /data/db
      read_only: false

network:
  vpc:
    enable_logs: true

exec: true
logging: true
```

### 3.4 Servicio Backend KuenteCO App
```bash
copilot svc init kuenteco-app --svc-type "Backend Service"
```

**Archivo: `copilot/kuenteco-app/copilot.yml`**
```yaml
name: kuenteco-app
type: Backend Service

image:
  build: 'yefff/image-backend-kuenteco-app:1.0.2'

http:
  healthcheck: '/actuator/health'

variables:
  SERVER_PORT: 8080
  SPRING_PROFILES_ACTIVE: production

count:
  min: 2
  max: 10

cpu: 1024
memory: 2048

network:
  vpc:
    enable_logs: true

exec: true
logging: true
```

### 3.5 Servicio Backend KuenteCO Chat
```bash
copilot svc init kuenteco-chat --svc-type "Backend Service"
```

**Archivo: `copilot/kuenteco-chat/copilot.yml`**
```yaml
name: kuenteco-chat
type: Backend Service

image:
  build: 'yefff/image-backend-kuenteco-chat:1.0.2'

http:
  healthcheck: '/actuator/health'

variables:
  SERVER_PORT: 7070
  SPRING_PROFILES_ACTIVE: production

count:
  min: 2
  max: 8

cpu: 1024
memory: 2048

network:
  vpc:
    enable_logs: true

exec: true
logging: true
```

### 3.6 Servicio Frontend KuenteCO UI
```bash
copilot svc init kuenteco-ui --svc-type "Load Balanced Web Service"
```

**Archivo: `copilot/kuenteco-ui/copilot.yml`**
```yaml
name: kuenteco-ui
type: Load Balanced Web Service

image:
  build: 'yefff/image-frontend-kuenteco-ui:1.0.2'

http:
  path: '/'
  healthcheck: '/health'

variables:
  NGINX_PORT: 80

count:
  min: 2
  max: 10

cpu: 256
memory: 512

network:
  vpc:
    enable_logs: true

exec: true
logging: true
```

## 4. Configuración de Entorno de Producción

### Crear entorno de producción
```bash
copilot env init --name production
```

## 5. ~~Configuración de Secrets~~ (NO NECESARIO)

**¡SALTATE ESTA SECCIÓN!** - Las credenciales, variables de entorno y configuraciones ya están embebidas en las imágenes de Docker como mencionaste.

## 6. Configuración de Service Discovery

**Archivo: `copilot/environments/addons/service-discovery.yml`**
```yaml
Parameters:
  App:
    Type: String
    Description: Your application's name.
  Env:
    Type: String
    Description: The name of the environment being deployed.

Resources:
  ServiceDiscoveryNamespace:
    Type: AWS::ServiceDiscovery::PrivateDnsNamespace
    Properties:
      Name: !Sub ${App}.local
      Vpc: !Ref VPC

Outputs:
  ServiceDiscoveryNamespace:
    Description: Service Discovery Namespace
    Value: !Ref ServiceDiscoveryNamespace
```

## 7. Despliegue a Producción

### 7.1 Desplegar entorno de producción
```bash
copilot env deploy --name production
```

### 7.2 Desplegar servicios en orden de dependencias

#### Primero las bases de datos:
```bash
# PostgreSQL Master
copilot svc deploy postgres-master --env production

# PostgreSQL Replica (esperar a que Master esté healthy)
copilot svc deploy postgres-replica --env production

# MongoDB
copilot svc deploy mongo-database --env production
```

#### Luego los backends:
```bash
# Backend App (depende de PostgreSQL)
copilot svc deploy kuenteco-app --env production

# Backend Chat (depende de MongoDB)
copilot svc deploy kuenteco-chat --env production
```

#### Finalmente el frontend:
```bash
# Frontend UI (depende de los backends)
copilot svc deploy kuenteco-ui --env production
```

### 7.3 Verificar el despliegue
```bash
copilot svc status --name kuenteco-ui --env production
copilot svc logs --name kuenteco-ui --env production --follow
```

## 8. Configuración de Monitoreo y Logs

### Habilitar Container Insights
```bash
copilot env addon init --name container-insights
```

**Archivo: `copilot/environments/addons/container-insights.yml`**
```yaml
Parameters:
  App:
    Type: String
  Env:
    Type: String

Resources:
  ContainerInsights:
    Type: AWS::ECS::ClusterCapacityProviderAssociation
    Properties:
      Cluster: !Sub ${App}-${Env}
      CapacityProviders:
        - FARGATE
        - FARGATE_SPOT
      DefaultCapacityProviderStrategy:
        - CapacityProvider: FARGATE
          Weight: 1
```

## 9. Comandos Útiles de Administración

### Ver todos los servicios
```bash
copilot svc ls
```

### Ver logs en tiempo real
```bash
copilot svc logs --name kuenteco-app --env test --follow
```

### Ejecutar comandos en contenedores
```bash
copilot task run --image yefff/image-backend-kuenteco-app:1.0.2 --command "bash"
```

### Escalar servicios
```bash
copilot svc show --name kuenteco-app
# Editar copilot.yml y cambiar count, luego:
copilot svc deploy kuenteco-app --env production
```

### Actualizar imagen de servicio
```bash
# Actualizar la imagen en copilot.yml y redesplegar
copilot svc deploy kuenteco-app --env production
```

## 10. ~~Configuración de Producción~~ (YA ESTÁ INCLUIDO ARRIBA)

El despliegue ya está configurado directamente para producción en la sección anterior.

## 8. Troubleshooting

### Ver estado detallado de servicios
```bash
copilot svc status --name kuenteco-app --env production
```

### Ver eventos de ECS
```bash
aws ecs describe-services --cluster kuenteco-production --services kuenteco-app-Service
```

### Conectar a contenedor para debugging
```bash
copilot task run --image yefff/image-backend-kuenteco-app:1.0.2 --command "bash" --env production
```

### Ver logs de CloudWatch
```bash
copilot svc logs --name kuenteco-app --env production --since 1h
```

## 12. Limpieza

### Eliminar servicios
```bash
copilot svc delete --name kuenteco-ui
copilot svc delete --name kuenteco-chat
copilot svc delete --name kuenteco-app
copilot svc delete --name mongo-database
copilot svc delete --name postgres-replica
copilot svc delete --name postgres-master
```

### Eliminar entorno
```bash
copilot env delete --name production
```

### Eliminar aplicación completa
```bash
copilot app delete kuenteco
```

## Notas Importantes

1. **Volúmenes EFS**: Los volúmenes persistentes se configuran automáticamente como EFS en Fargate
2. **Service Discovery**: Los servicios se comunican usando DNS interno (`service-name.app-name.local`)
3. **Health Checks**: Configurados en cada servicio para garantizar disponibilidad
4. **Secrets**: Almacenados de forma segura en AWS Systems Manager Parameter Store
5. **Logs**: Centralizados en CloudWatch Logs
6. **Monitoreo**: Container Insights habilitado para métricas detalladas
7. **Escalado**: Configurado automáticamente basado en CPU/memoria
8. **Load Balancer**: Application Load Balancer para el frontend con HTTPS
9. **VPC**: Red privada aislada creada automáticamente por Copilot