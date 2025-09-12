# 🏦 Backend KuenteCO - Microservicios Financieros

> **Arquitectura de microservicios para gestión financiera personal y empresarial con IA integrada**

<p align="center">
  <img src="https://img.shields.io/badge/Spring%20Boot-3.5.0-green?style=flat-square&logo=spring-boot" alt="Spring Boot">
  <img src="https://img.shields.io/badge/Java-17+-orange?style=flat-square&logo=java" alt="Java">
  <img src="https://img.shields.io/badge/PostgreSQL-15+-blue?style=flat-square&logo=postgresql" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/MongoDB-blue?style=flat-square&logo=mongodb" alt="MongoDB">
  <img src="https://img.shields.io/badge/Docker-Ready-blue?style=flat-square&logo=docker" alt="Docker">
</p>

## 💭 Arquitectura de Microservicios

El backend de KuenteCO está compuesto por **dos microservicios especializados**:

### 🏦 **KuentecoApp** - Core Financiero
- **Puerto**: `:8080`
- **Base de Datos**: PostgreSQL (Master-Slave)
- **Función**: Gestión financiera completa, autenticación, transacciones

### 🤖 **KuentecoChat** - Asistente IA
- **Puerto**: `:7070` 
- **Base de Datos**: MongoDB
- **Función**: Inteligencia artificial, procesamiento de documentos, chat financiero

---

## 📋 Índice de Funcionalidades

