# Sistema de Autenticación para WhatsApp e IVR

## Descripción General

Se ha implementado un sistema completo de autenticación para usuarios que interactúan con el asistente financiero KuenteCO a través de WhatsApp o llamadas IVR. Este sistema garantiza que solo usuarios autenticados puedan acceder a sus datos financieros.

## Componentes Principales

### 1. SessionManager (`service/session/SessionManager.java`)

Gestiona el estado de las sesiones de usuario:

- **Almacenamiento en memoria**: Usa `ConcurrentHashMap` para almacenar sesiones por identificador (número de teléfono o CallSid)
- **Estados de sesión**:
  - `AWAITING_CREDENTIALS`: Usuario no autenticado, esperando credenciales
  - `AUTHENTICATED`: Usuario autenticado exitosamente
  - `BLOCKED`: Usuario bloqueado por múltiples intentos fallidos

- **Funcionalidades**:
  - Crear/obtener sesiones
  - Autenticar sesiones (guarda el token JWT)
  - Registrar intentos fallidos (máximo 2 intentos)
  - Bloqueo temporal de 1 hora tras exceder intentos
  - Limpieza automática de sesiones expiradas cada hora

### 2. AuthenticationService (`service/auth/AuthenticationService.java`)

Maneja la lógica de autenticación:

- **Extracción de credenciales**: Usa expresiones regulares para extraer email/usuario y contraseña del mensaje del usuario
- **Formatos soportados**:
  ```
  usuario: tu_email, contraseña: tu_password
  correo: user@example.com, password: mypass123
  email: test@test.com clave: secret
  ```

- **Autenticación**: Llama al endpoint `AUTH_USER` del backend principal usando `KuentecoAppConnector`
- **Mensajes personalizados**: Genera mensajes apropiados según el resultado de la autenticación

### 3. Integración en Servicios

#### WhatsAppMessageServiceImpl

```java
@Override
public void handleIncomingMessage(String from, String body) {
    String responseMessage;

    // Verificar autenticación
    if (!sessionManager.isAuthenticated(from)) {
        LoginDTO credentials = authenticationService.extractCredentials(body);
        if (credentials != null) {
            responseMessage = authenticationService.authenticateUser(from, credentials);
        } else {
            responseMessage = authenticationService.requestCredentials(from);
        }
    } else {
        // Procesar consulta normal
        ChatClient chatClient = getChatClientForConversation(from);
        responseMessage = generateResponse(body, chatClient);
    }

    sendWhatsAppMessage(from, responseMessage);
}
```

#### IvrCallServiceImpl

Similar al flujo de WhatsApp, pero adaptado para llamadas de voz:

```java
@Override
public String processSpeech(String speechResult, String callSid) {
    String responseMessage;

    if (!sessionManager.isAuthenticated(callSid)) {
        LoginDTO credentials = authenticationService.extractCredentials(speechResult);
        if (credentials != null) {
            responseMessage = authenticationService.authenticateUser(callSid, credentials);
        } else {
            responseMessage = authenticationService.requestCredentials(callSid);
        }
    } else {
        ChatClient chatClient = getChatClientForCall(callSid);
        responseMessage = generateResponse(speechResult, chatClient);
    }

    return buildVoiceResponse(responseMessage);
}
```

## Flujo de Autenticación

### Caso de Uso: Usuario se conecta por primera vez

1. **Usuario envía mensaje**: "Hola"
2. **Sistema verifica autenticación**: No autenticado (estado: `AWAITING_CREDENTIALS`)
3. **Sistema responde**: "Bienvenido al asistente financiero de KuenteCO. Para comenzar, por favor proporciona tus credenciales en el formato: 'usuario: tu_email, contraseña: tu_password'"
4. **Usuario envía credenciales**: "usuario: john@example.com, contraseña: mypassword123"
5. **Sistema extrae credenciales** usando regex
6. **Sistema llama al endpoint de autenticación**: `POST /auth/login`
7. **Si es exitoso**:
   - Guarda el token JWT en la sesión
   - Cambia estado a `AUTHENTICATED`
   - Responde: "¡Autenticación exitosa! Ahora puedes consultarme sobre tus finanzas. ¿En qué puedo ayudarte?"
