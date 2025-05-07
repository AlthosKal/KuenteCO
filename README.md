# KuenteCO

<p align="center">
  <img src="https://cdn.mcauto-images-production.sendgrid.net/6357b2503ba86bb8/276fd986-07c9-432b-a32a-ce059eae9a40/589x162.png" alt="Logo de KuenteCO" height="30%" width="50%">
</p>

## 📘 Introducción

**KuenteCO** es un sistema integral de gestión financiera orientado tanto a usuarios particulares como a pequeños y medianos negocios. Esta aplicación web está diseñada para facilitar el registro, seguimiento, análisis y planificación de las finanzas personales y empresariales, todo desde cualquier dispositivo con acceso a Internet.

Este repositorio contiene el código fuente completo de KuenteCO, organizado en tres componentes principales: **FRONT-END**, **BACK-END** y **Database**, cada uno estructurado con su propia documentación técnica para una implementación clara y ordenada.

---

## 🌐 Descripción General del Sistema

KuenteCO permite:

- Registrar ingresos y egresos de manera intuitiva.
- Establecer y monitorear presupuestos personalizados.
- Definir metas de ahorro y realizar su seguimiento.
- Generar informes financieros visuales e interpretables.
- Gestionar múltiples cuentas para diferentes actividades.
- Automatizar la importación de transacciones desde cuentas bancarias.
- Tener control total de las finanzas, optimizando la toma de decisiones.

### Tecnologías Utilizadas

- **Flutter** – Para la construcción del front-end multiplataforma.
- **Spring Boot** – Como framework de desarrollo del back-end.
- **PostgreSQL** – Base de datos relacional utilizada para almacenar toda la información.
- **Docker** – Contenerización de los servicios para facilitar el despliegue en entornos de desarrollo y producción. (actualmente solo aplicado para las bases de datos).
- **Nginx** – Utilizado como servidor proxy inverso en la capa DMZ, mejorando la seguridad, el rendimiento y la disponibilidad de la aplicación.

---

## 🛡️ Seguridad y Arquitectura (DMZ)

KuenteCO implementa una arquitectura basada en una **Zona Desmilitarizada (DMZ)** para separar los servicios públicos del acceso directo a la base de datos y proteger los sistemas internos. Esta arquitectura utiliza:

- **Docker** para contenerizar cada componente (frontend, backend y base de datos), lo que facilita la gestión del entorno, escalabilidad y replicabilidad.
- **Nginx** como **proxy inverso**, sirviendo como punto de entrada a la aplicación desde Internet. Nginx se encarga de enrutar las peticiones hacia el frontend y backend, y puede actuar como capa de balanceo y seguridad frente a ataques comunes como DDoS.

---

## 🗂️ Estructura del Proyecto

El repositorio está dividido en tres carpetas principales:

---

### [📁 FRONT-END](./FRONT-END/README.md)

Contiene todo el código de la interfaz de usuario construida con Flutter. En su `README.md` encontrarás:

- Requisitos del entorno.
- Instrucciones para clonar y ejecutar la aplicación.
- Configuraciones necesarias para conectarse al backend.

### [📁 BACK-END](./BACK-END/README.md)

Incluye la API REST desarrollada con Spring Boot. Su `README.md` contiene:

- Configuración del entorno de desarrollo (JDK, Maven).
- Instrucciones para levantar la aplicación.
- Rutas de la API y estructura de controladores.
- Configuración de credenciales.

### [📁 Database](./Database/README.md)

Contiene los scripts necesarios para crear y poblar la base de datos en PostgreSQL. Su documentación cubre:

- Creación de las bases de datos de PosgreSQL con Docker.
- Configuración de la replicación de las bases de datos.
- Scripts SQL de creación de tablas y relaciones.

---

## ⚙️ Despliegue con Docker  

Este repositorio incluye un archivo `compose.yaml` que permite levantar todos los servicios de manera sencilla, 
para levantar este stack se debe contar con un `.env-docker` para las credenciales, la plantilla de como debe ser este es la siguiente:

```env
# API de SendGrid
SENDGRID_API_KEY=tu_api_key_de_sendgrid
EMAIL_SENDGRID=tu_correo_de_sendgrid_configurado_para_enviar_correos
VERIFICATION_EMAIL=id_de_tu_template_de_sengrid_para_verificar_correos
RESET_PASSWORD=d-id_de_tu_template_de_sengrid_para_cambiar_contraseñas

# API de Cloudinary
CLOUDINARY_NAME=tu_cloud_name
CLOUDINARY_API_KEY=tu_api_key_de_cloudinary
CLOUDINARY_API_SECRET=tu_api_secret_de_cloudinary

# Secret de JWT
JWT_SECRET=tu_jwt_secret

 # Conexion a la base de datos Maestra
SPRING_DATASOURCE_URL_MASTER=jdbc:postgresql://postgres-master-database:5432/KuenteCO
SPRING_DATASOURCE_USERNAME_MASTER=master
SPRING_DATASOURCE_PASSWORD_MASTER=root

# Conexion a la base de datos Esclava
SPRING_DATASOURCE_URL_SLAVE=jdbc:postgresql://postgres-replica-database:5432/KuenteCO
SPRING_DATASOURCE_USERNAME_SLAVE=replicator
SPRING_DATASOURCE_PASSWORD_SLAVE=root


```

Al ejecutar el siguiente comando, se levantará un stack de Docker:
```bash
docker compose --env-file .env-docker up -d
```

Esto desplegará:

- El frontend en un contenedor independiente.(proximamente)
- El backend con conexión a la base de datos.
- PostgreSQL con persistencia de datos.
- Nginx configurado como proxy inverso y capa de acceso segura.(proximamente)

---

## 🎯 Contexto del Sistema

KuenteCO actúa como una herramienta fundamental tanto para **usuarios individuales** como para **pequeños negocios**:

### Para Usuarios Particulares

- Registro detallado de ingresos y gastos.
- Visualización de metas económicas personales.
- Organización por categorías (renta, educación, alimentación, etc.).
- Informes personalizados para toma de decisiones informadas.

### Para Negocios

- Gestión centralizada de finanzas empresariales.
- Control de transacciones por múltiples cuentas.
- Reportes contables automáticos.
- Reducción de tareas manuales gracias a la automatización.

---

## 🛠️ Contribuciones

Las contribuciones son bienvenidas. Si deseas colaborar, por favor revisa los issues abiertos o abre uno nuevo. Asegúrate de seguir las buenas prácticas de desarrollo y, en lo posible, testear tus cambios.
