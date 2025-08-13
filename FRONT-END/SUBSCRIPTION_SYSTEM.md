# 📋 Sistema de Suscripciones - KuenteCO Frontend

## 🏗️ Arquitectura Completa

El sistema de suscripciones del frontend está completamente integrado con el backend y maneja todos los aspectos de la gestión de planes de suscripción.

### 📁 Estructura de Archivos

```
lib/
├── app/controllers/
│   └── subscription_controller.dart          # Controlador principal
├── core/services/app/
│   └── subscription_service.dart             # Servicio API REST
├── dto/subscription/
│   ├── request/
│   │   └── create_subscription_request_dto.dart
│   ├── response/
│   │   ├── subscription_response_dto.dart
│   │   ├── create_subscription_response_dto.dart
│   │   └── payment_history_response_dto.dart
│   └── subscription_price_config_dto.dart
├── screens/
│   └── subscriptions_view.dart               # Vista de suscripciones
└── utils/enum/
    └── subscription_type_enum.dart           # Enum unificado
```

## 🔧 Componentes Principales

### 1. **SubscriptionController** 
**Ubicación:** `lib/app/controllers/subscription_controller.dart`

**Responsabilidades:**
- Gestionar el estado de las suscripciones del usuario
- Comunicarse con el backend a través del servicio
- Proporcionar configuraciones de fallback
- Manejar estados de carga y errores

**Estados principales:**
```dart
enum SubscriptionControllerState {
  initial,
  loading, 
  loaded,
  error,
}
```

**Métodos clave:**
- `init()` - Inicializar y cargar datos del backend
- `loadMySubscriptions()` - Obtener suscripciones del usuario
- `createSubscription(SubscriptionType)` - Crear nueva suscripción
- `canUpgradeTo(SubscriptionType)` - Verificar si puede cambiar de plan
- `availableConfigs` - Obtener configuraciones disponibles

### 2. **SubscriptionService**
**Ubicación:** `lib/core/services/app/subscription_service.dart`

**Endpoints integrados:**
- `GET /subscription/my-subscriptions` - Obtener suscripciones del usuario
- `GET /subscription/price-configs` - Obtener configuración de precios
- `POST /subscription` - Crear nueva suscripción
- `GET /subscription/{id}` - Obtener detalles de suscripción
- `DELETE /subscription/{id}/cancel` - Cancelar suscripción
- `PATCH /subscription/{id}/reactivate` - Reactivar suscripción

**Manejo de errores:**
- Fallback a configuración por defecto si el backend no está disponible
- Manejo graceful de usuarios sin suscripciones
- Logging detallado para debugging

### 3. **SubscriptionPlansView**
**Ubicación:** `lib/screens/subscriptions_view.dart`

**Características:**
- ✅ Diseño responsivo (mobile y desktop)
- ✅ Estados de carga con indicadores visuales
- ✅ Planes dinámicos desde el backend
- ✅ Fallback a configuración estática
- ✅ Badge visual para plan actual
- ✅ Botones inteligentes (solo upgrades permitidos)
- ✅ Mensajes de error y éxito
- ✅ Glassmorphism design

## 📊 DTOs y Modelos

### SubscriptionResponseDTO
```dart
class SubscriptionResponseDTO {
  final int subscriptionId;
  final SubscriptionType subscriptionType;
  final double monthlyAmount;
  final State subscriptionState;
  // ... más campos
}
```

### SubscriptionConfig (Interno)
```dart
class SubscriptionConfig {
  final SubscriptionType type;
  final String name;
  final double price;
  final String currency;
  final List<String> features;
}
```

## 🎯 Tipos de Suscripción

```dart
enum SubscriptionType {
  BASIC,    // Plan gratuito con funciones limitadas
  STANDARD, // Plan intermedio sin anuncios
  PREMIUM,  // Plan completo con todas las funciones
}
```

## 🔄 Flujo de Datos