8. **Usuario puede hacer consultas**: "¿Cuál es mi balance?"

### Caso de Uso: Credenciales incorrectas

1. **Usuario envía credenciales incorrectas**: "usuario: wrong@email.com, contraseña: wrongpass"
2. **Sistema intenta autenticar**: Falla
3. **Sistema registra intento fallido**: 1/2 intentos
4. **Sistema responde**: "Credenciales incorrectas. Te quedan 1 intento(s). Por favor, proporciona tu correo o nombre de usuario y contraseña nuevamente."
5. **Si falla 2 veces**:
   - Estado cambia a `BLOCKED`
   - `blockedUntil` = ahora + 1 hora
   - Responde: "Has excedido el número máximo de intentos de autenticación. Tu sesión ha sido bloqueada temporalmente por 1 hora."

### Caso de Uso: Usuario bloqueado intenta autenticarse

1. **Usuario bloqueado envía mensaje**: "Hola"
2. **Sistema verifica**: Estado `BLOCKED` y `blockedUntil` en el futuro
3. **Sistema responde**: "Tu sesión está bloqueada temporalmente debido a múltiples intentos fallidos de autenticación. Por favor, intenta más tarde."

## Limpieza y Mantenimiento

### Limpieza Automática de Sesiones

El `SessionManager` ejecuta una tarea programada cada hora (`@Scheduled(fixedRate = 3600000)`):

- Elimina sesiones no autenticadas con más de 24 horas
- Elimina sesiones bloqueadas cuyo bloqueo expiró hace más de 24 horas

### Limpieza de Conversaciones Inactivas

WhatsApp e IVR limpian conversaciones inactivas:

- **WhatsApp**: Cada 24 horas, elimina conversaciones sin actividad en 30 minutos
- **IVR**: Cuando la llamada termina (`cleanupCall`)

En ambos casos, también se limpia la sesión del `SessionManager`.

## Datos Almacenados en la Sesión

```java
public static class Session {
    private String identifier;        // Número de teléfono o CallSid
    private SessionState state;       // AWAITING_CREDENTIALS, AUTHENTICATED, BLOCKED
    private String email;             // Email del usuario autenticado
    private String token;             // JWT token del usuario
    private Integer failedAttempts;   // Número de intentos fallidos
    private LocalDateTime createdAt;  // Fecha de creación de la sesión
    private LocalDateTime authenticatedAt; // Fecha de autenticación exitosa
    private LocalDateTime blockedUntil;    // Fecha hasta la cual está bloqueado
}
```

## Configuración

No se requiere configuración adicional. El sistema usa los endpoints ya configurados en `KuentecoEndpoint`:

```java
AUTH_USER("auth", "login")
```

## Seguridad

- **Tokens JWT**: Se almacenan en memoria y pueden usarse para llamadas subsecuentes al backend
- **Bloqueo temporal**: Previene ataques de fuerza bruta (máximo 2 intentos)
- **Limpieza automática**: Previene acumulación de datos en memoria
- **No persistencia**: Las sesiones no se guardan en base de datos (se pierden al reiniciar la app)

## Mejoras Futuras Sugeridas

1. **Persistencia de sesiones**: Guardar en Redis o base de datos
2. **Timeout de sesión**: Expirar sesiones después de X tiempo sin actividad
3. **Renovación de tokens**: Implementar refresh tokens
4. **Logging de seguridad**: Registrar todos los intentos de autenticación
5. **Notificaciones**: Enviar alerta al usuario cuando su cuenta es bloqueada
6. **Rate limiting**: Limitar número de mensajes por minuto
7. **2FA**: Implementar autenticación de dos factores

## Ejemplo de Uso

### WhatsApp

