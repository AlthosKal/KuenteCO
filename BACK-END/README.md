<p align="left">
  <img src="https://upload.wikimedia.org/wikipedia/commons/7/79/Spring_Boot.svg" alt="Logo de KuenteCO" height="30%" width="10%">
</p>

# BACK-END
Bienvenido al módulo **BACK-END** de **KuenteCO**, desarrollado con **Spring Boot** para proporcionar una API robusta, escalable y segura. Este componente centraliza toda la lógica de negocio, las rutas de la API, la autenticación, la validación de datos y la conexión segura con servicios externos como Cloudinary y SendGrid.

---

## ⚙️ Configuración del entorno de desarrollo

Antes de levantar el proyecto, asegúrate de contar con las siguientes herramientas instaladas:

- **Java Development Kit (JDK)** 17 o superior  
- **Apache Maven** 3.8+  
- **Nginx** (utilizado en la zona desmilitarizada – DMZ – para enrutar y proteger las solicitudes externas)

---

## 🚀 Instrucciones para levantar la aplicación

1. **Clona el repositorio:**

```bash
git clone https://github.com/AlthosKal/KuenteCO.git
cd KuenteCO/BACK-END
```



2. **Crea un archivo `.env` en la carpeta raiz del BACK-END para tus credenciales "aca se brindará un plantilla del .env":**

```bash
mkdir .env
```

3. **Ejecuta el proyecto con Maven "asegurate de tener las bases de datos encendidas" y el ORM  de Hibernate creará las tablas:**

```bash
./mvnw spring-boot:run
```

> [!NOTE]  
> También puedes usar Docker para levantar la app en conjunto con Nginx (ver documentación raíz del repositorio para más detalles).


4. **Una vez que se halla inicializado las bases de datos, se deben redirigir a la tabla de `role`, e insertar los siguientes valores**
```postgresql
INSERT INTO public.role(
	id, name)
	VALUES (0, ROLE_USER), (1, ROLE_ADMIN);
```

---

## 📑 Rutas de la API

La estructura de controladores está aplicando **Arquitectura de Capas** y está organizada siguiendo las buenas prácticas. Todas las rutas están documentadas automáticamente usando **OpenAPI (Swagger UI)**.

Accede a la documentación desde:  
```
http://localhost:8080/swagger-ui.html
```

**Estructura básica de rutas:**

- `POST /api/auth/register` – Registro de usuarios  
- `POST /api/auth/login` – Inicio de sesión  
- `GET /api/users/{id}` – Obtener información de usuario  
- `PUT /api/users/{id}` – Actualizar usuario  
- `POST /api/transactions` – Crear transacción  
- `GET /api/transactions` – Listar transacciones  
- ...y muchas más.

---

## 🔐 Configuración de credenciales

Para que el sistema funcione correctamente con los servicios externos y la seguridad, es necesario configurar el archivo `.env` con las siguientes variables:

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

# Conexión a la base de datos Maestra
SPRING_DATASOURCE_URL_MASTER=jdbc:postgresql://conexion_a_la_base_de_datos
SPRING_DATASOURCE_USERNAME_MASTER=usuario_master
SPRING_DATASOURCE_PASSWORD_MASTER=root

# Conexión a la base de datos Esclava
SPRING_DATASOURCE_URL_SLAVE=jdbc:postgresql://conexion_a_la_base_de_datos
SPRING_DATASOURCE_USERNAME_SLAVE=usuario_slave
SPRING_DATASOURCE_PASSWORD_SLAVE=root
```

> [!IMPORTANT]  
> Asegúrate de **no subir nunca tu archivo `.env` real al repositorio público**. Este contiene información sensible.
> **Para obtener credenciales como por ejemplo las de SenGrid y Cloudinary, es necesario dirigirse a estos servicios**
> **Para la generación de JWT_SECRET, si se tiene instalado Node.js, se puede ejecutar el siguiente comando en la terminal:**
> ```bash 
> node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"```
---

## 🌐 Seguridad y arquitectura en DMZ con Nginx

Para exponer la API de manera segura, se utiliza **Nginx como proxy inverso** en una zona desmilitarizada (**DMZ**), permitiendo:

- Control de tráfico hacia el back-end
- Redirección de puertos y rutas
- Certificados SSL (cuando se implemente en producción)
- Protección contra ataques de denegación de servicio y escaneo de endpoints
