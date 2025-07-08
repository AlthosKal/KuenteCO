# KuenteCO Frontend 📱

<p align="center">
  <img src="https://storage.googleapis.com/cms-storage-bucket/6a07d8a62f4308d2b854.svg" alt="Flutter Logo" height="100">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0+-blue?style=flat-square&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.0+-blue?style=flat-square&logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-orange?style=flat-square" alt="Architecture">
</p>

## 📱 Descripción

Este es el **frontend multiplataforma** de KuenteCO, desarrollado con **Flutter 3.0+**. Proporciona una experiencia de usuario fluida y nativa en Android, iOS y Web, conectándose de forma segura con la API REST del backend.

### ✨ Características Principales

- 📱 **Multiplataforma**: Android, iOS y Web desde un solo codebase
- 🎨 **UI/UX Moderno**: Diseño Material Design 3 y Cupertino
- 🔐 **Autenticación Segura**: JWT tokens con renovación automática
- 📊 **Gráficos Interactivos**: Visualización de datos financieros
- 🌙 **Tema Oscuro/Claro**: Soporte completo para ambos modos
- 🔄 **Sincronización**: Datos en tiempo real con el backend
- 💾 **Almacenamiento Local**: Cache seguro con Hive y SharedPreferences
- 🚫 **Modo Offline**: Funcionalidad básica sin conexión

---

## 🛠️ Stack Tecnológico

### Framework y Lenguaje
- **Flutter 3.0+** - Framework de desarrollo multiplataforma
- **Dart 3.0+** - Lenguaje de programación optimizado para UI

### Arquitectura y Patrones
- **Clean Architecture** - Separación clara de responsabilidades
- **Provider Pattern** - Gestión de estado reactiva
- **Repository Pattern** - Abstracción de fuentes de datos
- **SOLID Principles** - Principios de diseño de software

### Dependencias Principales

| Dependencia | Versión | Propósito |
|-------------|---------|----------|
| `flutter` | SDK | Framework base |
| `dio` | ^5.8.0 | Cliente HTTP avanzado |
| `provider` | ^6.1.3 | Gestión de estado |
| `hive_flutter` | ^1.1.0 | Base de datos NoSQL local |
| `flutter_secure_storage` | ^9.2.4 | Almacenamiento seguro |
| `shared_preferences` | ^2.5.3 | Preferencias del usuario |
| `flutter_dotenv` | ^5.2.1 | Variables de entorno |
| `permission_handler` | ^12.0.0 | Permisos del sistema |
| `toastification` | ^3.0.3 | Notificaciones toast |
| `iconsax` | ^0.0.8 | Biblioteca de iconos |

---

## 🚀 Configuración del Entorno

### 📋 Requisitos Previos

- **Flutter SDK** 3.0.0 o superior
- **Dart SDK** 3.0.0 o superior
- **Android Studio** / **Xcode** (para desarrollo móvil)
- **Chrome** (para desarrollo web)
- **Visual Studio Code** (recomendado)

### 🔧 Verificar Instalación

```bash
# Verificar instalación de Flutter
flutter doctor

# Verificar dispositivos disponibles
flutter devices

# Verificar versión
flutter --version
```

---

## 📦 Instalación y Configuración

### 1️⃣ Clonar el Repositorio

```bash
git clone https://github.com/AlthosKal/KuenteCO.git
cd KuenteCO/FRONT-END
```

### 2️⃣ Instalar Dependencias

```bash
# Obtener dependencias
flutter pub get

# Generar archivos de código (si es necesario)
flutter packages pub run build_runner build
```

### 3️⃣ Configurar Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto FRONT-END:

```bash
# API Configuration
API_BASE_URL=http://localhost:8080/api
API_TIMEOUT=30000

# App Configuration
APP_NAME=KuenteCO
APP_VERSION=1.0.0
ENVIRONMENT=development

# Debug Configuration
DEBUG_MODE=true
LOG_LEVEL=debug
```

### 4️⃣ Configurar Permisos

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Esta app necesita acceso a la cámara para capturar fotos de recibos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Esta app necesita acceso a la galería para seleccionar imágenes</string>
```

---

## 🎯 Ejecutar la Aplicación

### 📱 Desarrollo Móvil

```bash
# Android
flutter run -d android

# iOS (solo en macOS)
flutter run -d ios

# Dispositivo específico
flutter run -d <device_id>
```

### 🌐 Desarrollo Web

```bash
# Ejecutar en Chrome
flutter run -d chrome

# Construir para web
flutter build web

# Servir localmente
flutter run -d web-server --web-port=3000
```

### 🏗️ Builds de Producción

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (solo en macOS)
flutter build ios --release

# Web
flutter build web --release
```

---

## 📁 Estructura del Proyecto