```
Usuario: Hola
Bot: Bienvenido al asistente financiero de KuenteCO. Para comenzar, por favor
     proporciona tus credenciales en el formato: 'usuario: tu_email, contraseña: tu_password'

Usuario: usuario: john@kuenteco.com, contraseña: SecurePass123
Bot: ¡Autenticación exitosa! Ahora puedes consultarme sobre tus finanzas. ¿En qué puedo ayudarte?

Usuario: ¿Cuál es mi balance del mes?
Bot: [Respuesta con datos financieros...]
```

### IVR (Llamada de Voz)

```
Usuario: [Llama al número de Twilio]
Bot: "Bienvenido, soy tu asistente financiero. Estoy aquí para ayudarte"

Usuario: "Hola, quiero saber mi balance"
Bot: "Bienvenido al asistente financiero de KuenteCO. Para comenzar, por favor
     proporciona tus credenciales diciendo usuario seguido de tu correo, y contraseña
     seguida de tu clave"

Usuario: "usuario john@kuenteco.com, contraseña SecurePass123"
Bot: "¡Autenticación exitosa! Ahora puedes consultarme sobre tus finanzas. ¿En qué puedo ayudarte?"

Usuario: "¿Cuál es mi balance del mes?"
Bot: [Responde con datos financieros...]
```

## Cambios en KuentecoAppConnector

Se realizaron mejoras al `KuentecoAppConnector` para soportar autenticación sin token:

### Método Sobrecargado

Se agregó un método sobrecargado `call()` que permite especificar:

```java
public <T> ApiResponse<T> call(
        KuentecoEndpoint endpoint,
        Map<String, String> queryParams,
        TypeReference<T> typeReference,
        String httpMethod,        // "GET" o "POST"
        boolean requiresAuth)     // true o false
```

### Características

1. **Método HTTP dinámico**: Ahora soporta GET y POST
2. **Token opcional**: El header `Authorization` solo se agrega si `requiresAuth=true` y hay un token disponible
3. **Logging mejorado**: Registra el método HTTP utilizado y si se agregó el header de autorización

### Nuevo Método: `callWithBody()`

Para endpoints que requieren datos en el body (como login):

```java
public <T> ApiResponse<T> callWithBody(
        KuentecoEndpoint endpoint,
        Object requestBody,          // Objeto que se serializa a JSON
        TypeReference<T> typeReference,
        boolean requiresAuth)
```

### Uso para Autenticación

El `AuthenticationService` ahora usa `callWithBody()` para enviar las credenciales en el body del POST:

```java
// Las credenciales se envían como JSON en el body
ApiResponse<TokenResponseDTO> response = kuentecoAppConnector.callWithBody(
        KuentecoEndpoint.AUTH_USER,
        credentials,  // LoginDTO con nameOrEmail y password
        new TypeReference<>() {},
        false);       // No requiere autenticación

// Esto genera una petición:
// POST http://localhost:8080/api/app/v1/auth/login
// Content-Type: application/json
// Body: {"nameOrEmail": "usuario_negocio", "password": "patodeganso"}
```

## Troubleshooting

### Error: "405 Method Not Allowed"

**Causa**: El conector estaba usando GET cuando el endpoint requiere POST.

**Solución**: Ya corregido. Ahora `AuthenticationService` especifica `"POST"` y `requiresAuth=false` al llamar al endpoint de autenticación.

### Error: "Not all template variables were replaced"

**Causa**: El prompt template contiene variables sin reemplazar.

**Solución**: Ya corregido. El template ahora solo usa la variable `{prompt}`.

### Error: Sesiones no se limpian

**Causa**: El scheduler no está habilitado.

**Solución**: Asegurar que `@EnableScheduling` esté presente en la clase principal de la aplicación.

### Error: No se pueden extraer credenciales

**Causa**: El usuario no está proporcionando las credenciales en el formato correcto.

**Solución**: El `AuthenticationService` usa múltiples patrones regex. Si el usuario proporciona un email válido, intenta extraer la contraseña del resto del mensaje.