### 🏦 **KuentecoApp (Core Financiero)**
- [🔐 Autenticación y Usuarios](#-endpoints-de-autenticación)
- [👤 Gestión de Perfiles](#-endpoints-de-perfiles)
- [📊 Categorías Financieras](#-endpoints-de-categorías)
- [💰 Transacciones](#-endpoints-de-transacciones)
- [💵 Presupuestos](#-endpoints-de-presupuestos)
- [💳 Deudas y Obligaciones](#-endpoints-de-deudas)
- [📄 Importación/Exportación Excel](#-endpoints-de-excel)
- [💱 Tipos de Cambio](#-endpoints-de-tipos-de-cambio)
- [🔔 Notificaciones](#-endpoints-de-notificaciones)
- [💳 Suscripciones y Pagos](#-endpoints-de-suscripciones)

### 🤖 **KuentecoChat (Asistente IA)**
- [💬 Chat con IA Financiera](#-endpoints-de-chat)
- [📜 Historial de Conversaciones](#-endpoints-de-historial-de-chat)
- [✨ Características Avanzadas de IA](#-características-especiales)

---

---

## 🔐 Endpoints de Autenticación


### `AuthController.java` - Gestión de usuarios y autenticación

> **Base URL:** `/api/app/v1/auth`

#### 1. 🔍 **GET** `/user/details`

**Descripción:** Obtiene los detalles del usuario autenticado  
**Autenticación:** ✅ Requerida  
**Response:** `UserDetailDTO` - Información completa del usuario  
**Status:** `200 OK` si todo está correcto, `401 UNAUTHORIZED` si no está autorizado y `500 INTERNAL SERVER ERROR` problemas en el servidor

#### 2. 🔑 **POST** `/login`

**Descripción:** Autentica a un usuario en el sistema  
**Body:** `LoginDTO` - Credenciales de usuario  
**Response:** `TokenResponseDTO` - Token JWT y información de sesión  
**Funcionalidad:** Genera token JWT y establece cookies de sesión  
**Status:** **Status:** `200 OK` Si es inicio de sesión exitoso
`400 BAD REQUEST` si los datos ingresados tienen un algun error y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 3. ✍️ **POST** `/register`

**Descripción:** Registra un nuevo usuario en el sistema  
**Body:** `NewUserDTO` - Información del nuevo usuario  
**Funcionalidad:**
- ✅ Crea la cuenta de usuario
- 📧 Envía código de verificación por email

**Status:** `201 CREATED` registro exitoso `400 BAD REQUEST` si los datos ingresados tienen un algun error o si ya hay un usuario existente con éstos y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 4. 📧 **POST** `/send-verification-code`

**Descripción:** Envía un código de verificación por email  
**Body:** `SendVerificationCodeDTO` - Email del usuario  
**Query Param:** `isRegistration` (boolean, default: false)  
**Funcionalidad:** Genera y envía código de 6 dígitos por email  
**Status:** `200 OK` envio de correo exitoso `400 BAD REQUEST` si los datos ingresados tienen un algun error y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 5. ✅ **POST** `/validate-verification-code`

**Descripción:** Valida un código de verificación sin activar la cuenta  
**Body:** `ValidateVerificationCodeDTO` - Email y código  
**Response:** Confirmación de validez del código  
**Status:** `200 OK` (válido) / `400 BAD REQUEST` (inválido) y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 6. 🎯 **POST** `/activate-user`

**Descripción:** Activa la cuenta de usuario después de validar el código  
**Body:** `ValidateVerificationCodeDTO` - Email y código  
**Funcionalidad:**
- ✅ Valida el código de verificación
- 🚀 Activa la cuenta del usuario

**Status:** `200 OK` (exitoso) / `400 BAD REQUEST` (código inválido) `500 INTERNAL SERVER ERROR` problemas en el servidor

#### 7. 🔒 **PATCH** `/change-password`

**Descripción:** Cambia la contraseña del usuario con verificación  
**Body:** `ChangePasswordDTO` - Email, código y nueva contraseña  
**Funcionalidad:** Actualiza la contraseña después de verificar el código  
**Status:** `201 CREATED` Se actualizo la contraseña correctamente `400 BAD REQUEST` si los datos ingresados tienen un algun error y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 8. 🚪 **POST** `/logout`

**Descripción:** Cierra la sesión del usuario autenticado  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- ❌ Invalida el token JWT
- 🧹 Limpia las cookies de sesión

**Status:** `204 NO CONTENT` Se cerro sesión correctamente
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 9. 🗑️ **DELETE**

**Descripción:** Elimina una cuenta de usuario por el email obtenido del usuarío autenticado  
**Funcionalidad:** Eliminación completa del usuario y sus datos  
**Status:** `204 NO CONTENT`se elimino el usuario correctamente `401 UNAUTHORIZED` si no está autorizado 
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 10. 📷 **POST** `/user/image/add`

**Descripción:** Sube una nueva imagen de perfil para el usuario  
**Body:** `MultipartFile` - Imagen  
**Autenticación:** ✅ Requerida  
**Response:** `ImageDTO` - Información de la imagen subida  
**Status:** `201 CREATED` Se agrego la imagen correctamente `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 11. 🔄 **PATCH** `/user/image/update`

**Descripción:** Actualiza la imagen de perfil existente del usuario  
**Body:** `MultipartFile` - Nueva imagen  
**Autenticación:** ✅ Requerida  
**Response:** `ImageDTO` - Información de la imagen actualizada  
**Status:** `200 OK` Se actualizo la imagen correctamente `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 12. 🗑️ **DELETE** `/delete`

**Descripción:** Elimina la imagen de perfil del usuario autenticado  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Elimina la imagen del CDN (Cloudinary) y de la base de datos  
**Status:** `204 NO CONTENT` Se elimino la imagen correctamente
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

---

## 👤 Endpoints de Perfiles

### `ProfileController.java` - Gestión de perfiles múltiples

> **Base URL:** `/api/app/v1/profile`

#### 1. 📋 **GET**

**Descripción:** Obtiene todos los perfiles del usuario autenticado  
**Autenticación:** ✅ Requerida  
**Response:** Lista de perfiles asociados al usuario  
**Status:** `200 OK`  se listaron los perfiles correctamente
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 2. 🔍 **GET** `/details`

**Descripción:** Obtiene los detalles del perfil autenticado actualmente  
**Autenticación:** ✅ Requerida  
**Response:** `ProfileDetailDTO` - Información completa del perfil  
**Status:** `200 OK` se listarón los detalles del perfil correctamente
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 3. 🔑 **POST** `/login`

**Descripción:** Autentica un perfil específico en el sistema  
**Body:** `LoginDTO` - Credenciales del perfil  
**Funcionalidad:**
- 🎯 Autenticación a nivel de perfil (no usuario)
- 🔐 Genera token JWT específico para el perfil
- 🍪 Establece cookies de sesión

**Response:** `TokenResponseDTO` - Token y datos de sesión  
**Status:** `200 OK`  `400 BAD REQUEST` si los datos ingresados tienen un algun error y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 4. ➕ **POST** `/add`

**Descripción:** Registra un nuevo perfil para el usuario autenticado  
**Body:** `NewProfileDTO` - Datos del nuevo perfil  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Crea un perfil adicional bajo la cuenta del usuario  
**Status:** `201 CREATED`  Se creó un perfil correctamente
`400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 5. 🔄 **PATCH** `/update`

**Descripción:** Actualiza la información del perfil autenticado  
**Body:** `UpdateProfileDTO` - Datos a actualizar  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Modifica nombre, email, y otros datos del perfil  
**Status:** `201 CREATED` se actualizo los datos del perfil correctamente
`400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 6. 🔒 **PATCH** `/change-password`

**Descripción:** Cambia la contraseña del perfil con verificación por código  
**Body:** `ChangePasswordDTO` - Email, código y nueva contraseña  
**Validación:** Requiere código de verificación válido  
**Funcionalidad:**
- ✅ Valida el código de verificación
- 🔐 Actualiza la contraseña del perfil

**Status:** `201 CREATED` Se actualizo la contraseña correctamente `400 BAD REQUEST`  
`400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 7. 🚪 **POST** `/logout`

**Descripción:** Cierra la sesión del perfil autenticado  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- ❌ Invalida el token JWT del perfil
- 🧹 Limpia las cookies de sesión

**Status:** `204 NO CONTENT` Se cerró sesión correctamente
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 8. 🗑️ **DELETE** `/{id}`

**Descripción:** Elimina un perfil específico  
**Path Variable:** `id` (Integer) - ID del perfil  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Eliminación del perfil y sus datos asociados  
**Status:** `200 OK`  Perfil eliminado correctamente
`400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 9. 📷 **POST** `/image/add`

**Descripción:** Sube una nueva imagen de perfil  
**Body:** `MultipartFile` - Imagen a subir  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- ☁️ Sube la imagen a Cloudinary
- 🔗 Asocia la imagen al perfil autenticado

**Response:** `ImageDTO` - Datos de la imagen subida  
**Status:** `201 CREATED` Se agregó la imagen correctamente
`400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 10. 🔄 **POST** `/image/update`

**Descripción:** Actualiza la imagen de perfil existente  
**Body:** `MultipartFile` - Nueva imagen  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 🔄 Reemplaza la imagen actual en Cloudinary
- 💾 Actualiza la referencia en la base de datos

**Response:** `ImageDTO` - Datos de la imagen actualizada  
**Status:** `200 OK`  se actualizo la imagen correctamente
`400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 11. 🗑️ **DELETE** `/delete`

**Descripción:** Elimina la imagen de perfil del perfil autenticado  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- ☁️ Elimina la imagen de Cloudinary
- 🗑️ Remueve la referencia de la base de datos

**Status:** `204 NO CONTENT`  Imagen eliminada correctamente
`500 INTERNAL SERVER ERROR` problemas en el servidor

---

### 🌟 **Características Especiales de Perfiles**

| Característica | Descripción |
|----------------|-------------|
| 👥 **Gestión Multi-Perfil** | Permite que un usuario tenga múltiples perfiles (personal, comercial, etc.) |
| 🔐 **Autenticación de Perfil** | Cada perfil puede tener su propia sesión independiente |
| 🔑 **Validación de Códigos** | El cambio de contraseña requiere verificación por código |
| 📷 **Gestión de Imágenes** | Integración completa con Cloudinary para manejo de imágenes |

## 📊 Endpoints de Categorías

### `CategoryController.java` - Gestión de categorías financieras

> **Base URL:** `/api/app/v1/category`  
> **Autenticación:** ✅ Requerida  
> **Microservicio:** KuentecoApp (:8080)

#### 1. 📋 **GET**

**Descripción:** Obtiene todas las categorías del usuario autenticado  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Response:** Lista de categorías disponibles  
**Status:** `200 OK` - Categorías obtenidas correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 2. 📝 **GET** `/enroll`

**Descripción:** Obtiene todas las asignaciones de categorías (enrollments)  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Response:** Lista de todas las asignaciones de categorías a perfiles  
**Status:** `200 OK` - Categorías obtenidas correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 3. 📊 **GET** `/report/{categoryId}`

**Descripción:** Genera un reporte detallado de una categoría específica  
**Autenticación:** ✅ Requerida  
**Path Variable:** `categoryId` (Integer) - ID de la categoría  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Response:** `CategoryReportDTO` - Estadísticas y detalles de la categoría  
**Status:** `200 OK` - Reporte de categoría generado exitosamente  
**Errores:** `400 BAD REQUEST` - ID inválido | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Categoría no encontrada | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 4. 📈 **GET** `/report/summary`

**Descripción:** Obtiene un resumen de todas las transacciones agrupadas por categoría  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Response:** Resumen estadístico de transacciones por categoría  
**Status:** `200 OK` - Resumen de transacciones por categoría obtenido correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 5. 🏢 **GET** `/enroll/user`

**Descripción:** Obtiene las asignaciones de categorías específicas para usuarios de tipo business  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Response:** Lista de asignaciones de categorías para usuarios comerciales  
**Status:** `200 OK` - Resumen de transacciones por categoría obtenido correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `403 FORBIDDEN` - No es usuario business | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 6. ➕ **POST** `/add`

**Descripción:** Crea una nueva categoría  
**Autenticación:** ✅ Requerida  
**Body:** `NewCategoryDTO` - Datos de la nueva categoría  
**Funcionalidad:** Crea una categoría con presupuesto asignado y fechas  
**Status:** `201 CREATED` - Categoría creada correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `409 CONFLICT` - Categoría ya existe | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 7. 📦 **POST** `/batch/add`

**Descripción:** Crea múltiples categorías en una sola operación  
**Autenticación:** ✅ Requerida  
**Body:** `List<NewCategoryDTO>` - Lista de categorías a crear  
**Funcionalidad:** Creación masiva de categorías (itera sobre cada elemento)  
**Status:** `201 CREATED` - Categorías creadas correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `409 CONFLICT` - Algunas categorías ya existen | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 8. 🔄 **PATCH** `/update`

**Descripción:** Actualiza una categoría existente  
**Autenticación:** ✅ Requerida  
**Body:** `UpdateCategoryDTO` - Datos actualizados de la categoría  
**Funcionalidad:** Modifica los datos de la categoría existente  
**Status:** `201 CREATED` - Categoría actualizada correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Categoría no encontrada | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 9. 📦 **PUT** `/batch/update`

**Descripción:** Actualiza múltiples categorías en una sola operación  
**Autenticación:** ✅ Requerida  
**Body:** `List<UpdateCategoryDTO>` - Lista de categorías a actualizar  
**Funcionalidad:** Actualización masiva de categorías (itera sobre cada elemento)  
**Status:** `201 CREATED` - Categorías actualizadas correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Algunas categorías no encontradas | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 10. 🔗 **POST** `/enroll/add`

**Descripción:** Asigna una categoría a un perfil específico  
**Autenticación:** ✅ Requerida  
**Query Params:**
- `profileId` (Integer) - ID del perfil
- `categoryId` (Integer) - ID de la categoría

**Response:** `CategoryEnrollmentDTO` - Detalles de la asignación  
**Status:** `201 CREATED` - Categoría asignada correctamente  
**Errores:** `400 BAD REQUEST` - IDs inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Perfil o categoría no encontrados | `409 CONFLICT` - Asignación ya existe | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 11. 🔗 **POST** `/enroll/add/batch`

**Descripción:** Asigna múltiples categorías a perfiles en una sola operación  
**Autenticación:** ✅ Requerida  
**Body:** `List<BatchEnrollmentRequestDTO>` - Lista de asignaciones a crear  
**Response:** Lista de `CategoryEnrollmentDTO` - Detalles de las asignaciones  
**Status:** `201 CREATED` - Categorías asignadas correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Algunos perfiles/categorías no encontrados | `409 CONFLICT` - Algunas asignaciones ya existen | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 12. 🗑️ **DELETE** `/{id}`

**Descripción:** Elimina una categoría específica  
**Autenticación:** ✅ Requerida  
**Path Variable:** `id` (Integer) - ID de la categoría  
**Funcionalidad:** Eliminación de la categoría  
**Status:** `204 NO CONTENT` - Categoría eliminada correctamente  
**Errores:** `400 BAD REQUEST` - ID inválido | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Categoría no encontrada | `409 CONFLICT` - Categoría en uso | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 13. 📦 **DELETE** `/batch`

**Descripción:** Elimina múltiples categorías en una sola operación  
**Autenticación:** ✅ Requerida  
**Query Param:** `id` (`List<Integer>`) - IDs de las categorías a eliminar  
**Funcionalidad:** Eliminación masiva de categorías (itera sobre cada ID)  
**Response:** Mensaje con el número de categorías eliminadas  
**Status:** `204 NO CONTENT` - X Categorías eliminadas correctamente  
**Errores:** `400 BAD REQUEST` - IDs inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Algunas categorías no encontradas | `409 CONFLICT` - Algunas categorías en uso | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 14. 🔗 **DELETE** `/enroll/{id}`

**Descripción:** Elimina una asignación de categoría a perfil  
**Autenticación:** ✅ Requerida  
**Path Variable:** `id` (Integer) - ID de la asignación  
**Funcionalidad:** Desvincula una categoría de un perfil específico  
**Status:** `204 NO CONTENT` - Asignación eliminada correctamente  
**Errores:** `400 BAD REQUEST` - ID inválido | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Asignación no encontrada | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 15. 📦 **DELETE** `/enroll/batch`

**Descripción:** Elimina múltiples asignaciones de categoría en una sola operación  
**Autenticación:** ✅ Requerida  
**Query Param:** `id` (`List<Integer>`) - IDs de las asignaciones a eliminar  
**Funcionalidad:** Eliminación masiva de asignaciones (itera sobre cada ID)  
**Status:** `204 NO CONTENT` - Asignaciones eliminadas correctamente  
**Errores:** `400 BAD REQUEST` - IDs inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Algunas asignaciones no encontradas | `500 INTERNAL SERVER ERROR` - Error del servidor

---

## 💰 Endpoints de Transacciones

### `TransactionController.java` - Gestión de transacciones financieras

> **Base URL:** `/api/app/v1/transaction`  
> **Autenticación:** ✅ Requerida  
> **Microservicio:** KuentecoApp (:8080)

#### 1. 📋 **GET**

**Descripción:** Obtiene transacciones basadas en los parámetros proporcionados  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Funcionalidad:** 
- 👤 Para usuarios **PERSONAL**: Retorna sus transacciones directas
- 🏢 Para usuarios **BUSINESS**: Retorna transacciones de todos sus perfiles
- 👥 Para **PERFILES**: Retorna transacciones específicas del perfil

**Response:** Lista de transacciones o mensaje informativo  
**Status:** `200 OK` - Transacciones obtenidas correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `403 FORBIDDEN` - Acceso denegado al perfil/usuario | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 2. 📈 **GET** `/report/summary`

**Descripción:** Obtiene un resumen estadístico de todas las transacciones  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Funcionalidad:** Solo disponible para usuarios (no perfiles)  
**Response:** Resumen estadístico agrupado  
**Status:** `200 OK` - Resumen de transacciones obtenido correctamente  
**Errores:** `400 BAD REQUEST` - Solicitud inválida | `401 UNAUTHORIZED` - Sin autorización | `403 FORBIDDEN` - Solo usuarios | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 3. 🏥 **GET** `/bancolombia/health`

**Descripción:** Verifica el estado de salud del servicio de Bancolombia  
**Autenticación:** 🔓 No requerida  
**Funcionalidad:** Monitoreo del servicio externo de transacciones  
**Response:** Estado del servicio con timestamp  
**Status:** `200 OK` - Servicio UP | `503 SERVICE_UNAVAILABLE` - Servicio DOWN  
**Errores:** `500 INTERNAL SERVER ERROR` - Error al verificar estado

#### 4. 🏦 **POST** `/bancolombia`

**Descripción:** Obtiene transacciones desde Bancolombia mediante filtros específicos  
**Autenticación:** ✅ Requerida  
**Body:** `BancolombiaTransactionRequestDTO` - Criterios de filtrado de Bancolombia  
**Funcionalidad:** 
- 🔗 Integración con API de Bancolombia
- 📄 Genera URL de archivo con transacciones filtradas

**Response:** URL del archivo generado  
**Status:** `200 OK` - URL de archivo de transacciones obtenida  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `503 SERVICE_UNAVAILABLE` - Servicio Bancolombia no disponible | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 5. ➕ **POST** `/add`

**Descripción:** Registra una nueva transacción en el sistema  
**Autenticación:** ✅ Requerida  
**Body:** `NewTransactionDTO` - Datos de la nueva transacción  
**Funcionalidad:**
- 👤 Usuarios **PERSONAL**: Pueden crear transacciones directamente
- 🏢 Usuarios **BUSINESS**: Solo perfiles pueden crear transacciones
- 🔗 Asociación automática con categorías, presupuestos y deudas

**Status:** `201 CREATED` - Transacción registrada correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `403 FORBIDDEN` - Permisos insuficientes | `404 NOT FOUND` - Categoría/presupuesto no encontrado | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 6. 📦 **POST** `/batch/add`

**Descripción:** Registra múltiples transacciones en una sola operación  
**Autenticación:** ✅ Requerida  
**Body:** `List<NewTransactionDTO>` - Lista de transacciones a crear  
**Funcionalidad:** Creación masiva de transacciones (itera sobre cada elemento)  
**Response:** Mensaje con número de transacciones creadas  
**Status:** `201 CREATED` - X transacciones creadas exitosamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `403 FORBIDDEN` - Permisos insuficientes | `404 NOT FOUND` - Algunas categorías/presupuestos no encontrados | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 7. 🔄 **PATCH** `/update`

**Descripción:** Actualiza una transacción existente en el sistema  
**Autenticación:** ✅ Requerida  
**Body:** `UpdateTransactionDTO` - Datos actualizados de la transacción  
**Funcionalidad:** 
- 📝 Modifica campos de transacciones existentes
- 🔗 Actualiza asociaciones con categorías, presupuestos y deudas

**Status:** `201 CREATED` - Transacción actualizada correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `403 FORBIDDEN` - Permisos insuficientes | `404 NOT FOUND` - Transacción no encontrada | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 8. 📦 **PUT** `/batch/update`

**Descripción:** Actualiza múltiples transacciones en una sola operación  
**Autenticación:** ✅ Requerida  
**Body:** `List<UpdateTransactionDTO>` - Lista de transacciones a actualizar  
**Funcionalidad:** Actualización masiva de transacciones (itera sobre cada elemento)  
**Status:** `201 CREATED` - Transacciones actualizadas correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `403 FORBIDDEN` - Permisos insuficientes | `404 NOT FOUND` - Algunas transacciones no encontradas | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 9. 🗑️ **DELETE** `/{id}`

**Descripción:** Elimina una transacción específica por su ID  
**Autenticación:** ✅ Requerida  
**Path Variable:** `id` (Integer) - ID de la transacción  
**Funcionalidad:** Eliminación física de la transacción  
**Status:** `204 NO CONTENT` - Transacción eliminada correctamente  
**Errores:** `400 BAD REQUEST` - ID inválido | `401 UNAUTHORIZED` - Sin autorización | `403 FORBIDDEN` - Permisos insuficientes | `404 NOT FOUND` - Transacción no encontrada | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 10. 📦 **DELETE** `/batch`

**Descripción:** Elimina múltiples transacciones en una sola operación  
**Autenticación:** ✅ Requerida  
**Query Param:** `id` (`List<Integer>`) - IDs de las transacciones a eliminar  
**Funcionalidad:** Eliminación masiva de transacciones (itera sobre cada ID)  
**Response:** Mensaje con número de transacciones eliminadas  
**Status:** `204 NO CONTENT` - X transacciones eliminadas correctamente  
**Errores:** `400 BAD REQUEST` - IDs inválidos | `401 UNAUTHORIZED` - Sin autorización | `403 FORBIDDEN` - Permisos insuficientes | `404 NOT FOUND` - Algunas transacciones no encontradas | `500 INTERNAL SERVER ERROR` - Error del servidor

### 🌟 **Características Especiales de Transacciones**

| Característica | Descripción |
|----------------|-------------|
| 🏦 **Integración Bancolombia** | Conexión directa con API de Bancolombia para importar transacciones |
| 👥 **Multi-nivel de Acceso** | Diferentes comportamientos según tipo de usuario (Personal/Business) y perfiles |
| 📊 **Reportes Avanzados** | Resúmenes estadísticos y análisis de transacciones |
| 🔗 **Asociaciones Inteligentes** | Vinculación automática con categorías, presupuestos y deudas |
| 📦 **Operaciones en Lote** | Creación, actualización y eliminación masiva para eficiencia |
| 🏥 **Monitoreo de Servicios** | Health checks para servicios externos |
| ⚡ **Procesamiento Dinámico** | Manejo inteligente basado en roles y tipos de usuario |

---

## 💵 Endpoints de Presupuestos

### `BudgetController.java` - Gestión de presupuestos financieros

> **Base URL:** `/api/app/v1/budget`  
> **Autenticación:** ✅ Requerida  
> **Microservicio:** KuentecoApp (:8080)

#### 1. 📋 **GET**

**Descripción:** Obtiene todos los presupuestos del usuario autenticado  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Response:** Lista de presupuestos con detalles completos  
**Status:** `200 OK` - Presupuestos obtenidas correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 2. 📝 **GET** `/enroll`

**Descripción:** Obtiene todas las asignaciones de presupuestos (enrollments)  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Response:** `BudgetEnrollmentDTO` - Lista de asignaciones presupuesto-perfil  
**Status:** `200 OK` - Presupuestos obtenidos correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 3. 🏢 **GET** `/enroll/user`

**Descripción:** Obtiene las asignaciones de presupuestos para usuarios tipo business  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Response:** Lista de asignaciones de presupuestos para usuarios comerciales  
**Status:** `200 OK` - Resumen de transacciones por presupuesto obtenido correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `403 FORBIDDEN` - No es usuario business | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 4. 📈 **GET** `/report/comparison`

**Descripción:** Genera reporte comparativo de presupuesto vs gastos reales  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Funcionalidad:** 
- 📉 Compara presupuesto asignado vs gasto real
- 📈 Análisis de desviaciones y tendencias
- 📊 Identificación de categorías con mayor impacto

**Response:** `BudgetVsActualDTO` - Reporte comparativo detallado  
**Status:** `200 OK` - Reporte generado correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 5. 📆 **GET** `/report/summary`

**Descripción:** Obtiene resumen ejecutivo de todos los presupuestos  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Funcionalidad:**
- 💰 Total de presupuesto asignado
- 📉 Presupuesto utilizado
- 💵 Presupuesto disponible
- 📈 Porcentajes de utilización

**Response:** `BudgetSummaryDTO` - Resumen ejecutivo consolidado  
**Status:** `200 OK` - Resumen de presupuestos generado correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 6. ➕ **POST** `/add`

**Descripción:** Crea un nuevo presupuesto en el sistema  
**Autenticación:** ✅ Requerida  
**Body:** `NewBudgetDTO` - Datos del nuevo presupuesto  
**Funcionalidad:**
- 📅 Definición de períodos presupuestarios
- 💰 Asignación de montos por categoría
- 🎨 Configuración de alertas y límites

**Status:** `201 CREATED` - Presupuesto creado correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `409 CONFLICT` - Presupuesto ya existe | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 7. 📦 **POST** `/batch/add`

**Descripción:** Crea múltiples presupuestos en una sola operación  
**Autenticación:** ✅ Requerida  
**Body:** `List<NewBudgetDTO>` - Lista de presupuestos a crear  
**Funcionalidad:** Creación masiva de presupuestos para planificación anual (itera sobre cada elemento)  
**Response:** Lista de presupuestos creados  
**Status:** `201 CREATED` - Presupuestos creados correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `409 CONFLICT` - Algunos presupuestos ya existen | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 8. 🔄 **PATCH** `/update`

**Descripción:** Actualiza un presupuesto existente  
**Autenticación:** ✅ Requerida  
**Body:** `BudgetDTO` - Datos actualizados del presupuesto  
**Funcionalidad:**
- 📝 Modificación de montos y períodos
- 🎨 Ajuste de configuraciones y alertas
- 🔄 Recalculo automático de métricas

**Status:** `201 CREATED` - Presupuesto actualizado correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Presupuesto no encontrado | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 9. 📦 **PUT** `/batch/update`

**Descripción:** Actualiza múltiples presupuestos en una sola operación  
**Autenticación:** ✅ Requerida  
**Body:** `List<BudgetDTO>` - Lista de presupuestos a actualizar  
**Funcionalidad:** Actualización masiva para ajustes estacionales (itera sobre cada elemento)  
**Status:** `201 CREATED` - Presupuestos actualizados correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Algunos presupuestos no encontrados | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 10. 🔗 **POST** `/enroll/add`

**Descripción:** Asigna un presupuesto a un perfil específico  
**Autenticación:** ✅ Requerida  
**Query Params:**
- `profileId` (Integer) - ID del perfil
- `budgetId` (Integer) - ID del presupuesto

**Response:** `BudgetEnrollmentDTO` - Detalles de la asignación  
**Status:** `201 CREATED` - Presupuesto asignado correctamente  
**Errores:** `400 BAD REQUEST` - IDs inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Perfil o presupuesto no encontrados | `409 CONFLICT` - Asignación ya existe | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 11. 🔗 **POST** `/enroll/add/batch`

**Descripción:** Asigna múltiples presupuestos a perfiles en una sola operación  
**Autenticación:** ✅ Requerida  
**Body:** `List<BatchEnrollmentRequestDTO>` - Lista de asignaciones a crear  
**Response:** Lista de `BudgetEnrollmentDTO` - Detalles de las asignaciones  
**Status:** `201 CREATED` - Presupuestos asignados correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Algunos perfiles/presupuestos no encontrados | `409 CONFLICT` - Algunas asignaciones ya existen | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 12. 🗑️ **DELETE** `/{id}`

**Descripción:** Elimina un presupuesto específico por su ID  
**Autenticación:** ✅ Requerida  
**Path Variable:** `id` (Integer) - ID del presupuesto  
**Funcionalidad:** Eliminación completa del presupuesto y sus asignaciones  
**Status:** `204 NO CONTENT` - Presupuesto eliminado correctamente  
**Errores:** `400 BAD REQUEST` - ID inválido | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Presupuesto no encontrado | `409 CONFLICT` - Presupuesto en uso | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 13. 📦 **DELETE** `/batch`

**Descripción:** Elimina múltiples presupuestos en una sola operación  
**Autenticación:** ✅ Requerida  
**Query Param:** `id` (`List<Integer>`) - IDs de los presupuestos a eliminar  
**Funcionalidad:** Eliminación masiva de presupuestos obsoletos (itera sobre cada ID)  
**Response:** Mensaje con número de presupuestos eliminados  
**Status:** `204 NO CONTENT` - X presupuestos eliminados correctamente  
**Errores:** `400 BAD REQUEST` - IDs inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Algunos presupuestos no encontrados | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 14. 🔗 **DELETE** `/enroll/{id}`

**Descripción:** Elimina una asignación de presupuesto a perfil  
**Autenticación:** ✅ Requerida  
**Path Variable:** `id` (Integer) - ID de la asignación  
**Funcionalidad:** Desvincula un presupuesto de un perfil específico  
**Status:** `204 NO CONTENT` - Asignación eliminada correctamente  
**Errores:** `400 BAD REQUEST` - ID inválido | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Asignación no encontrada | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 15. 📦 **DELETE** `/enroll/batch`

**Descripción:** Elimina múltiples asignaciones de presupuesto en una sola operación  
**Autenticación:** ✅ Requerida  
**Query Param:** `id` (`List<Integer>`) - IDs de las asignaciones a eliminar  
**Funcionalidad:** Eliminación masiva de asignaciones (itera sobre cada ID)  
**Status:** `204 NO CONTENT` - Asignaciones eliminadas correctamente  
**Errores:** `400 BAD REQUEST` - IDs inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Algunas asignaciones no encontradas | `500 INTERNAL SERVER ERROR` - Error del servidor

### 🌟 **Características Especiales de Presupuestos**

| Característica | Descripción |
|----------------|-------------|
| 📈 **Análisis Comparativo** | Reportes detallados de presupuesto vs gasto real con desviaciones |
| 📆 **Resúmenes Ejecutivos** | Dashboards consolidados con métricas clave de rendimiento |
| 👥 **Asignación por Perfiles** | Distribución granular de presupuestos entre diferentes perfiles |
| 📦 **Operaciones Masivas** | Creación, actualización y eliminación en lote para eficiencia |
| 🔄 **Recalculo Dinámico** | Actualización automática de métricas y alertas |
| 🎨 **Configuración Flexible** | Alertas personalizables y límites ajustables |
| 📅 **Planificación Temporal** | Soporte para presupuestos periódicos y estacionales |

---

## 💳 Endpoints de Deudas

### `DebtController.java` - Gestión de deudas y obligaciones financieras

> **Base URL:** `/api/app/v1/debt`  
> **Autenticación:** ✅ Requerida  
> **Microservicio:** KuentecoApp (:8080)

#### 1. 📋 **GET**

**Descripción:** Obtiene todas las deudas del usuario autenticado  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Response:** Lista completa de deudas con detalles y estado  
**Status:** `200 OK` - Deudas obtenidas correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 2. 📝 **GET** `/enroll`

**Descripción:** Obtiene todas las asignaciones de deudas (enrollments)  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Response:** Lista de todas las asignaciones de deudas a perfiles  
**Status:** `200 OK` - Presupuestos obtenidos correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 3. 🏢 **GET** `/enroll/user`

**Descripción:** Obtiene las asignaciones de deudas específicas para usuarios de tipo business  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Response:** Lista de asignaciones de deudas para usuarios comerciales  
**Status:** `200 OK` - Resumen de transacciones por presupuesto obtenido correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `403 FORBIDDEN` - No es usuario business | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 4. 🏷️ **GET** `/state/{state}`

**Descripción:** Obtiene deudas filtradas por estado específico  
**Autenticación:** ✅ Requerida  
**Path Variable:** `state` (StateDebt) - Estado de la deuda  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Estados disponibles:**
- ✅ `ACTIVE` - Deudas activas
- ✅ `PAID` - Deudas pagadas
- ⚠️ `DEFEATED` - Deudas vencidas
- 🔄 `REFINANCED` - Deudas refinanciadas
- ⏸️ `IN_MORATIUM` - Deudas en moratoria
- ❌ `CANCELLED` - Deudas canceladas

**Response:** Lista de deudas filtradas por estado  
**Status:** `200 OK` - Deudas filtradas por estado obtenidas correctamente  
**Errores:** `400 BAD REQUEST` - Estado inválido | `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 5. ⚠️ **GET** `/overdue`

**Descripción:** Obtiene todas las deudas vencidas (con fecha límite superada)  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Funcionalidad:**
- 📅 Identifica deudas con fecha de vencimiento pasada
- ⚠️ Genera alertas de cobro prioritario
- 📈 Calcula intereses por mora

**Response:** Lista de deudas vencidas con detalles de mora  
**Status:** `200 OK` - Deudas vencidas obtenidas correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 6. ⏰ **GET** `/expiring-soon`

**Descripción:** Obtiene deudas que vencerán en los próximos días especificados  
**Autenticación:** ✅ Requerida  
**Query Param:** `days` (Integer) - Número de días para el filtro (**REQUERIDO**)  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Funcionalidad:**
- 📅 Planificación de pagos futuros
- 🔔 Sistema de alertas preventivas
- 📊 Gestión de flujo de caja

**Response:** Lista de deudas próximas a vencer  
**Status:** `200 OK` - Deudas próximas a vencer obtenidas correctamente  
**Errores:** `400 BAD REQUEST` - Parámetro days inválido | `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 7. 💰 **GET** `/total-pending`

**Descripción:** Calcula el monto total pendiente de todas las deudas activas  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Funcionalidad:**
- 💵 Suma de todas las deudas pendientes
- 📈 Indicador de salud financiera
- 📏 Resumen para presupuesto

**Response:** `BigDecimal` - Monto total pendiente  
**Status:** `200 OK` - Total pendiente del usuario obtenido correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 8. 📈 **GET** `/report/summary`

**Descripción:** Genera reporte resumen completo de todas las deudas  
**Autenticación:** ✅ Requerida  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros (sin implementar funcionalidad)  
**Funcionalidad:**
- 📉 Distribución por estados
- 📈 Tendencias de pago
- ⚠️ Alertas y vencimientos
- 💰 Métricas financieras clave

**Response:** Reporte ejecutivo de deudas consolidado  
**Status:** `200 OK` - Resumen de deudas generado correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 9. ➕ **POST** `/add`

**Descripción:** Registra una nueva deuda en el sistema  
**Autenticación:** ✅ Requerida  
**Body:** `NewDebtDTO` - Datos de la nueva deuda  
**Funcionalidad:**
- 📅 Definición de fechas de vencimiento
- 💵 Configuración de montos e intereses
- 🔔 Configuración de alertas automáticas
- 🏷️ Categorización y etiquetado

**Status:** `201 CREATED` - Deuda creada correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `409 CONFLICT` - Deuda ya existe | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 10. 📦 **POST** `/batch/add`

**Descripción:** Registra múltiples deudas en una sola operación  
**Autenticación:** ✅ Requerida  
**Body:** `List<NewDebtDTO>` - Lista de deudas a crear  
**Funcionalidad:** Importación masiva de deudas (itera sobre cada elemento)  
**Response:** Lista de deudas creadas  
**Status:** `201 CREATED` - Deudas creadas correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `409 CONFLICT` - Algunas deudas ya existen | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 11. 🔄 **PATCH** `/update`

**Descripción:** Actualiza una deuda existente  
**Autenticación:** ✅ Requerida  
**Body:** `DebtDTO` - Datos actualizados de la deuda  
**Funcionalidad:**
- 📝 Modificación de montos y fechas
- 🏷️ Cambio de categorías y etiquetas
- 🔔 Ajuste de configuraciones de alerta
- 📈 Recalculo automático de intereses

**Status:** `200 OK` - Deuda actualizada correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Deuda no encontrada | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 12. 📦 **PUT** `/batch/update`

**Descripción:** Actualiza múltiples deudas en una sola operación  
**Autenticación:** ✅ Requerida  
**Body:** `List<DebtDTO>` - Lista de deudas a actualizar  
**Funcionalidad:** Actualización masiva para renegociaciones (itera sobre cada elemento)  
**Status:** `200 OK` - Deudas actualizadas correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Algunas deudas no encontradas | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 13. 🔗 **POST** `/enroll/add`

**Descripción:** Asigna una deuda a un perfil específico  
**Autenticación:** ✅ Requerida  
**Query Params:**
- `profileId` (Integer) - ID del perfil
- `debtId` (Integer) - ID de la deuda

**Response:** `DebtEnrollmentDTO` - Detalles de la asignación  
**Status:** `201 CREATED` - Deuda asignado correctamente  
**Errores:** `400 BAD REQUEST` - IDs inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Perfil o deuda no encontrados | `409 CONFLICT` - Asignación ya existe | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 14. 🔗 **POST** `/enroll/add/batch`

**Descripción:** Asigna múltiples deudas a perfiles en una sola operación  
**Autenticación:** ✅ Requerida  
**Body:** `List<BatchEnrollmentRequestDTO>` - Lista de asignaciones a crear  
**Response:** Lista de `DebtEnrollmentDTO` - Detalles de las asignaciones  
**Status:** `201 CREATED` - Deudas asignadas correctamente  
**Errores:** `400 BAD REQUEST` - Datos inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Algunos perfiles/deudas no encontrados | `409 CONFLICT` - Algunas asignaciones ya existen | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 15. 💳 **POST** `/payment`

**Descripción:** Registra un pago hacia una deuda específica  
**Autenticación:** ✅ Requerida  
**Body:** `DebtPaymentDTO` - Detalles del pago realizado  
**Funcionalidad:**
- 💵 Registro de pagos parciales o totales
- 📅 Actualización automática de saldos
- 📈 Cálculo de intereses y penalizaciones
- 🏷️ Cambio automático de estado si es necesario

**Status:** `200 OK` - Pago realizado correctamente  
**Errores:** `400 BAD REQUEST` - Datos de pago inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Deuda no encontrada | `409 CONFLICT` - Pago ya registrado | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 16. 🏷️ **PATCH** `/{id}/state/{state}`

**Descripción:** Actualiza el estado de una deuda específica  
**Autenticación:** ✅ Requerida  
**Path Variables:**
- `id` (Integer) - ID de la deuda
- `state` (StateDebt) - Nuevo estado

**Funcionalidad:**
- ✅ Activar deudas pausadas
- ⏸️ Pausar deudas temporalmente
- ❌ Cancelar deudas
- ✅ Marcar como pagadas

**Status:** `200 OK` - Estado de la deuda actualizado correctamente  
**Errores:** `400 BAD REQUEST` - ID o estado inválido | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Deuda no encontrada | `409 CONFLICT` - Cambio de estado inválido | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 17. 🗑️ **DELETE** `/{id}`

**Descripción:** Elimina una deuda específica por su ID  
**Autenticación:** ✅ Requerida  
**Path Variable:** `id` (Integer) - ID de la deuda  
**Funcionalidad:** Eliminación completa de la deuda y su historial  
**Status:** `204 NO CONTENT` - Deuda eliminada correctamente  
**Errores:** `400 BAD REQUEST` - ID inválido | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Deuda no encontrada | `409 CONFLICT` - Deuda con pagos asociados | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 18. 📦 **DELETE** `/batch`

**Descripción:** Elimina múltiples deudas en una sola operación  
**Autenticación:** ✅ Requerida  
**Query Param:** `id` (`List<Integer>`) - IDs de las deudas a eliminar  
**Funcionalidad:** Limpieza masiva de deudas canceladas (itera sobre cada ID)  
**Response:** Mensaje con número de deudas eliminadas  
**Status:** `204 NO CONTENT` - X deudas eliminadas correctamente  
**Errores:** `400 BAD REQUEST` - IDs inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Algunas deudas no encontradas | `409 CONFLICT` - Algunas deudas con pagos asociados | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 19. 🔗 **DELETE** `/enroll/{id}`

**Descripción:** Elimina una asignación de deuda a perfil  
**Autenticación:** ✅ Requerida  
**Path Variable:** `id` (Integer) - ID de la asignación  
**Funcionalidad:** Desvincula una deuda de un perfil específico  
**Status:** `204 NO CONTENT` - Asignación eliminada correctamente  
**Errores:** `400 BAD REQUEST` - ID inválido | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Asignación no encontrada | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 20. 📦 **DELETE** `/enroll/batch`

**Descripción:** Elimina múltiples asignaciones de deuda en una sola operación  
**Autenticación:** ✅ Requerida  
**Query Param:** `id` (`List<Integer>`) - IDs de las asignaciones a eliminar  
**Funcionalidad:** Eliminación masiva de asignaciones (itera sobre cada ID)  
**Status:** `204 NO CONTENT` - Asignaciónes eliminadas correctamente  
**Errores:** `400 BAD REQUEST` - IDs inválidos | `401 UNAUTHORIZED` - Sin autorización | `404 NOT FOUND` - Algunas asignaciones no encontradas | `500 INTERNAL SERVER ERROR` - Error del servidor

### 🌟 **Características Especiales de Deudas**

| Característica | Descripción |
|----------------|-------------|
| ⚠️ **Gestión de Vencimientos** | Sistema inteligente de alertas para deudas vencidas y próximas a vencer |
| 🏷️ **Estados Dinámicos** | Control granular del ciclo de vida de las deudas (Activa, Pausada, Pagada, Cancelada) |
| 💳 **Sistema de Pagos** | Registro detallado de pagos con cálculo automático de saldos e intereses |
| 📈 **Reportes Avanzados** | Análisis completo de salud financiera y tendencias de endeudamiento |
| 💰 **Cálculos Automáticos** | Totales pendientes, intereses por mora y proyecciones de pago |
| 🔔 **Alertas Inteligentes** | Notificaciones preventivas y sistema de recordatorios |
| 📦 **Operaciones Masivas** | Importación, actualización y eliminación en lote para eficiencia |
| 📅 **Planificación Temporal** | Herramientas de planificación y gestión de flujo de caja |

---

## 📄 Endpoints de Excel

### `ExcelController.java` - Importación y exportación de datos en Excel

> **Base URL:** `/api/app/v1/excel`

#### 1. 📄 **GET** `/export`

**Descripción:** Exporta todos los datos financieros del usuario a un archivo Excel  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 📋 Genera reporte consolidado de todas las entidades financieras
- 📈 Incluye transacciones, presupuestos, categorías y deudas
- 📅 Formateado con fechas y montos legibles
- 🎨 Aplicación de estilos y formato profesional
- 📊 Gráficos y tablas dinámicas

**Response:** Archivo Excel (.xlsx) descargable directamente  
**Content-Type:** `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`  
**Status:** `200 OK`  

**Características del archivo exportado:**
- 📁 **Múltiples hojas**: Una hoja por cada tipo de dato (Transacciones, Presupuestos, etc.)
- 📈 **Formatos avanzados**: Colores, bordes y tipografías profesionales
- 📊 **Fórmulas integradas**: Cálculos automáticos de totales y promedios
- 📅 **Filtros dinámicos**: Capacidad de filtrado por fechas y categorías
- 💰 **Formatos de moneda**: Presentación adecuada de valores monetarios

#### 2. 📅 **POST** `/import`

**Descripción:** Importa datos financieros desde un archivo Excel cargado  
**Content-Type:** `multipart/form-data`  
**Body:** Archivo Excel (.xlsx o .xls) con datos estructurados  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 📂 Procesamiento inteligente de hojas múltiples
- 🔍 Validación automática de formatos y datos
- ⚙️ Mapeo automático de columnas
- 📈 Actualización masiva de registros existentes
- ➕ Creación automática de nuevos registros
- ⚠️ Reporte de errores y conflictos

**Response:** Mensaje de confirmación con detalles del proceso  
**Status:** `200 OK`  

**Estructura esperada del archivo:**
- 📁 **Hoja "Transacciones"**: Columnas para fecha, monto, descripción, categoría
- 📁 **Hoja "Presupuestos"**: Columnas para nombre, monto, período, categoría
- 📁 **Hoja "Categorías"**: Columnas para nombre, descripción, tipo
- 📁 **Hoja "Deudas"**: Columnas para acreedor, monto, fecha vencimiento, estado

**Validaciones automáticas:**
- 📅 **Formatos de fecha**: Reconocimiento automático de diversos formatos
- 💰 **Valores numéricos**: Validación de montos y cantidades
- 🏷️ **Referencias**: Verificación de existencia de categorías y perfiles
- ✅ **Campos obligatorios**: Validación de campos requeridos
- 🔄 **Duplicados**: Detección y manejo de registros duplicados

### 🌟 **Características Especiales de Excel**

| Característica | Descripción |
|----------------|-------------|
| 📄 **Exportación Completa** | Genera reportes consolidados con todos los datos financieros del usuario |
| 📅 **Importación Inteligente** | Procesamiento automático con validación y mapeo de columnas |
| 🎨 **Formato Profesional** | Aplicación automática de estilos, colores y formatos empresariales |
| 📊 **Datos Dinámicos** | Incluye fórmulas, filtros y capacidades de análisis avanzado |
| ⚠️ **Validación Robusta** | Sistema completo de validación de datos y reporte de errores |
| 🔄 **Actualización Masiva** | Capacidad de actualizar miles de registros en una sola operación |
| 📁 **Estructura Flexible** | Soporte para múltiples hojas y formatos de archivo |
| 💰 **Formato Financiero** | Presentación adecuada de monedas, porcentajes y cálculos |

---

## 💱 Endpoints de Tipos de Cambio

### `ExchangeRateController.java` - Conversión de divisas y tipos de cambio

> **Base URL:** `/api/app/v1/exchange-rates`

#### 1. 🌍 **GET**

**Descripción:** Obtiene todas las tasas de cambio disponibles en el sistema  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 💰 Tasas de cambio actualizadas en tiempo real
- 🌍 Soporte para múltiples monedas internacionales
- 📅 Historial de fluctuaciones y tendencias
- 📈 Datos de mercado financiero global
- ⏱️ Última actualización y timestamps

**Response:** `List<ExchangeRateDTO>` - Lista completa de tasas de cambio  
**Status:** `200 OK`  
**Monedas soportadas:**
Todas las registradas en OpenExchangeRates

#### 2. 🔄 **POST** `/convert`

**Descripción:** Convierte una cantidad de dinero entre diferentes monedas  
**Body:** `ConvertCurrencyRequestDTO` - Datos de la conversión solicitada  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- ⚡ Conversión instantánea con tasas actuales
- 📈 Cálculos precisos con decimales
- 📊 Aplicación de comisiones y spreads
- 📅 Registro de historial de conversiones
- ⚠️ Validación de monedas soportadas

**Características de la conversión:**
- 📈 **Precisión**: Cálculos con hasta 6 decimales
- 💰 **Comisiones**: Aplicación transparente de fees
- ⏱️ **Tiempo Real**: Tasas actualizadas cada minuto
- 📅 **Historial**: Registro de todas las conversiones
- ⚠️ **Validación**: Verificación de montos y monedas

### 🌟 **Características Especiales de Tipos de Cambio**

| Característica | Descripción |
|----------------|-------------|
| 🌍 **Cobertura Global** | Soporte para las principales monedas internacionales del mercado |
| ⏱️ **Actualización en Tiempo Real** | Tasas de cambio actualizadas cada 2 horas desde fuentes confiables |
| 📈 **Cálculos Precisos** | Algoritmos financieros con precisión de hasta 6 decimales |
| 📊 **Integración Financiera** | Conexión con APIs de bancos centrales y mercados financieros |
| 📅 **Historial Completo** | Registro detallado de conversiones y tendencias históricas |
| 💰 **Transparencia de Costos** | Aplicación clara de comisiones y spreads |
| ⚡ **Rendimiento Optimizado** | Respuestas rápidas con caché inteligente |
| ⚠️ **Validación Robusta** | Verificación completa de datos y límites de conversión |

---
## 🔔 Endpoints de Notificaciones

### `NotificationController.java` - Sistema de notificaciones y alertas

> **Base URL:** `/api/app/v1/notification`  
> **Autenticación:** ✅ Requerida  
> **Microservicio:** KuentecoApp (:8080)

#### 1. 📋 **GET**

**Descripción:** Obtiene todas las notificaciones del usuario autenticado  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 🔔 Notificaciones del sistema y alertas personalizadas
- 📅 Recordatorios de vencimientos y pagos
- 📊 Alertas de presupuesto y límites excedidos
- ⚠️ Notificaciones de seguridad y cambios de cuenta
- 📈 Actualizaciones de transacciones y movimientos

**Response:** `List<NotificationDTO>` - Lista completa de notificaciones del usuario  
**Status:** `200 OK` - Notificaciones obtenidas correctamente  
**Errores:** `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

#### 2. 📅 **GET** `/range`

**Descripción:** Obtiene notificaciones del usuario filtradas por rango de fechas  
**Autenticación:** ✅ Requerida  
**Query Params (requeridos):**
- `fromDate` (LocalDateTime) - Fecha de inicio (**REQUERIDO**) - Formato: `yyyy-MM-dd'T'HH:mm:ss`
- `toDate` (LocalDateTime) - Fecha final (**REQUERIDO**) - Formato: `yyyy-MM-dd'T'HH:mm:ss`

**Funcionalidad:**
- 📅 Filtrado preciso por rango temporal
- 🗓️ Consultas históricas de notificaciones
- 📈 Análisis de patrones de notificación
- 🔍 Búsqueda eficiente en grandes volúmenes

**Response:** `List<NotificationDTO>` - Lista de notificaciones en el rango especificado  
**Status:** `200 OK` - Notificaciones del usuario en rango de fechas obtenidas correctamente  
**Errores:** `400 BAD REQUEST` - Parámetros de fecha inválidos | `401 UNAUTHORIZED` - Sin autorización | `500 INTERNAL SERVER ERROR` - Error del servidor

**Ejemplo de Query:**
```http
GET /api/app/v1/notification/range?fromDate=2024-01-01T00:00:00&toDate=2024-01-31T23:59:59
```

### 🌟 **Características Especiales de Notificaciones**

| Característica | Descripción |
|----------------|-------------|
| 🔔 **Sistema Inteligente** | Notificaciones personalizadas basadas en comportamiento del usuario |
| 📅 **Filtrado Temporal** | Búsqueda precisa por rangos de fechas con formatos flexibles |
| ⚡ **Tiempo Real** | Notificaciones instantáneas para eventos críticos |
| 🎯 **Categorización** | Clasificación automática por tipo y prioridad |
| 👥 **Soporte Multi-perfil** | Compatible con usuarios individuales (ROLE_USER) y perfiles empresariales (ROLE_PROFILE) |
| 📊 **Estructura Consistente** | Formato uniforme con ContentNotification (title, body, date) |
| 🔒 **Seguridad** | Notificaciones de seguridad y auditoría de acceso |
| 🎨 **Personalización** | Configuración avanzada de preferencias mediante NotificationPreferencesDTO |

### 📊 **DTOs de Notificaciones**

#### 📧 **NotificationDTO**
**Estructura principal para notificaciones:**
- `id` (Integer) - Identificador único de la notificación
- `content` (ContentNotification) - Contenido estructurado de la notificación
- `dateSend` (LocalDateTime) - Fecha y hora de envío

#### 📝 **ContentNotification**
**Contenido de la notificación:**
- `title` (String) - Título de la notificación
- `body` (String) - Cuerpo o mensaje principal
- `date` (String) - Fecha como texto legible

#### ⚙️ **NotificationPreferencesDTO**
**Configuración avanzada de preferencias del usuario:**

**Identificación:**
- `userId` (String) - ID del usuario
- `profileId` (Integer) - ID del perfil específico

**Preferencias de Presupuestos:**
- `budgetExceededEnabled` (boolean) - Alertas de presupuesto excedido (default: true)
- `budgetNearLimitEnabled` (boolean) - Alertas de presupuesto cerca del límite (default: true)

**Preferencias de Deudas:**
- `debtReminderEnabled` (boolean) - Recordatorios de deudas (default: true)
- `debtOverdueEnabled` (boolean) - Alertas de deudas vencidas (default: true)
- `debtReminderDaysBefore` (int) - Días de anticipación para recordatorios (default: 3)

**Preferencias de Transacciones:**
- `transactionAlertEnabled` (boolean) - Alertas de transacciones (default: false)
- `unusualActivityEnabled` (boolean) - Detección de actividad inusual (default: true)

**Canales de Notificación:**
- `emailEnabled` (boolean) - Notificaciones por email (default: true)
- `pushEnabled` (boolean) - Notificaciones push (default: true)
- `smsEnabled` (boolean) - Notificaciones SMS (default: false)

**Configuración de Contacto:**
- `notificationEmail` (String) - Email alternativo para notificaciones
- `phoneNumber` (String) - Número de teléfono para SMS

### 📊 **Tipos de Notificaciones Soportadas**

#### 💰 **Financieras**
- Nuevas transacciones registradas
- Límites de presupuesto alcanzados
- Cambios en tipos de cambio relevantes
- Actualizaciones de saldos y balances

#### 📅 **Recordatorios y Vencimientos**
- Deudas próximas a vencer
- Fechas límite de pagos
- Renovación de presupuestos periódicos
- Recordatorios de metas financieras

#### 🔒 **Seguridad y Auditoría**
- Inicios de sesión desde nuevos dispositivos
- Cambios de contraseña y configuración
- Intentos de acceso fallidos
- Actividad sospechosa detectada

#### 📈 **Reportes y Resúmenes**
- Resúmenes mensuales automáticos
- Reportes de gastos por categoría
- Actualizaciones de rendimiento financiero
- Alertas de tendencias y patrones

---

## 💳 Endpoints de Suscripciones

### `SubscriptionController.java` - Gestión de suscripciones y pagos con MercadoPago

> **Base URL:** `/api/app/v1/subscription`

#### 1. ➕ **POST**

**Descripción:** Crea una nueva suscripción en MercadoPago  
**Body:** `CreateSubscriptionRequestDTO` - Datos de la suscripción a crear  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 💳 Integración directa con API de MercadoPago
- 🗓️ Configuración de planes de suscripción flexibles
- 💰 Gestión automática de cobros recurrentes
- 🔒 Seguridad PCI DSS compliant
- 🔔 Notificaciones automáticas de estado
**Status:** `201 CREATED`  

#### 2. 🔍 **GET** `/{preapprovalId}`

**Descripción:** Obtiene los detalles de una suscripción específica  
**Path Variable:** `preapprovalId` (String) - ID de preaprobación de MercadoPago  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 📄 Detalles completos de la suscripción
- 📅 Estado actual y próxima fecha de cobro
- 📊 Métricas de uso y consumo
- 💰 Historial de transacciones asociadas
- ⚙️ Configuración y preferencias

**Status:** `200 OK`  


#### 3. 📋 **GET** `/{preapprovalId}/payment-history`

**Descripción:** Obtiene el historial de pagos de una suscripción específica  
**Path Variable:** `preapprovalId` (String) - ID de preaprobación de MercadoPago  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 💳 Historial completo de pagos y transacciones
- 📅 Fechas de cobro y vencimientos
- 📊 Estados de pago detallados
- 💰 Montos cobrados y comisiones
- ⚠️ Pagos fallidos y reintentos

**Status:** `200 OK`  


#### 4. 📁 **GET** `/v1/subscription/my-subscriptions`

**Descripción:** Obtiene todas las suscripciones del usuario autenticado  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 📋 Lista completa de suscripciones activas e inactivas
- 📈 Resumen del estado de cada suscripción
- 💰 Total de gastos mensuales en suscripciones
- 📅 Próximas fechas de renovación
- ⚙️ Enlaces rápidos para gestión

**Response:** `SubscriptionResponseDTO` - Información consolidada de suscripciones  
**Status:** `200 OK`  

### 🌟 **Características Especiales de Suscripciones**

| Característica | Descripción |
|----------------|-------------|
| 💳 **Integración MercadoPago** | Conexión nativa con la API de MercadoPago para pagos seguros |
| 🔒 **Seguridad PCI DSS** | Cumplimiento total de estándares de seguridad financiera |
| 💰 **Cobros Automáticos** | Gestión inteligente de cobros recurrentes y reintentos |
| 🔔 **Notificaciones Real-time** | Alertas instantáneas de estados de pago y cambios |
| 📈 **Analytics Avanzado** | Métricas detalladas de suscripciones y rendimiento |
| ⚙️ **Gestión Flexible** | Configuración dinámica de planes y precios |
| 📅 **Planificación** | Calendario inteligente de pagos y renovaciones |
| 🌐 **Multi-moneda** | Soporte para múltiples divisas y mercados |


---

---

# 🤖 **KuentecoChat** - Microservicio de IA Financiera

> **Microservicio especializado en inteligencia artificial para análisis financiero y procesamiento de documentos**

**🔗 Puerto:** `:7070`  
**📊 Base de Datos:** MongoDB  
**🐳 Imagen Docker:** `yefff/image-backend-kuenteco-chat:1.0.4`  

## 💬 Endpoints de Chat

### `ChatController.java` - Sistema de inteligencia artificial para procesamiento de documentos financieros

> **Base URL:** `/api/chat/v1`  
> **Microservicio:** KuentecoChat (:7070)

#### 1. 🤖 **POST** `/chat`

**Descripción:** Procesa consultas de texto con IA para análisis financiero inteligente  
**Body:** `ChatDTO` - Datos de la consulta de chat  
**Autenticación:** 🔓 No requerida (sistema interno)  
**Funcionalidad:**
- 🤖 Procesamiento de consultas con modelos de IA (OpenAI, DeepSeek)
- 📊 Análisis dinámico de datos financieros
- 🔄 Generación automática de IDs de conversación
- 📈 Respuestas estructuradas con gráficos y datos
- 💭 Contexto conversacional mantenido por medio del conversationId

**Response:** `DynamicAnalysisResponseDTO` - Respuesta estructurada de la IA  
**Status:** `200 OK` / `400 BAD REQUEST` / `404 NOT FOUND`  


#### 2. 🔗 **POST** `/chat-with-url`

**Descripción:** Procesa archivos desde URLs con IA para análisis financiero  
**Body:** `ChatFilesDTO` - Datos de chat con URLs de archivos  
**Content-Type:** `application/json`  
**Autenticación:** 🔓 No requerida (sistema interno)  
**Funcionalidad:**
- 🔗 Procesamiento de múltiples archivos desde URLs
- 📄 Soporte para PDF, Excel, CSV y documentos financieros
- ⚙️ Extracción inteligente de datos financieros
- 📊 Análisis automatizado de transacciones y reportes
- 🔄 Contexto conversacional mantenido entre archivos

**Response:** `StringChatResponseDTO` - Respuesta de chat con string  
**Status:** `200 OK` / `400 BAD REQUEST` / `404 NOT FOUND`  

#### 3. 📁 **POST** `/chat-with-file`

**Descripción:** Procesa un archivo cargado directamente con IA  
**Content-Type:** `multipart/form-data`  
**Body:** `ChatMultipartDTO` - Datos de chat con archivo multipart  
**Autenticación:** 🔓 No requerida (sistema interno)  
**Funcionalidad:**
- 📁 Carga directa de archivos financieros
- 📊 Procesamiento inteligente de documentos
- 📝 Extracción de texto y datos estructurados
- 📈 Generación de insights y recomendaciones
- 🔍 Análisis contextual del contenido 

**Response:** `StringChatResponseDTO` - Respuesta de chat con string  
**Status:** `200 OK` / `400 BAD REQUEST` / `404 NOT FOUND`


#### 4. 📄 **GET** `/reports/download/{reportId}`

**Descripción:** Descarga reportes generados por la IA  
**Path Variable:** `reportId` (String) - ID del reporte generado  
**Autenticación:** 🔓 No requerida (sistema interno)  
**Funcionalidad:**
- 📄 Descarga de reportes PDF generados automáticamente
- 📊 Gráficos y visualizaciones incluidas
- 📈 Reportes de alta calidad con branding
- 🔗 Enlaces de descarga seguros y temporales
- 🔄 Generación bajo demanda

**Response:** Archivo PDF del reporte  
**Content-Type:** `application/pdf`  
**Status:** `200 OK` / `404 NOT FOUND`  

### 🌟 **Características Especiales de Chat con IA**

| Característica | Descripción |
|----------------|-------------|
| 🤖 **Modelos Múltiples** | Soporte para OpenAI y DeepSeek con capacidades especializadas |
| 📊 **Análisis Dinámico** | Respuestas estructuradas con gráficos y visualizaciones |
| 📁 **Procesamiento Multi-formato** | Soporte para PDF, Excel, CSV, y documentos financieros |
| 🔄 **Contexto Conversacional** | Mantenimiento del historial de conversación entre consultas |
| 📈 **Insights Inteligentes** | Generación automática de recomendaciones financieras |
| 🔗 **Integración Externa** | Procesamiento de archivos desde URLs externas |
| 📄 **Generación de Reportes** | Creación automática de reportes PDF profesionales |
| ⚙️ **Extracción Inteligente** | Algoritmos avanzados para extraer datos de documentos complejos |

### 🤖 **Modelos de IA Soportados**

#### 🌐 **OpenAI**
- **Modelo**: GPT-4 / GPT-3.5 Turbo
- **Fortalezas**:
  - 📝 Procesamiento de lenguaje natural avanzado
  - 📊 Análisis financiero complejo
  - 📈 Generación de insights detallados
  - 🌍 Soporte multiidioma

#### 🤖 **DeepSeek**
- **Modelo**: DeepSeek-Coder
- **Fortalezas**:
  - 📊 Análisis numérico especializado
  - 📄 Procesamiento eficiente de documentos
  - ⚡ Respuestas rápidas y optimizadas
  - 💰 Costos operativos reducidos

### 📁 **Tipos de Archivos Soportados**

**Documentos Financieros:**
- 📄 **PDF**: Estados financieros, reportes, facturas
- 📏 **Excel**: Hojas de cálculo, presupuestos, análisis
- 📈 **CSV**: Datos de transacciones, exportaciones bancarias
- 📅 **Word**: Reportes narrativos, propuestas financieras

**Capacidades de Procesamiento:**
- 🔍 **Extracción de Texto**: OCR avanzado para documentos escaneados
- 📈 **Reconocimiento de Tablas**: Identificación automática de estructuras de datos
- 📊 **Análisis Numérico**: Procesamiento de valores monetarios y cálculos
- 🔗 **Referencias Cruzadas**: Vinculación entre múltiples documentos

### 📈 **Tipos de Análisis Disponibles**

#### 💰 **Análisis Financiero**
- Balance general y estado de resultados
- Análisis de flujo de caja
- Ratios financieros y indicadores clave
- Proyecciones y tendencias

#### 📉 **Análisis de Transacciones**
- Categorización automática de gastos
- Detección de patrones de gasto
- Identificación de anomalías
- Recomendaciones de ahorro

#### 📊 **Análisis Predictivo**
- Proyecciones de ingresos y gastos
- Análisis de riesgo financiero
- Planificación presupuestaria
- Optimización de inversiones

### 🔄 **Gestión de Conversaciones**

**Funcionalidades:**
- 🎯 **IDs únicos**: Generación automática de identificadores de conversación
- 📜 **Historial Contextual**: Mantenimiento del contexto entre múltiples consultas
- 🔄 **Continuidad**: Capacidad de retomar conversaciones previas
- 📊 **Seguimiento**: Monitoreo del progreso del análisis

### 📄 **Sistema de Reportes**

**Características:**
- 🎨 **Diseño Profesional**: Plantillas con branding corporativo
- 📈 **Visualizaciones**: Gráficos interactivos y tablas dinámicas
- 🔗 **Enlaces Seguros**: URLs temporales para descarga segura
- 📋 **Formatos Múltiples**: PDF, Excel, y formatos personalizados

---

## 📜 Endpoints de Historial de Chat

### `ChatHistoryController.java` - Gestión de historial de conversaciones con IA

> **Base URL:** `/api/chat/v1/chat/history`

#### 1. 👤 **GET** `/user`

**Descripción:** Obtiene todas las conversaciones del usuario autenticado  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 📋 Lista completa de conversaciones del usuario
- 📅 Historial cronológico de interacciones con IA
- 🔍 Resumen de conversaciones por fecha
- 🎯 Identificadores únicos de conversación
- 📊 Metadatos de cada conversación
 
**Status:** `200 OK`

#### 2. 🔍 **GET** `/{conversationId}`

**Descripción:** Obtiene el historial completo de una conversación específica  
**Path Variable:** `conversationId` (String) - ID único de la conversación  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 💬 Historial detallado de mensajes de la conversación
- 🔄 Secuencia completa de intercambios usuario-IA
- 📅 Timestamps precisos de cada interacción
- 🎯 Contexto conversacional preservado
- 📊 Análisis y respuestas estructuradas

**Status:** `200 OK`  


#### 3. 🗑️ **DELETE** `/delete/{conversationId}`

**Descripción:** Elimina el historial completo de una conversación específica  
**Path Variable:** `conversationId` (String) - ID único de la conversación a eliminar  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 🗑️ Eliminación completa del historial de conversación
- 🔒 Eliminación segura y definitiva de datos
- 📊 Liberación de espacio de almacenamiento
- ⚠️ Acción irreversible - sin posibilidad de recuperación
- 🔒 Validación de permisos de usuario

**Response:** Sin contenido (eliminación exitosa)  
**Status:** `200 OK`  

### 🌟 **Características Especiales del Historial de Chat**

| Característica | Descripción |
|----------------|-------------|
| 📋 **Gestión Completa** | Control total sobre el historial de conversaciones con IA |
| 🔍 **Búsqueda Granular** | Acceso a conversaciones individuales y historial detallado |
| 📅 **Preservación Temporal** | Timestamps precisos para cada interacción registrada |
| 🎯 **Identificación Única** | Sistema de IDs únicos para gestión eficiente de conversaciones |
| 🔒 **Seguridad de Datos** | Acceso controlado y eliminación segura del historial |
| 💬 **Contexto Conversacional** | Mantenimiento del flujo natural de la conversación |
| 📊 **Estructura Consistente** | Formato uniforme para todos los tipos de interacciones |
| ⚡ **Acceso Rápido** | Recuperación eficiente del historial para continuidad |

**Campos del modelo:**
- 🎯 **conversationId**: Identificador único que agrupa mensajes relacionados
- 💬 **prompt**: Consulta original del usuario a la IA
- 🤖 **response**: Respuesta procesada y generada por los modelos de IA
- 📅 **date**: Marca temporal con formato ISO 8601

### 🔄 **Flujo de Gestión de Historial**

#### 📊 **Creación Automática**
Cuando un usuario interactúa con los endpoints de chat:
1. 🎯 Se genera o utiliza un `conversationId` existente
2. 💾 Se almacena automáticamente el prompt y response
3. 📅 Se registra el timestamp de la interacción
4. 🔗 Se vincula al usuario autenticado

#### 🔍 **Consulta del Historial**
Los usuarios pueden:
- 📋 Ver todas sus conversaciones (`/user`)
- 🔍 Acceder a conversaciones específicas (`/{conversationId}`)
- 📅 Revisar el contexto temporal de cada interacción
- 💬 Mantener la continuidad conversacional

#### 🗑️ **Gestión de Datos**
Funcionalidades de limpieza:
- 🗑️ Eliminación selectiva de conversaciones
- 🔒 Validación de permisos antes de eliminar
- ⚠️ Confirmación de acciones irreversibles
- 📊 Optimización del almacenamiento

### 🎯 **Casos de Uso Principales**

#### 👤 **Para Usuarios Finales**
- 📋 Revisar conversaciones pasadas con la IA financiera
- 🔍 Buscar consultas anteriores y sus respuestas
- 💭 Mantener contexto en sesiones múltiples
- 📊 Analizar el historial de interacciones

#### 🔧 **Para Desarrolladores**
- 📈 Monitoreo de uso del sistema de IA
- 🔍 Debugging de conversaciones problemáticas
- 📊 Análisis de patrones de consulta
- ⚡ Optimización del rendimiento

#### 📊 **Para Analytics**
- 📈 Métricas de engagement con IA
- 🎯 Patrones de consultas frecuentes
- 💭 Análisis de satisfacción del usuario
- 🔄 Mejoras en modelos de respuesta


---

## ✨ Características Especiales

### 🔒 **Seguridad y Autenticación**
- **JWT Tokens:** Autenticación basada en tokens seguros
- **Multi-level Auth:** Autenticación a nivel de usuario y perfil
- **Code Verification:** Verificación por código de 6 dígitos vía email
- **Session Management:** Gestión completa de sesiones y cookies

### 👥 **Gestión Multi-Perfil**
- **Multiple Profiles:** Un usuario puede tener múltiples perfiles
- **Independent Sessions:** Cada perfil maneja su propia sesión
- **Profile Types:** Soporte para perfiles personales y comerciales
- **Isolated Data:** Datos completamente aislados entre perfiles

### 📊 **Sistema de Categorías**
- **Flexible Categories:** Creación y gestión flexible de categorías
- **Budget Assignment:** Asignación de presupuestos por categoría
- **Batch Operations:** Operaciones masivas para mayor eficiencia
- **Advanced Reporting:** Reportes detallados y resúmenes estadísticos
- **Profile Assignment:** Asignación de categorías específicas por perfil

### 🌐 **Integraciones Externas**
- **Cloudinary:** Gestión completa de imágenes en la nube
- **SendGrid:** Envío de emails transaccionales
- **MercadoPago:** Procesamiento de pagos (mencionado en constraints)

### 🔧 **Características Técnicas**
- **RESTful API:** Diseño REST completo y consistente
- **Data Validation:** Validación robusta de datos de entrada
- **Error Handling:** Manejo estructurado de errores y excepciones
- **Query Parameters:** Filtros flexibles con parámetros de consulta
- **Batch Processing:** Soporte para operaciones en lote

---

> 📝 **Nota:** Todos los endpoints que requieren autenticación utilizan JWT tokens. Los códigos de estado HTTP siguen las convenciones REST estándar.
