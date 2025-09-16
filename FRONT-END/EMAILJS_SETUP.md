# 📧 Configuración de EmailJS para KuenteCO

## ¿Qué es EmailJS?
EmailJS permite enviar emails directamente desde aplicaciones frontend (como Flutter Web) sin necesidad de un servidor backend.

## Pasos para configurar EmailJS:

### 1. Crear cuenta en EmailJS
1. Ve a [EmailJS.com](https://www.emailjs.com/)
2. Regístrate con tu email
3. Confirma tu email

### 2. Configurar un servicio de email
1. En el dashboard, ve a **"Email Services"**
2. Haz clic en **"Add New Service"**
3. Selecciona **Gmail** (recomendado)
4. Configura:
   - **Service ID**: `service_kuenteco` (puedes usar otro nombre)
   - **User ID**: tu email de Gmail
   - **Access Token**: genera uno desde tu cuenta de Google
5. Guarda el servicio

### 3. Crear un template de email
1. Ve a **"Email Templates"**
2. Haz clic en **"Create New Template"**
3. Configura:
   - **Template ID**: `template_contact`
   - **Template Name**: "KuenteCO Contact Form"
4. En el contenido del template, puedes usar la plantilla HTML personalizada con estas variables:
   - `{{nombreCompleto}}` - para el nombre del remitente
   - `{{correoElectronico}}` - para el email del remitente
   - `{{asunto}}` - para el asunto del mensaje
   - `{{mensaje}}` - para el contenido del mensaje
5. En **"Settings"**:
   - **To Email**: KuenteCO@yopmail.com (o tu email de destino)
   - **Reply To**: {{correoElectronico}}

### 4. Obtener tu Public Key
1. Ve a **"Account"** en la barra lateral
2. Copia tu **Public Key** (User ID)

### 5. Actualizar el archivo .env
Reemplaza estos valores en tu archivo `.env`:

```env
# 📧 EMAILJS CONFIGURATION
EMAILJS_SERVICE_ID=service_kuenteco  # El Service ID que creaste
EMAILJS_TEMPLATE_ID=template_contact # El Template ID que creaste
EMAILJS_PUBLIC_KEY=tu_public_key_aqui # Tu Public Key de EmailJS
```

### 6. Probar la configuración
1. Ejecuta `flutter run -d chrome` para probar en web
2. Ve a la página de contacto
3. Llena el formulario y envía un mensaje
4. Revisa la consola para ver si hay errores
5. Revisa tu email de destino

## Limitaciones del plan gratuito de EmailJS:
- 200 emails por mes
- Marca de EmailJS en los emails

## Variables disponibles en el template:
- `{{nombreCompleto}}` - Nombre completo del remitente
- `{{correoElectronico}}` - Email del remitente  
- `{{asunto}}` - Asunto del mensaje
- `{{mensaje}}` - Contenido del mensaje
- `{{to_email}}` - Email de destino (configurado automáticamente)
- `{{reply_to}}` - Email para responder (configurado automáticamente)

## Solución de problemas:

### Error 400 - Bad Request
- Verifica que el Service ID y Template ID sean correctos
- Asegúrate de que las variables del template coincidan

### Error 401 - Unauthorized  
- Verifica tu Public Key
- Asegúrate de que el servicio esté configurado correctamente

### Error 402 - Payment Required
- Has excedido el límite de emails gratuitos
- Considera actualizar a un plan pagado

### El email no llega
- Revisa la carpeta de spam
- Verifica que el email de destino sea correcto
- Revisa los logs de EmailJS en su dashboard