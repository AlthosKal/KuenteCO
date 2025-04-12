<p align="left">
  <img src="https://raw.githubusercontent.com/dnfield/flutter_svg/7d374d7107561cbd906d7c0ca26fef02cc01e7c8/example/assets/flutter_logo.svg?sanitize=true" alt="Logo de KuenteCO" height="30%" width="10%">
</p>

# FRONT-END

Este módulo corresponde al **Front-End de KuenteCO**, desarrollado con **Flutter**, orientado a ofrecer una experiencia rápida, fluida y multiplataforma tanto para usuarios particulares como para pequeños negocios.

La aplicación ofrece interfaces amigables y altamente responsivas, adaptadas para dispositivos móviles, tablets y navegadores web modernos. Está diseñada con enfoque en accesibilidad, usabilidad y rendimiento.

---

## 🎯 Requisitos del entorno

Asegúrate de tener instalado lo siguiente para comenzar con el desarrollo o ejecución de esta app:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.13 o superior recomendado)
- Dart SDK (incluido con Flutter)
- Android Studio, Intellij IDEA "tanto Community como Ultimate" o Visual Studio Code
- Emulador Android o dispositivo físico (para pruebas móviles)
- Navegador web (para pruebas web)
- Cuenta de desarrollador en Firebase (para autenticación y futuras integraciones, próximamente)

---

## 🚀 Instrucciones para levantar el proyecto

1. **Clonar el repositorio y posicionarse en la carpeta del front-end:**

```bash
git clone https://github.com/AlthosKal/KuenteCO.git
cd KuenteCO/FRONT-END
```


2. **Instalar las dependencias:**

```bash
flutter pub get
```

3. **Levantar la aplicación:**

- Para Web:

```bash
flutter run -d chrome
```

- Para Android:

```bash
flutter run -d emulator-5554
```

> [!NOTE]  
> Asegúrate de que tu emulador esté activo o tu navegador esté disponible.

---

## 📁 Estructura del proyecto

```text
FRONT-END/
│
├── lib/
│   ├── main.dart            # Punto de entrada principal
│   ├── routes/              # Configuración de rutas
│   ├── screens/             # Vistas principales
│   ├── widgets/             # Componentes reutilizables
│   ├── models/              # Modelos de datos
│   └── services/            # Lógica de conexión con la API
│
├── assets/                 # Imágenes, íconos y estilos
├── pubspec.yaml            # Archivo de configuración del proyecto
└── README.md               # Este archivo
```

---

## 🔗 Conexión con el Back-End

La aplicación se comunica con la API de **Spring Boot** a través de llamadas HTTP. Las rutas están configuradas dentro del archivo de servicios (`services/`), y utilizan autenticación mediante **JWT**, para la conexión, ésta se tiene que brindar por medio de un archivo **.env**.

**Ejemplo base de conexión:**

```env
API_URL="http://localhost:8080/api/";
```

---

## 📦 Funcionalidades clave del Front-End

- Registro e inicio de sesión de usuarios
- Gestión de transacciones (ingresos / egresos)
- Visualización de presupuestos y estadísticas
- Administración de perfil y configuración personal
- Diseño responsivo y adaptado a Flutter Web + Mobile

---

> [!NOTE]  
> Próximamente se añadirá compatibilidad con notificaciones push y almacenamiento en Firebase.

---

## 🧩 Configuración adicional

Si deseas realizar builds para producción o probar en diferentes dispositivos, revisa la [documentación oficial de Flutter](https://docs.flutter.dev/) para más detalles sobre el despliegue multiplataforma.
