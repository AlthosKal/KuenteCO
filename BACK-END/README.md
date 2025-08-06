# 🏦 Funcionalidades del KuenteCO

> **Sistema de gestión financiera personal y empresarial con API REST completa**

## 📋 Índice

- [🔐 Endpoints de Autenticación](#-endpoints-de-autenticación)
- [👤 Endpoints de Perfiles](#-endpoints-de-perfiles)
- [📊 Endpoints de Categorías](#-endpoints-de-categorías)
- [💰 Endpoints de Transacciones](#-endpoints-de-transacciones)
- [💵 Endpoints de Presupuestos](#-endpoints-de-presupuestos)
- [💳 Endpoints de Deudas](#-endpoints-de-deudas)
- [📄 Endpoints de Excel](#-endpoints-de-excel)
- [💱 Endpoints de Tipos de Cambio](#-endpoints-de-tipos-de-cambio)
- [🔔 Endpoints de Notificaciones](#-endpoints-de-notificaciones)
- [💳 Endpoints de Suscripciones](#-endpoints-de-suscripciones)

## 🤖 KuentecoChat - Sistema de IA

- [💬 Endpoints de Chat](#-endpoints-de-chat)
- [📜 Endpoints de Historial de Chat](#-endpoints-de-historial-de-chat)
- [🤖 Endpoints de Modelos de IA](#-endpoints-de-modelos-de-ia)
- [✨ Características Especiales](#-características-especiales)

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

#### 1. 📋 **GET**

**Descripción:** Obtiene todas las categorías del usuario autenticado  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros  
**Response:** Lista de categorías disponibles  
**Status:** `200 OK` si se listarón correctamente `401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 2. 📝 **GET** `/enroll`

**Descripción:** Obtiene todas las asignaciones de categorías (enrollments)  
**Query Params (opcionales):** `from`, `to`, `kind`  
**Response:** Lista de todas las asignaciones de categorías a perfiles  
**Status:** `200 OK` Se listó correctamente las categorias
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 3. 📊 **GET** `/report/{categoryId}`

**Descripción:** Genera un reporte detallado de una categoría específica  
**Path Variable:** `categoryId` (Integer) - ID de la categoría  
**Query Params (opcionales):** `from`, `to`, `kind`  
**Response:** `CategoryReportDTO` - Estadísticas y detalles de la categoría  
**Status:** `200 OK` Se litó correctamente el reporte `400 BAD REQUEST`
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 4. 📈 **GET** `/report/summary`

**Descripción:** Obtiene un resumen de todas las transacciones agrupadas por categoría  
**Query Params (opcionales):** `from`, `to`, `kind`  
**Response:** Resumen estadístico de transacciones por categoría  
**Status:** `200 OK` se listó correctamente el resumen
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 5. 🏢 **GET** `/enroll/user`

**Descripción:** Obtiene las asignaciones de categorías específicas para usuarios de tipo business  
**Query Params (opcionales):** `from`, `to`, `kind`  
**Response:** Lista de asignaciones de categorías para usuarios comerciales  
**Status:** `200 OK` Se listó correctamente las asiganciones `401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 6. ➕ **POST** `/add`

**Descripción:** Crea una nueva categoría  
**Body:** `NewCategoryDTO` - Datos de la nueva categoría  
**Funcionalidad:** Crea una categoría con presupuesto asignado y fechas  
**Status:** `201 CREATED` se creó correctamente la categoría `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 7. 📦 **POST** `/batch/add`

**Descripción:** Crea múltiples categorías en una sola operación  
**Body:** `List<NewCategoryDTO>` - Lista de categorías a crear  
**Funcionalidad:** Creación masiva de categorías  
**Status:** `201 CREATED` se crearón correctamente las categorías `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 8. 🔄 **PATCH** `/update`

**Descripción:** Actualiza una categoría existente  
**Body:** `CategoryDTO` - Datos actualizados de la categoría  
**Funcionalidad:** Modifica nombre, presupuesto, fechas y estado de la categoría  
**Status:** `201 CREATED` se actualizo correctamente la categoría `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 9. 📦 **PUT** `/batch/update`

**Descripción:** Actualiza múltiples categorías en una sola operación  
**Body:** `List<CategoryDTO>` - Lista de categorías a actualizar  
**Funcionalidad:** Actualización masiva de categorías  
**Status:** `201 CREATED` Si las categorías se crearon correctamente `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 10. 🔗 **POST** `/enroll/add`

**Descripción:** Asigna una categoría a un perfil específico  
**Query Params:**
- `profileId` (Integer) - ID del perfil
- `categoryId` (Integer) - ID de la categoría

**Response:** `CategoryEnrollmentDTO` - Detalles de la asignación  
**Status:** `201 CREATED` si se asigno correctamente la categoría `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 11. 🗑️ **DELETE** `/{id}`

**Descripción:** Elimina una categoría específica  
**Path Variable:** `id` (Integer) - ID de la categoría  
**Funcionalidad:** Eliminación lógica o física de la categoría  
**Status:** `204 NO CONTENT` se eliminó correctamente la categoría
`400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 12. 📦 **DELETE** `/batch`

**Descripción:** Elimina múltiples categorías en una sola operación  
**Query Param:** `id` (`List<Integer>`) - IDs de las categorías a eliminar  
**Funcionalidad:** Eliminación masiva de categorías  
**Response:** Mensaje con el número de categorías eliminadas  
**Status:** `204 NO CONTENT`  

#### 13. 🔗 **DELETE** `/enroll/{id}`

**Descripción:** Elimina una asignación de categoría a perfil  
**Path Variable:** `id` (Integer) - ID de la asignación  
**Funcionalidad:** Desvincula una categoría de un perfil específico  
**Status:** `204 NO CONTENT`  

---

## 💰 Endpoints de Transacciones

### `TransactionController.java` - Gestión de transacciones financieras

> **Base URL:** `/api/app/v1/transaction`

#### 1. 📋 **GET**

**Descripción:** Obtiene transacciones basadas en los parámetros proporcionados  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros  
**Funcionalidad:** 
- 👤 Para usuarios **PERSONAL**: Retorna sus transacciones directas
- 🏢 Para usuarios **BUSINESS**: Retorna transacciones de todos sus perfiles
- 👥 Para **PERFILES**: Retorna transacciones específicas del perfil

**Response:** Lista de transacciones o mensaje informativo  
**Status:** `200 OK`  se listó correctamente
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 2. 📈 **GET** `/report/summary`

**Descripción:** Obtiene un resumen estadístico de todas las transacciones  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros  
**Funcionalidad:** Solo disponible para usuarios (no perfiles)  
**Response:** `TransactionSummaryDTO` - Resumen estadístico agrupado  
**Status:** `200 OK` Se listó correctamente
`400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 3. 🏥 **GET** `/bancolombia/health`

**Descripción:** Verifica el estado de salud del servicio de Bancolombia  
**Funcionalidad:** Monitoreo del servicio externo de transacciones  
**Response:** Estado del servicio con timestamp  
**Status:** `200 OK` (UP) / `503 SERVICE_UNAVAILABLE` (DOWN)  

#### 4. 🏦 **POST** `/bancolombia`

**Descripción:** Obtiene transacciones desde Bancolombia mediante filtros específicos  
**Body:** `BancolombiaTransactionRequestDTO` - Criterios de filtrado de Bancolombia  
**Funcionalidad:** 
- 🔗 Integración con API de Bancolombia
- 📄 Genera URL de archivo con transacciones filtradas

**Response:** URL del archivo generado  
**Status:** `200 OK` Funciono correctamente `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 5. ➕ **POST** `/add`

**Descripción:** Registra una nueva transacción en el sistema  
**Body:** `NewTransactionDTO` - Datos de la nueva transacción  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 👤 Usuarios **PERSONAL**: Pueden crear transacciones directamente
- 🏢 Usuarios **BUSINESS**: Solo perfiles pueden crear transacciones
- 🔗 Asociación automática con categorías, presupuestos y deudas

**Status:** `201 CREATED` Se creó correctamente
 `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 6. 📦 **POST** `/batch/add`

**Descripción:** Registra múltiples transacciones en una sola operación  
**Body:** `List<NewTransactionDTO>` - Lista de transacciones a crear  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Creación masiva de transacciones para mayor eficiencia  
**Response:** Mensaje con número de transacciones creadas  
**Status:** `201 CREATED` Se crearón correctamente `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 7. 🔄 **PATCH** `/update`

**Descripción:** Actualiza una transacción existente en el sistema  
**Body:** `UpdateTransactionDTO` - Datos actualizados de la transacción  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** 
- 📝 Modifica campos de transacciones existentes
- 🔗 Actualiza asociaciones con categorías, presupuestos y deudas

**Status:** `201 CREATED` Se actualizo correctamente `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 8. 📦 **PUT** `/batch/update`

**Descripción:** Actualiza múltiples transacciones en una sola operación  
**Body:** `List<UpdateTransactionDTO>` - Lista de transacciones a actualizar  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Actualización masiva de transacciones  
**Status:** `201 CREATED` se actualizaron correctamente `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 9. 🗑️ **DELETE** `/{id}`

**Descripción:** Elimina una transacción específica por su ID  
**Path Variable:** `id` (Integer) - ID de la transacción  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Eliminación física de la transacción  
**Status:** `204 NO CONTENT` se eliminó correctamente
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 10. 📦 **DELETE** `/batch`

**Descripción:** Elimina múltiples transacciones en una sola operación  
**Query Param:** `id` (`List<Integer>`) - IDs de las transacciones a eliminar  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Eliminación masiva de transacciones  
**Response:** Mensaje con número de transacciones eliminadas  
**Status:** `204 NO CONTENT`  `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

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

#### 1. 📋 **GET** 

**Descripción:** Obtiene todos los presupuestos del usuario autenticado  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros  
**Autenticación:** ✅ Requerida  
**Response:** Lista de presupuestos con detalles completos  
**Status:** `200 OK` se listó correctamente
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 2. 📝 **GET** `/enroll`

**Descripción:** Obtiene todas las asignaciones de presupuestos (enrollments)  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros  
**Autenticación:** ✅ Requerida  
**Response:** `BudgetEnrollmentDTO` - Lista de asignaciones presupuesto-perfil  
**Status:** `200 OK` si se listo correctamente
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 3. 📈 **GET** `/report/comparison`

**Descripción:** Genera reporte comparativo de presupuesto vs gastos reales  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** 
- 📉 Compara presupuesto asignado vs gasto real
- 📈 Análisis de desviaciones y tendencias
- 📊 Identificación de categorías con mayor impacto

**Response:** `BudgetVsActualDTO` - Reporte comparativo detallado  
**Status:** `200 OK` si se listo correctamente
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 4. 📆 **GET** `/report/summary`

**Descripción:** Obtiene resumen ejecutivo de todos los presupuestos  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 💰 Total de presupuesto asignado
- 📉 Presupuesto utilizado
- 💵 Presupuesto disponible
- 📈 Porcentajes de utilización

**Response:** `BudgetSummaryDTO` - Resumen ejecutivo consolidado  
**Status:** `200 OK` si se listó correctamente`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 5. ➕ **POST** `/add`

**Descripción:** Crea un nuevo presupuesto en el sistema  
**Body:** `NewBudgetDTO` - Datos del nuevo presupuesto  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 📅 Definición de períodos presupuestarios
- 💰 Asignación de montos por categoría
- 🎨 Configuración de alertas y límites

**Status:** `201 CREATED` si se creo correctamente `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 6. 📦 **POST** `/batch/add`

**Descripción:** Crea múltiples presupuestos en una sola operación  
**Body:** `List<NewBudgetDTO>` - Lista de presupuestos a crear  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Creación masiva de presupuestos para planificación anual  
**Response:** Mensaje con número de presupuestos creados  
**Status:** `201 CREATED` si se crearón correctamente `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 7. 🔄 **PATCH** `/update`

**Descripción:** Actualiza un presupuesto existente  
**Body:** `BudgetDTO` - Datos actualizados del presupuesto  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 📝 Modificación de montos y períodos
- 🎨 Ajuste de configuraciones y alertas
- 🔄 Recalculo automático de métricas

**Status:** `201 CREATED` si se actualizo correctamente `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 8. 📦 **PUT** `/batch/update`

**Descripción:** Actualiza múltiples presupuestos en una sola operación  
**Body:** `List<BudgetDTO>` - Lista de presupuestos a actualizar  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Actualización masiva para ajustes estacionales  
**Status:** `201 CREATED` si se actualizaron correctamente `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 9. 🔗 **POST** `/enroll/add`

**Descripción:** Asigna un presupuesto a un perfil específico  
**Query Params:**
- `profileId` (Integer) - ID del perfil
- `budgetId` (Integer) - ID del presupuesto

**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 👥 Vinculación presupuesto-perfil
- 🔒 Control de acceso granular
- 📈 Seguimiento individualizado

**Response:** `BudgetEnrollmentDTO` - Detalles de la asignación  
**Status:** `201 CREATED` si se creo correctamente `400 BAD REQUEST` si los datos ingresados tienen un algun error
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 10. 🗑️ **DELETE** `/{id}`

**Descripción:** Elimina un presupuesto específico por su ID  
**Path Variable:** `id` (Integer) - ID del presupuesto  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Eliminación completa del presupuesto y sus asignaciones  
**Status:** `204 NO CONTENT`  si se elimino correctamente `401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 11. 📦 **DELETE** `/batch`

**Descripción:** Elimina múltiples presupuestos en una sola operación  
**Query Param:** `id` (`List<Integer>`) - IDs de los presupuestos a eliminar  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Eliminación masiva de presupuestos obsoletos  
**Response:** Mensaje con número de presupuestos eliminados  
**Status:** `204 NO CONTENT`  si se elimino correctamente
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 12. 🔗 **DELETE** `/enroll/{id}`

**Descripción:** Elimina una asignación de presupuesto a perfil  
**Path Variable:** `id` (Integer) - ID de la asignación  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Desvincula un presupuesto de un perfil específico  
**Status:** `204 NO CONTENT`  si se eliminarón correctamente
`401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

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

#### 1. 📋 **GET**

**Descripción:** Obtiene todas las deudas del usuario autenticado  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros  
**Autenticación:** ✅ Requerida  
**Response:** Lista completa de deudas con detalles y estado  
**Status:** `200 OK`  si se listó correctamente `401 UNAUTHORIZED` si no está autorizado y
`500 INTERNAL SERVER ERROR` problemas en el servidor

#### 2. 🏷️ **GET** `/state/{state}`

**Descripción:** Obtiene deudas filtradas por estado específico  
**Path Variable:** `state` (StateDebt) - Estado de la deuda  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros  
**Autenticación:** ✅ Requerida  
**Estados disponibles:**
- ✅ `ACTIVE` - Deudas activas
- ⏸️ `PAUSED` - Deudas pausadas
- ✅ `PAID` - Deudas pagadas
- ❌ `CANCELLED` - Deudas canceladas

**Response:** Lista de deudas filtradas por estado  
**Status:** `200 OK`  

#### 3. ⚠️ **GET** `/overdue`

**Descripción:** Obtiene todas las deudas vencidas (con fecha límite superada)  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 📅 Identifica deudas con fecha de vencimiento pasada
- ⚠️ Genera alertas de cobro prioritario
- 📈 Calcula intereses por mora

**Response:** Lista de deudas vencidas con detalles de mora  
**Status:** `200 OK`  

#### 4. ⏰ **GET** `/expiring-soon`

**Descripción:** Obtiene deudas que vencerán en los próximos días especificados  
**Query Param:** `days` (Integer) - Número de días para el filtro  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros adicionales  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 📅 Planificación de pagos futuros
- 🔔 Sistema de alertas preventivas
- 📊 Gestión de flujo de caja

**Response:** Lista de deudas próximas a vencer  
**Status:** `200 OK`  

#### 5. 💰 **GET** `/total-pending`

**Descripción:** Calcula el monto total pendiente de todas las deudas activas  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 💵 Suma de todas las deudas pendientes
- 📈 Indicador de salud financiera
- 📏 Resumen para presupuesto

**Response:** `BigDecimal` - Monto total pendiente  
**Status:** `200 OK`  

#### 6. 📈 **GET** `/report/summary`

**Descripción:** Genera reporte resumen completo de todas las deudas  
**Query Params (opcionales):** `from`, `to`, `kind` - Para filtros  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 📉 Distribución por estados
- 📈 Tendencias de pago
- ⚠️ Alertas y vencimientos
- 💰 Métricas financieras clave

**Response:** Reporte ejecutivo de deudas consolidado  
**Status:** `200 OK`  

#### 7. ➕ **POST** `/add`

**Descripción:** Registra una nueva deuda en el sistema  
**Body:** `NewDebtDTO` - Datos de la nueva deuda  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 📅 Definición de fechas de vencimiento
- 💵 Configuración de montos e intereses
- 🔔 Configuración de alertas automáticas
- 🏷️ Categorización y etiquetado

**Status:** `201 CREATED`  

#### 8. 📦 **POST** `/batch/add`

**Descripción:** Registra múltiples deudas en una sola operación  
**Body:** `List<NewDebtDTO>` - Lista de deudas a crear  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Importación masiva de deudas desde hojas de cálculo  
**Response:** Mensaje con número de deudas creadas  
**Status:** `201 CREATED`  

#### 9. 🔄 **PATCH** `/update`

**Descripción:** Actualiza una deuda existente  
**Body:** `DebtDTO` - Datos actualizados de la deuda  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 📝 Modificación de montos y fechas
- 🏷️ Cambio de categorías y etiquetas
- 🔔 Ajuste de configuraciones de alerta
- 📈 Recalculo automático de intereses

**Status:** `200 OK`  

#### 10. 📦 **PUT** `/batch/update`

**Descripción:** Actualiza múltiples deudas en una sola operación  
**Body:** `List<DebtDTO>` - Lista de deudas a actualizar  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Actualización masiva para renegociaciones o cambios globales  
**Status:** `200 OK`  

#### 11. 💳 **POST** `/payment`

**Descripción:** Registra un pago hacia una deuda específica  
**Body:** `DebtPaymentDTO` - Detalles del pago realizado  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 💵 Registro de pagos parciales o totales
- 📅 Actualización automática de saldos
- 📈 Cálculo de intereses y penalizaciones
- 🏷️ Cambio automático de estado si es necesario

**Status:** `200 OK`  

#### 12. 🏷️ **PATCH** `/{id}/state/{state}`

**Descripción:** Actualiza el estado de una deuda específica  
**Path Variables:**
- `id` (Integer) - ID de la deuda
- `state` (StateDebt) - Nuevo estado

**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- ✅ Activar deudas pausadas
- ⏸️ Pausar deudas temporalmente
- ❌ Cancelar deudas
- ✅ Marcar como pagadas

**Status:** `200 OK`  

#### 13. 🗑️ **DELETE** `/{id}`

**Descripción:** Elimina una deuda específica por su ID  
**Path Variable:** `id` (Integer) - ID de la deuda  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Eliminación completa de la deuda y su historial  
**Status:** `204 NO CONTENT`  

#### 14. 📦 **DELETE** `/batch`

**Descripción:** Elimina múltiples deudas en una sola operación  
**Query Param:** `id` (`List<Integer>`) - IDs de las deudas a eliminar  
**Autenticación:** ✅ Requerida  
**Funcionalidad:** Limpieza masiva de deudas canceladas u obsoletas  
**Response:** Mensaje con número de deudas eliminadas  
**Status:** `204 NO CONTENT`  

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
### 🔔 Endpoints de Notificaciones

### `NotificationController.java` - Sistema de notificaciones y alertas

> **Base URL:** `api/app/v1/notification`

#### 1. 📋 **GET**

**Descripción:** Obtiene todas las notificaciones del usuario autenticado  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 🔔 Notificaciones del sistema y alertas personalizadas
- 📅 Recordatorios de vencimientos y pagos
- 📊 Alertas de presupuesto y límites excedidos
- ⚠️ Notificaciones de seguridad y cambios de cuenta
- 📈 Actualizaciones de transacciones y movimientos

**Response:** Lista completa de notificaciones del usuario  
**Status:** `200 OK`  

**Tipos de notificaciones:**
- 💰 **Financieras**: Movimientos, presupuestos, límites
- 📅 **Vencimientos**: Deudas próximas a vencer, recordatorios
- 🔒 **Seguridad**: Cambios de contraseña, inicios de sesión
- 📈 **Reportes**: Resúmenes mensuales, actualizaciones
- ⚠️ **Alertas**: Gastos excesivos, actividad inusual

#### 2. 📅 **GET** `/range`

**Descripción:** Obtiene notificaciones del usuario filtradas por rango de fechas  
**Query Params:**
- `fromDate` (LocalDateTime) - Fecha de inicio (formato: yyyy-MM-dd'T'HH:mm:ss)
- `toDate` (LocalDateTime) - Fecha final (formato: yyyy-MM-dd'T'HH:mm:ss)

**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 📅 Filtrado preciso por rango temporal
- 🗓️ Consultas históricas de notificaciones
- 📈 Análisis de patrones de notificación
- 🔍 Búsqueda eficiente en grandes volúmenes

**Response:** Lista de notificaciones en el rango especificado  
**Status:** `200 OK`  

**Ejemplo de Query:**
```
GET /v1/notification/range?fromDate=2024-01-01T00:00:00&toDate=2024-01-31T23:59:59
```

#### 3. 🔍 **GET** `/search`

**Descripción:** Busca notificaciones del usuario por palabra clave  
**Query Param:** `keyword` (String) - Palabra clave para buscar  
**Autenticación:** ✅ Requerida  
**Funcionalidad:**
- 🔎 Búsqueda de texto completo en notificaciones
- 📝 Coincidencias en título, contenido y metadatos
- ⚡ Búsqueda rápida con indexación optimizada
- 🎯 Resultados relevantes y ordenados por coincidencia
- 🔄 Sugerencias automáticas y corrección de texto

**Response:** Lista de notificaciones que coinciden con la búsqueda  
**Status:** `200 OK`  

**Ejemplo de Query:**
```
GET /v1/notification/search?keyword=presupuesto
```

**Capacidades de búsqueda:**
- 📝 **Búsqueda parcial**: Encuentra coincidencias parciales
- 🔤 **Case-insensitive**: No distingue mayúsculas/minúsculas
- 🌐 **Múltiples idiomas**: Soporte para caracteres especiales
- 🔢 **Operadores**: AND, OR para búsquedas complejas
- 📅 **Filtros adicionales**: Combinable con filtros de fecha

### 🌟 **Características Especiales de Notificaciones**

| Característica | Descripción |
|----------------|-------------|
| 🔔 **Sistema Inteligente** | Notificaciones personalizadas basadas en comportamiento del usuario |
| 📅 **Filtrado Temporal** | Búsqueda precisa por rangos de fechas con formatos flexibles |
| 🔍 **Búsqueda Avanzada** | Motor de búsqueda de texto completo con coincidencias inteligentes |
| ⚡ **Tiempo Real** | Notificaciones instantáneas para eventos críticos |
| 🎯 **Categorización** | Clasificación automática por tipo y prioridad |
| 📈 **Analytics** | Métricas de engagement y efectividad de notificaciones |
| 🔒 **Seguridad** | Notificaciones de seguridad y auditoría de acceso |
| 🎨 **Personalización** | Configuración de preferencias y canales de notificación |

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

### ⚙️ **Configuración de Notificaciones**

- 🔔 **Canales**: Email, Push, SMS, In-App
- ⏰ **Horarios**: Configuración de horarios preferidos
- 🎯 **Prioridades**: Filtrado por nivel de importancia
- 🔇 **Modo Silencioso**: Desactivación temporal
- 🎨 **Plantillas**: Personalización de formato y estilo

### 📈 **Métricas y Analytics**

- 📈 **Tasa de Apertura**: Porcentaje de notificaciones leídas
- ⏱️ **Tiempo de Respuesta**: Velocidad de reacción del usuario
- 🎯 **Relevancia**: Efectividad de las notificaciones enviadas
- 🔄 **Frecuencia Óptima**: Análisis de patrones de engagement

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

## 💬 Endpoints de Chat

### `ChatController.java` - Sistema de inteligencia artificial para procesamiento de documentos financieros

> **Base URL:** `/api/chat/v1`

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

## 🤖 Endpoints de Modelos de IA

### `ModelController.java` - Gestión de modelos de inteligencia artificial disponibles

> **Base URL:** `/api/chat/v1/model`

#### 1. 🌐 **GET**

**Descripción:** Obtiene la lista completa de modelos de IA disponibles en el sistema  
**Autenticación:** 🔓 No requerida (sistema interno)  
**Funcionalidad:**
- 📋 Lista de todos los modelos de IA soportados
- 🎯 Identificadores únicos de cada modelo
- 📊 Información sobre capacidades disponibles
- ⚡ Verificación rápida de modelos activos
- 🔄 Actualización dinámica de disponibilidad

**Status:** `200 OK`  


### 🤖 **Modelos de IA Disponibles**

#### 🌌 **OPENAI**
- **Proveedor**: OpenAI (GPT-4 / GPT-3.5 Turbo)
- **Especialidades**:
  - 📝 **Procesamiento de Lenguaje Natural**: Comprensión avanzada de consultas complejas
  - 📊 **Análisis Financiero**: Interpretación de estados financieros y métricas
  - 📈 **Generación de Insights**: Recomendaciones estratégicas y análisis predictivo
  - 🌍 **Soporte Multi-idioma**: Procesamiento en español, inglés y otros idiomas
  - 📄 **Documentos Complejos**: Análisis de reportes financieros detallados

**Casos de uso ideales:**
- 📊 Análisis financiero complejo y detallado
- 📈 Generación de reportes narrativos
- 🔍 Consultas de planificación estratégica
- 🌐 Interacciones en múltiples idiomas

#### 🚀 **DEEPSEEK**
- **Proveedor**: DeepSeek (DeepSeek-Coder)
- **Especialidades**:
  - 📊 **Análisis Numérico**: Procesamiento eficiente de datos cuantitativos
  - 📄 **Documentos Estructurados**: Extracción rápida de datos de hojas de cálculo
  - ⚡ **Respuestas Optimizadas**: Procesamiento rápido con menor latencia
  - 💰 **Eficiencia de Costos**: Operación con costos reducidos
  - 📈 **Patrones de Datos**: Identificación de tendencias en grandes volúmenes

**Casos de uso ideales:**
- 📊 Cálculos financieros rápidos
- 📈 Análisis de tendencias y patrones
- 📄 Procesamiento masivo de transacciones
- ⚡ Respuestas en tiempo real

### 🌟 **Características Especiales de Modelos**

| Característica | Descripción |
|----------------|-------------|
| 🔄 **Disponibilidad Dinámica** | Lista actualizada en tiempo real de modelos activos |
| 🎯 **Selección Inteligente** | Recomendación automática del modelo óptimo según el tipo de consulta |
| 📊 **Especialización por Dominio** | Cada modelo optimizado para casos de uso específicos |
| ⚡ **Balanceador de Carga** | Distribución inteligente de consultas entre modelos disponibles |
| 💰 **Optimización de Costos** | Selección automática basada en eficiencia de costos |
| 🔍 **Monitoreo de Estado** | Verificación continua de disponibilidad y rendimiento |
| 🔄 **Fallback Automático** | Cambio automático a modelo alternativo en caso de fallas |
| 📈 **Métricas de Rendimiento** | Seguimiento de velocidad, precisión y satisfacción |

### 🎯 **Selección Automática de Modelos**

El sistema selecciona automáticamente el modelo más adecuado basado en:

#### 📊 **Tipo de Consulta**
- **Consultas Analíticas Complejas** → OpenAI (GPT-4)
- **Cálculos Numéricos Rápidos** → DeepSeek
- **Procesamiento de Documentos** → Modelo según formato y complejidad
- **Generación de Reportes** → OpenAI para narrativa, DeepSeek para datos

#### 🕰️ **Factores de Rendimiento**
- **Latencia Requerida**: Prioriza modelos rápidos para respuestas inmediatas
- **Precisión Necesaria**: Selecciona modelos con mayor exactitud para análisis críticos
- **Volumen de Datos**: Optimiza para procesamiento eficiente de grandes datasets
- **Complejidad de Contexto**: Utiliza modelos con mayor capacidad contextual

#### 💰 **Optimización de Recursos**
- **Costo por Consulta**: Balancea calidad vs costo operativo
- **Disponibilidad de API**: Selecciona modelos con mayor uptime
- **Límites de Rate**: Distribuye carga según límites de cada proveedor
- **Eficiencia Energética**: Considera impacto ambiental en la selección

### 📈 **Métricas y Monitoreo**

#### 📊 **Métricas de Rendimiento**
- **Tiempo de Respuesta Promedio**: Latencia por modelo y tipo de consulta
- **Tasa de Éxito**: Porcentaje de consultas procesadas exitosamente
- **Precisión de Respuestas**: Calidad y relevancia de las respuestas generadas
- **Satisfacción del Usuario**: Feedback y ratings de usuarios

#### 🔍 **Monitoreo de Disponibilidad**
- **Estado de APIs**: Verificación continua de conectividad
- **Health Checks**: Validación periódica de funcionalidad
- **Alertas Proactivas**: Notificaciones automáticas de fallos
- **Recuperación Automática**: Reintentos y fallbacks inteligentes

#### 💰 **Análisis de Costos**
- **Costo por Consulta**: Tracking detallado de gastos por modelo
- **Optimización de Uso**: Identificación de oportunidades de ahorro
- **Proyecciones de Gasto**: Estimaciones basadas en patrones de uso
- **ROI por Modelo**: Análisis de retorno de inversión

### 🔧 **Configuración Avanzada**


#### 🎯 **Estrategias de Fallback**
1. **Modelo Primario Falla** → Intenta modelo secundario
2. **Rate Limit Alcanzado** → Cambia a modelo alternativo
3. **Latencia Excesiva** → Escala a modelo más rápido
4. **Error de API** → Implementa retry con backoff exponencial

### 🔮 **Casos de Uso Específicos**

#### 📈 **Análisis Financiero Complejo**
**Modelo Recomendado**: OpenAI  
**Razón**: Mayor capacidad de razonamiento financiero y generación de insights estratégicos

#### ⚡ **Procesamiento Rápido de Transacciones**
**Modelo Recomendado**: DeepSeek  
**Razón**: Optimizado para cálculos numéricos y respuestas de baja latencia

#### 📄 **Análisis de Documentos Mixtos**
**Estrategia**: Híbrida  
**Enfoque**: DeepSeek para extracción de datos, OpenAI para interpretación y síntesis

#### 🌍 **Consultas Multi-idioma**
**Modelo Recomendado**: OpenAI  
**Razón**: Superior capacidad de procesamiento de lenguaje natural en múltiples idiomas

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