1. **Inicialización:**
   ```
   SubscriptionController.init() 
   ├── Cargar configuración estática (fallback)
   ├── loadMySubscriptions() → API call
   ├── loadPriceConfigs() → API call
   └── Actualizar estado UI
   ```

2. **Cambio de Plan:**
   ```
   Usuario hace click en "Cambiar Plan"
   ├── Verificar canUpgradeTo()
   ├── createSubscription() → API call
   ├── Actualizar suscripciones locales
   └── Mostrar mensaje de confirmación
   ```

## 🛠️ Características Implementadas

### ✅ **Funcionalidades Core**
- [x] Visualización de planes disponibles
- [x] Detección de plan actual del usuario
- [x] Creación de nuevas suscripciones
- [x] Estados de carga y error
- [x] Validación de upgrades/downgrades

### ✅ **Integración Backend**
- [x] Llamadas REST API completas
- [x] Manejo de respuestas del servidor
- [x] Fallback graceful si backend no disponible
- [x] Sincronización de estado

### ✅ **UX/UI**
- [x] Diseño responsivo
- [x] Estados visuales claros
- [x] Mensajes informativos
- [x] Botones contextuales
- [x] Indicadores de carga

### ✅ **Manejo de Errores**
- [x] Errores de red
- [x] Errores de validación
- [x] Estados sin suscripciones
- [x] Fallback a datos estáticos

## 🔧 Configuración por Defecto

Si el backend no está disponible, el sistema usa esta configuración:

```dart
static final List<SubscriptionConfig> _defaultConfigs = [
  SubscriptionConfig(
    type: SubscriptionType.BASIC,
    name: 'Básico',
    price: 0.0,
    currency: 'COP',
    features: [
      'Contiene anuncios',
      'Algunas funciones están limitadas', 
      'Solo puedes crear hasta 4 rubros',
      'Acceso a 3 perfiles',
    ],
  ),
  // ... STANDARD y PREMIUM
];
```

## 🚀 Cómo Usar

### En la vista:
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final SubscriptionController _controller = SubscriptionController();

  @override
  void initState() {
    super.initState();
    _controller.init(); // Carga datos automáticamente
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SubscriptionControllerState>(
      valueListenable: _controller.state,
      builder: (context, state, child) {
        if (state == SubscriptionControllerState.loading) {
          return CircularProgressIndicator();
        }
        
        // Mostrar planes disponibles
        return _buildPlans(_controller.availableConfigs);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // ¡Importante!
    super.dispose();
  }
}
```

## 🐛 Debugging

### Logs importantes:
```dart
// En consola del navegador/app
debugPrint('Info: Usuario sin suscripciones - $e');
debugPrint('Info: Usando configuración de precios por defecto - $e'); 
debugPrint('Warning: Error al inicializar suscripciones (usando fallback): $e');
```

### Estados a verificar:
- `_controller.state.value` - Estado del controlador
- `_controller.mySubscriptions.value` - Lista de suscripciones
- `_controller.activeSubscription` - Suscripción activa actual
- `_controller.errorMessage.value` - Mensajes de error

## 🔄 Próximas Mejoras

### Pendientes:
- [ ] Tests unitarios completos
- [ ] Manejo de webhooks de pagos
- [ ] Historial de pagos en la UI
- [ ] Cancelación/reactivación desde la UI
- [ ] Notificaciones push para cambios de estado
- [ ] Análitics de conversión de planes

### Optimizaciones:
- [ ] Cache de configuraciones
- [ ] Retry automático en fallos de red
- [ ] Estados de loading más granulares
- [ ] Animaciones de transición

---

## 📝 Resumen Técnico

**Estado Actual:** ✅ **COMPLETAMENTE INTEGRADO**

- **Servicio:** Comunicación real con backend REST API
- **Controlador:** Estado reactivo sincronizado con backend  
- **Vista:** UI moderna, responsiva y funcional
- **Manejo de Errores:** Robusto con fallbacks
- **DTOs:** Unificados y consistentes

**Próximo Paso:** Pruebas de integración completas y deployment.