```
lib/
├── 🎯 main.dart                 # Punto de entrada de la app
├── 🎨 core/                     # Configuraciones centrales
│   ├── constants/               # Constantes de la app
│   ├── themes/                  # Temas y estilos
│   ├── utils/                   # Utilidades globales
│   └── errors/                  # Manejo de errores
├── 📊 dto/                      # Data Transfer Objects
│   ├── request/                 # DTOs de peticiones
│   └── response/                # DTOs de respuestas
├── 🎮 controllers/              # Lógica de negocio
│   ├── auth_controller.dart     # Autenticación
│   ├── transaction_controller.dart
│   └── user_controller.dart
├── 🔗 provider/                 # Gestión de estado
│   ├── auth_provider.dart
│   ├── theme_provider.dart
│   └── data_provider.dart
├── 🛣️ routes/                   # Configuración de rutas
│   └── app_routes.dart
├── 📱 screens/                  # Pantallas de la app
│   ├── auth/                    # Autenticación
│   ├── dashboard/               # Panel principal
│   ├── transactions/            # Transacciones
│   ├── profile/                 # Perfil de usuario
│   └── settings/                # Configuraciones
├── 🧩 widgets/                  # Componentes reutilizables
│   ├── common/                  # Widgets comunes
│   ├── forms/                   # Formularios
│   └── charts/                  # Gráficos
└── 🔧 utils/                    # Utilidades específicas
    ├── helpers/                 # Funciones auxiliares
    ├── extensions/              # Extensiones de Dart
    └── validators/              # Validadores de formularios
```

---

## 🔌 Integración con Backend

### 🌐 Configuración de API

La aplicación se conecta al backend a través de HTTP usando Dio:

```dart
// Configuración base en core/api/api_client.dart
class ApiClient {
  static const String baseUrl = 'http://localhost:8080/api';
  static const int timeoutDuration = 30000;
  
  static Dio get instance {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: timeoutDuration),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Interceptors para logging y autenticación
    dio.interceptors.addAll([
      LogInterceptor(),
      AuthInterceptor(),
    ]);
    
    return dio;
  }
}
```

### 🔐 Autenticación JWT

```dart
// Manejo automático de tokens JWT
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = AuthService.instance.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
```

### 📊 Endpoints Principales

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/auth/login` | POST | Inicio de sesión |
| `/auth/register` | POST | Registro de usuario |
| `/users/profile` | GET | Perfil del usuario |
| `/transactions` | GET/POST | Gestión de transacciones |
| `/categories` | GET | Categorías disponibles |
| `/reports` | GET | Reportes financieros |

---

## 🧪 Testing

### 🔍 Ejecutar Tests

```bash
# Tests unitarios
flutter test

# Tests con cobertura
flutter test --coverage

# Tests de integración
flutter test integration_test/

# Tests específicos
flutter test test/controllers/auth_controller_test.dart
```

### 📊 Tipos de Tests

- **Unit Tests**: Lógica de negocio y funciones puras
- **Widget Tests**: Pruebas de componentes UI
- **Integration Tests**: Flujos completos de usuario
- **Golden Tests**: Pruebas visuales de widgets

---

## 🎨 Personalización de Tema

### 🌟 Temas Disponibles

La aplicación soporta temas claro y oscuro:

```dart
// En lib/core/themes/app_theme.dart
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      brightness: Brightness.light,
    ),
    // ... configuración del tema claro
  );
  
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E88E5),
      brightness: Brightness.dark,
    ),
    // ... configuración del tema oscuro
  );
}
```

---

## 🚀 Despliegue

### 📱 Android

```bash
# Generar APK firmado
flutter build apk --release --target-platform android-arm64

# Generar App Bundle (recomendado para Play Store)
flutter build appbundle --release
```

### 🍎 iOS

```bash
# Generar build para App Store
flutter build ios --release --no-codesign

# Abrir en Xcode para firmar y subir
open ios/Runner.xcworkspace
```

### 🌐 Web

```bash
# Build optimizado para web
flutter build web --release --web-renderer html

# Los archivos están en build/web/
```

---

## 🐛 Debugging y Troubleshooting

### 🔍 Comandos Útiles

```bash
# Limpiar proyecto
flutter clean && flutter pub get

# Analizar código
flutter analyze

# Formatear código
flutter format .

# Inspector de widgets
flutter inspector

# Logs detallados
flutter run --verbose
```

### ⚠️ Problemas Comunes

1. **Gradle Build Failed**: Limpiar cache con `flutter clean`
2. **CocoaPods Issues**: `cd ios && pod install`
3. **Web CORS**: Configurar proxy o usar `--web-browser-flag="--disable-web-security"`
4. **Hot Reload No Funciona**: Reiniciar con `r` en terminal

---

## 📚 Recursos Útiles

- 📖 **[Flutter Docs](https://docs.flutter.dev/)**
- 🎯 **[Dart Language](https://dart.dev/)**
- 🎨 **[Material Design 3](https://m3.material.io/)**
- 🍎 **[Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)**
- 📱 **[Flutter Samples](https://flutter.github.io/samples/)**

---

## 🤝 Contribuir

Para contribuir al frontend:

1. Seguir las [convenciones de código](https://dart.dev/guides/language/effective-dart)
2. Escribir tests para nuevas funcionalidades
3. Mantener compatibilidad multiplataforma
4. Documentar cambios en la UI/UX

---

<p align="center">
  <b>🎨 Frontend desarrollado con ❤️ usando Flutter</b>
</p>
