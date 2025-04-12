<p align="left">
  <img src="https://www.postgresql.org/media/img/about/press/elephant.png" alt="Logo de KuenteCO" height="30%" width="10%">
</p>

# Bases de Datos con PostgreSQL utilizando Docker
> [!NOTE]
> Las bases de datos de este proyecto se encuentran publicadas en Docker Hub:  
> 👉 [MasterKuenteCO](https://hub.docker.com/repository/docker/yefff/image-master-kuenteco/general)  
> 👉 [SlaveKuenteCO](https://hub.docker.com/repository/docker/yefff/image-slave-kuenteco/general)

Este repositorio contiene una guía detallada sobre cómo construir y configurar las bases de datos del sistema **KuenteCO** utilizando **PostgreSQL**, contenedores **Docker** y un archivo `compose.yaml`, incluyendo la configuración de replicación entre nodos maestro y esclavo.

Basado en:  
🔗 [Kinsta - Replicación en PostgreSQL](https://kinsta.com/es/blog/postgresql-replicacion/)

---

## ✅ Requisitos Previos

- Tener instalado **Docker** y **Docker Compose**
- Editor de texto recomendado: **Visual Studio Code**, **Vim**, **Nano**
- Extensión de Docker en VS Code (opcional pero útil)
- Conocimientos básicos de terminal y SQL

---

## ⚙️ Creación de las bases de datos con Docker

### 1. Clonar el repositorio y entrar al directorio de la base de datos

```bash
git clone https://github.com/AlthosKal/KuenteCO.git
cd KuenteCO/DATABASE
```


### 2. Levantar los contenedores con Docker Compose

```bash
docker compose up -d
```

Esto iniciará los contenedores `MasterKuenteCO` y `SlaveKuenteCO` definidos en el archivo `compose.yaml`.

---

## 🔄 Configuración de la Replicación en PostgreSQL

### 1. Crear el usuario replicador en el nodo maestro

```bash
docker exec -it MasterKuenteCO psql -U admin -d KuenteCO
```

```sql
CREATE USER replicator REPLICATION LOGIN ENCRYPTED PASSWORD 'example_password';
```

### 2. Modificar archivos de configuración en el nodo maestro

```bash
docker exec -it MasterKuenteCO bash
cd /var/lib/postgresql/data/
```

Reemplaza los archivos `postgresql.conf` y `pg_hba.conf` con los que están en este repositorio.

> 💡 También puedes usar `docker cp` para copiar directamente desde el host al contenedor:

```bash
docker cp ./config/postgresql.conf MasterKuenteCO:/var/lib/postgresql/data/postgresql.conf
docker cp ./config/pg_hba.conf MasterKuenteCO:/var/lib/postgresql/data/pg_hba.conf
```

Luego reinicia el contenedor maestro:

```bash
docker restart MasterKuenteCO
```

### 3. Configurar el nodo esclavo

```bash
docker exec -it SlaveKuenteCO bash
```
Primero elimina los archivos de configuración existentes
```bash
rm -rf /var/lib/postgresql/data/*
```

E inmediatamente ejecuta el siguiente comando para hacer la réplica "cuando lo ejecutes, te pedirá una contraseña, es la que le brindaste al usuario replicator":

```bash
pg_basebackup -D /var/lib/postgresql/data \
  -h MasterKuenteCO -p 5432 \
  -X stream -c fast \
  -U replicator -W -R
```

---

## 🗃️ Scripts SQL: Tablas y Relaciones

En la carpeta `/db` encontrarás los archivos `.sql` necesarios para crear por ejemplo los triggers y funciones de la base de datos.
---

## 🧠 Observaciones y Solución de Problemas

Verifica los logs en caso de errores o comportamientos inesperados:

```bash
docker logs MasterKuenteCO
docker logs SlaveKuenteCO
```

También puedes detener los contenedores y reconstruir el entorno si es necesario:

```bash
docker compose down
docker compose up -d --build
```

Claro, increíble Yeferson 🔥  
Aquí tienes un fragmento adicional para el `README.md` de la carpeta `DATABASE` que explica la instalación y configuración de las extensiones `pg_http` y `pg_cron`, así como el uso de una función SQL que realiza solicitudes HTTP a la API de OpenExchangeRate:

---


## 🌐 Integración con OpenExchangeRate: `pg_http` y `pg_cron`

Para que el sistema KuenteCO pueda obtener automáticamente tasas de cambio desde la API de **OpenExchangeRate**, se realiza una integración directa desde PostgreSQL utilizando las extensiones `pg_http` y `pg_cron`. Este proceso solo se configura en el contenedor de la base de datos **maestra**.

---

### 📦 Instalación de extensiones en la base de datos maestra

1. Accede al contenedor:

```bash
docker exec -it MasterKuenteCO bash
```

2. Instala las extensiones necesarias (si no están ya incluidas en la imagen base):

```bash
apt update
apt install -y postgresql-server-dev-15 make gcc git
git clone https://github.com/pramsey/pgsql-http.git
cd pgsql-http
make
make install
```

```bash
git clone https://github.com/citusdata/pg_cron.git
cd pg_cron
make
make install
```
3. Dentro del archivo de configuración de postgresql.conf descomentar las lineas:
```conf
768 #shared_preload_libraries = 'pg_cron'		# (change requires restart)
845 #cron.database_name = 'KuenteCO'
```
3. Ahora reinicia el contenedor para cargar las extensiones instaladas:

```bash
exit
docker restart MasterKuenteCO
```

---

### 🧩 Habilitación de las extensiones en la base de datos `KuenteCO`

Dentro del contenedor, ejecuta:

```bash
docker exec -it MasterKuenteCO psql -U admin -d KuenteCO
```

```sql
CREATE EXTENSION IF NOT EXISTS http;
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

---

### ⚙️ Función programada para actualizar tasas de cambio

En la carpeta `/db/` del repositorio encontrarás el archivo:

```
DatabaseFunctionsKuenteCO.sql
```

Este script contiene la habilitación de las extensiones en la base de datos y una función SQL llamada `update_exchange_rates()` que utiliza `pg_http` para consultar la API de **OpenExchangeRate**, parsear la respuesta JSON y almacenar la tasa de cambio actual en una tabla interna.

También contiene la programación automática con `pg_cron` para ejecutar esta función cada **2 horas**, asegurando que la información esté siempre actualizada para el sistema KuenteCO.

---

### 📥 Ejecución del script

Para cargar la función en tu base de datos:

```bash
docker cp ./db/DatabaseFunctionsKuenteCO.sql MasterKuenteCO:/db/
docker exec -it MasterKuenteCO psql -U admin -d KuenteCO -f /db/DatabaseFunctionsKuenteCO.sql
```

---

> 🧠 **Nota**: Recuerda asegurarte de tener tu API Key de OpenExchangeRate en la función o una tabla de configuración para evitar errores de autenticación.
