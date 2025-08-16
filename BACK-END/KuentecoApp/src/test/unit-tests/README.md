# 🧪 Unit Tests - KuenteCO Backend

Esta carpeta contiene las **pruebas unitarias críticas** para el proyecto KuenteCO Backend Application.

## 📋 Estructura de Tests Implementados

### 🔐 Seguridad y Autenticación
- **`JwtUtilTest`** - Tests para generación, validación y parsing de tokens JWT
  - ✅ Generación de tokens válidos
  - ✅ Validación de tokens y usuarios
  - ✅ Extracción de claims y expiración
  - ✅ Resolución de tokens desde headers y cookies
  - ✅ Manejo de tokens expirados y malformados

### 📊 Enumeraciones Críticas  
- **`StateTest`** - Tests para el enum State (ciclo de vida de categorías)
  - ✅ Validación de valores esperados
  - ✅ Lógica de transiciones de estado
  - ✅ Categorización por lógica de negocio
  
- **`StateDebtTest`** - Tests para el enum StateDebt (estados de deudas)
  - ✅ Validación de estados de deuda
  - ✅ Transiciones válidas de deudas
  - ✅ Identificación de estados problemáticos
  - ✅ Lógica de notificaciones y pagos

### 🏗️ Servicios de Lógica de Negocio
- **`CategoryServiceImplTest`** - Tests para el servicio de categorías
  - ✅ Operaciones CRUD completas (Create, Read, Update, Delete)
  - ✅ Validaciones de roles (USER vs PROFILE)
  - ✅ Manejo de errores y excepciones
  - ✅ Generación de reportes por categoría
  - ✅ Gestión de presupuestos asignados
  - ✅ Validación de estados de categorías

### 🔄 Mappers (MapStruct)
- **`NewCategoryMapperTest`** - Tests para mapeo de DTOs a entidades
  - ✅ Mapeo correcto de campos
  - ✅ Ignorar campos específicos (ID, user, registerDate)
  - ✅ Manejo de valores nulos
  - ✅ Mapeo de objetos complejos (DescriptionCategory)
  - ✅ Preservación de integridad de datos

## 🚀 Cómo Ejecutar los Tests

### Ejecutar Todos los Unit Tests
```bash
# Desde la raíz del proyecto
mvn test -Dtest="org.kuenteco.backend.**.*Test"

# O especificamente los unit tests
mvn test -Dtest="*Test" -DfailIfNoTests=false
```

### Ejecutar Tests Específicos
```bash
# Solo tests de seguridad
mvn test -Dtest="JwtUtilTest"

# Solo tests de enums
mvn test -Dtest="StateTest,StateDebtTest"

# Solo tests de servicios
mvn test -Dtest="CategoryServiceImplTest"

# Solo tests de mappers
mvn test -Dtest="NewCategoryMapperTest"
```

### Ejecutar con Perfil de Testing
```bash
mvn test -Dspring.profiles.active=test
```

## 📈 Cobertura de Código

Para generar reporte de cobertura con JaCoCo:

```bash
# Ejecutar tests con cobertura
mvn clean test jacoco:report

# Ver reporte en: target/site/jacoco/index.html
```

### Objetivos de Cobertura Actuales:
- **JwtUtil**: 95%+ 🎯
- **State/StateDebt Enums**: 100% ✅
- **CategoryServiceImpl**: 90%+ 🎯
- **NewCategoryMapper**: 95%+ 🎯

## 🛠️ Configuración de Testing

### Base de Datos de Tests
- **Motor**: H2 in-memory database
- **Configuración**: `application-test.yml`
- **Auto-cleanup**: Habilitado (drop-create)

### Dependencias de Testing Utilizadas:
- **JUnit 5** - Framework de testing principal
- **Mockito** - Mocking y stubbing
- **Spring Boot Test** - Integración con Spring
- **Hamcrest** - Matchers adicionales
- **H2 Database** - Base de datos en memoria

## 🔍 Casos de Prueba Críticos Cubiertos

### Seguridad
- [x] Generación segura de JWT tokens
- [x] Validación de integridad de tokens
- [x] Manejo de tokens expirados
- [x] Extracción correcta de claims
- [x] Resolución desde múltiples fuentes

### Lógica de Negocio
- [x] Validación de roles y permisos
- [x] Operaciones CRUD con validación
- [x] Manejo correcto de estados
- [x] Cálculo de estadísticas financieras
- [x] Gestión de relaciones entre entidades

### Mapeo de Datos
- [x] Transformación DTO ↔ Entity
- [x] Preservación de integridad de datos
- [x] Manejo de campos opcionales/nulos
- [x] Mapeo de objetos complejos anidados

## 📝 Buenas Prácticas Implementadas

### Estructura de Tests
- **Given-When-Then** pattern para claridad
- **DisplayName** descriptivos en español
- **@BeforeEach** para setup consistente
- **Casos edge** y manejo de errores

### Naming Conventions
- Tests descriptivos: `shouldDoSomethingWhenCondition()`
- Métodos helper privados para reutilización
- Variables con nombres semánticamente claros

### Cobertura de Escenarios
- ✅ **Happy Path**: Casos exitosos
- ✅ **Error Handling**: Manejo de excepciones
- ✅ **Edge Cases**: Casos límite
- ✅ **Null Safety**: Validación de nulos
- ✅ **Business Logic**: Reglas de negocio

## 🎯 Próximos Pasos

### Tests Pendientes de Alto Impacto:
1. **BudgetServiceImplTest** - Servicio de presupuestos
2. **DebtServiceImplTest** - Servicio de deudas
3. **TransactionServiceImplTest** - Servicio de transacciones
4. **Password validation tests** - Seguridad de contraseñas
5. **Integration tests** - Pruebas de integración con BD

### Mejoras Recomendadas:
- [ ] Tests de performance con **QuickPerf**
- [ ] Tests de concurrencia
- [ ] Tests de validación Jakarta Bean Validation
- [ ] Mocks más específicos para APIs externas
- [ ] Tests parametrizados adicionales

---

## 🏆 Métricas de Calidad

| Componente | Tests | Cobertura | Estado |
|------------|--------|-----------|---------|
| JwtUtil | 15 tests | 95%+ | ✅ |
| State Enum | 8 tests | 100% | ✅ |
| StateDebt Enum | 9 tests | 100% | ✅ |
| CategoryServiceImpl | 16 tests | 90%+ | ✅ |
| NewCategoryMapper | 13 tests | 95%+ | ✅ |

**Total**: **61 tests unitarios críticos implementados** 🎉

---

**Nota**: Estos tests forman la base sólida para el desarrollo continuo y garantizan la **calidad y confiabilidad** del sistema financiero KuenteCO.
