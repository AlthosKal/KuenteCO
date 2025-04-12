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

> [!NOTE]  
> Próximamente


## ⚙️ Despliegue con Docker  

Este repositorio incluye un archivo `compose.yaml` que permite levantar todos los servicios de manera sencilla:

```bash
docker-compose up -d
```

Esto desplegará:

- El frontend en un contenedor independiente.
- El backend con conexión a la base de datos.
- PostgreSQL con persistencia de datos.
- Nginx configurado como proxy inverso y capa de acceso segura.

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
