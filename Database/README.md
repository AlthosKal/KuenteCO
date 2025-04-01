# Bases de Datos con PostgreSQL utilizando Docker para el proyecto KuenteCO

## **Nota**
Las bases de datos de este proyecto se encuentran publicadas en docker hub,
Aquí estan sus links:
## [MasterKuenteCO](https://hub.docker.com/repository/docker/yefff/image-master-kuenteco/general "target=blank")

## [SlaveKuenteCO](https://hub.docker.com/repository/docker/yefff/image-slave-kuenteco/general "target=blank")

---

Este repositorio contiene una guía detallada de como se construyo la base de datos de **KuenteCO** con **PostgreSQL** utilizando **contenedores de Docker** y un archivo `compose.yaml`. El proceso descrito se basa en la información proporcionada en la siguiente página web: [Kinsta - Replicación en PostgreSQL](https://kinsta.com/es/blog/postgresql-replicacion/), pero adaptado para ejecutarse dentro de contenedores Docker.

---

## **Requisitos Previos**
- Docker y Docker Compose instalados en tu sistema.
- Un editor de texto como **Visual Studio Code** con la extensión de Docker (opcional, pero recomendado), Vim o Nano.

---

## **Proceso de Configuración**
### **1. Iniciar los Contenedores**
Se ejecutó el siguiente comando en la terminal para iniciar los contenedores definidos en el archivo `compose.yaml`:
```sh
docker compose up -d
```

### **2. Configuración del Nodo Maestro**
Se accedió al contenedor del nodo maestro y se creó el usuario de replicación con los siguientes comandos:
```sh
docker exec -it MasterKuenteCO psql -U admin -d KuenteCO
```
Ejecuta el siguiente comando SQL para crear el usuario de replicación:
```sql
CREATE USER replicator REPLICATION LOGIN ENCRYPTED PASSWORD 'example_password';
```

### **3. Modificación de Archivos de Configuración**
Se modificó los archivos de configuración de PostgreSQL en el nodo maestro:
1. Accediendo al contenedor del nodo maestro:
   ```sh
   docker exec -it MasterKuenteCO bash
   ```
2. Hasta al directorio de configuración:
   ```sh
   cd /var/lib/postgresql/data/
   ```
3. Se Reemplazó los archivos `postgresql.conf` y `pg_hba.conf` con los proporcionados en este repositorio.

**Nota:** Si se usa Visual Studio Code con la extensión de Docker, se puede editar estos archivos directamente sin necesidad de acceder manualmente al contenedor.

4. Se aplicó los cambios reiniciando el contenedor maestro:
   ```sh
   docker restart MasterKuenteCO
   ```

### **4. Configuración del Nodo Esclavo**
1. Se accedió al contenedor del nodo esclavo:
   ```sh
   docker exec -it SlaveKuenteCO bash
   ```
2. Elimina todos los archivos de configuración existentes:
   ```sh
   rm -rf /var/lib/postgresql/data/*
   ```
3. Ejecutando el siguiente comando para sincronizar la base de datos del esclavo con la del maestro:
   ```sh
   pg_basebackup -D /var/lib/postgresql/data \
     -h MasterKuenteCO -p 5432 \
     -X stream -c fast \
     -U replicator -W -R
   ```

---

## **Observaiones**
Si se necesita realizar ajustes adicionales o solucionar errores, se revisa los archivos de configuración y los registros del contenedor con:
```sh
docker logs MasterKuenteCO
```
o
```sh
docker logs SlaveKuenteCO
```

