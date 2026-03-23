# InventarioPro — Plataforma Full Stack para la Automatización del Control de Inventario y Estimación de Requerimientos en Proyectos de Construcción Urbana

## Descripción

InventarioPro es una plataforma Full Stack desarrollada para automatizar el control de inventario de materiales y la estimación de requerimientos en proyectos de construcción urbana. El sistema permite a empresas constructoras medianas gestionar sus materiales, calcular requerimientos mediante Análisis de Precios Unitarios (APU), generar órdenes de compra automáticas y monitorear el estado del inventario en tiempo real desde una aplicación móvil/desktop.

---

## Objetivo General

Desarrollar una plataforma Full Stack que automatice el control de inventario y la estimación de requerimientos de materiales en proyectos de construcción urbana, verificable a través de los reportes comparativos de presupuesto vs. costo ejecutado y los indicadores de rotación de inventario generados por el propio sistema.

---

## Objetivos Específicos

- Implementar una API REST con autenticación JWT y control de acceso por roles (ADMINISTRADOR, ALMACENERO, RESIDENTE, GERENTE).
- Desarrollar el módulo de gestión de materiales con seguimiento de stock mínimo/máximo y alertas automáticas.
- Implementar el motor de cálculo APU que estime requerimientos a partir de proformas de obra.
- Generar órdenes de compra automáticas desde los requerimientos calculados con flujo de aprobación.
- Desarrollar una interfaz móvil/desktop con Flutter que consuma la API y permita operar el sistema en campo.
- Persistir todos los datos en PostgreSQL y desplegar el backend en contenedores Docker.

---

## Alcance

### Incluye
- Autenticación JWT con roles y permisos por endpoint
- CRUD completo de materiales con control de stock
- Registro de ingresos y salidas de inventario con trazabilidad
- Gestión de Análisis de Precios Unitarios (APUs) con rendimientos reales
- Motor de cálculo de requerimientos: `cantidad_obra × cantidad_por_unidad × (1 + rendimiento%)`
- Generación automática de órdenes de compra desde requerimientos
- Flujo de aprobación de órdenes: PENDIENTE → APROBADA → RECIBIDA
- Dashboard con KPIs en tiempo real (stock crítico, alertas, OC pendientes)
- Reportes exportables en PDF (requerimientos e historial de movimientos)
- Alertas automáticas de stock mínimo, stock máximo y sin stock

### No incluye (versión actual)
- Integración con sistemas contables externos
- Módulo de facturación
- Notificaciones push en tiempo real (FCM)
- Gestión de usuarios desde la app (solo desde backend)
- Soporte multi-empresa

---

## Stack Tecnológico

| Capa | Tecnología |
|---|---|
| Backend | Java 17 + Spring Boot 3.2.x |
| Seguridad | Spring Security + JWT (HS256) |
| Base de datos | PostgreSQL 15 |
| ORM | Spring Data JPA + Hibernate |
| Documentación API | SpringDoc OpenAPI (Swagger UI) |
| Frontend | Flutter 3.x (Dart) |
| Gestión de estado | BLoC Pattern |
| HTTP Client | Dio |
| Inyección de dependencias | GetIt |
| Navegación | GoRouter |
| Contenedores | Docker + Docker Compose |
| Control de versiones | Git + GitHub |

---

## Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENTE (Flutter)                        │
│  macOS / Android / iOS                                      │
│  Clean Architecture + BLoC                                  │
└──────────────────────┬──────────────────────────────────────┘
                       │  HTTP/REST + JWT
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                  API REST (Spring Boot)                     │
│                                                             │
│  Presentation  →  Application  →  Domain  →  Infrastructure │
│  (Controllers)    (Use Cases)   (Entities)   (JPA + DB)    │
└──────────────────────┬──────────────────────────────────────┘
                       │  JDBC
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                  PostgreSQL 15                              │
│  materiales · movimientos · proformas · APUs · órdenes     │
└─────────────────────────────────────────────────────────────┘
```

---

## Estructura del Proyecto

```
inventario-civil-backend/
├── src/main/java/com/ucb/inventariocivil/
│   ├── domain/
│   │   ├── entities/          # Entidades de negocio puras
│   │   ├── repositories/      # Interfaces (ports)
│   │   └── exceptions/        # Excepciones de dominio
│   ├── application/
│   │   └── usecases/          # Casos de uso (lógica de negocio)
│   ├── infrastructure/
│   │   ├── persistence/       # JPA entities + repositorios
│   │   └── security/          # JWT + Spring Security
│   └── presentation/
│       └── controllers/       # Controllers REST
├── Dockerfile
├── docker-compose.yml
└── README.md

inventario-civil-flutter/
├── lib/
│   ├── core/
│   │   ├── constants/         # URLs, keys de almacenamiento
│   │   ├── errors/            # Jerarquía de fallos
│   │   ├── network/           # ApiClient (Dio + JWT interceptor)
│   │   ├── theme/             # Colores y estilos globales
│   │   └── utils/             # Generadores de PDF
│   └── features/
│       ├── auth/              # Login, BLoC de sesión
│       ├── materiales/        # Catálogo, CRUD
│       ├── inventario/        # Ingresos, salidas, historial, alertas
│       ├── proformas/         # Proformas, APUs, requerimientos
│       ├── ordenes/           # Órdenes de compra
│       ├── reportes/          # Reporte de stock
│       └── dashboard/         # KPIs y accesos rápidos
└── pubspec.yaml
```

---

## Endpoints Core

### Autenticación
| Método | Ruta | Descripción |
|---|---|---|
| POST | `/api/v1/auth/login` | Iniciar sesión, retorna JWT |

### Materiales
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/v1/materiales` | Listar materiales activos |
| POST | `/api/v1/materiales` | Crear material (ADMIN) |
| PUT | `/api/v1/materiales/{id}` | Actualizar material (ADMIN) |
| GET | `/api/v1/materiales/alertas` | Materiales bajo stock mínimo |

### Inventario
| Método | Ruta | Descripción |
|---|---|---|
| POST | `/api/v1/inventario/ingresos` | Registrar ingreso de material |
| POST | `/api/v1/inventario/salidas` | Registrar salida de material |
| GET | `/api/v1/inventario/movimientos/recientes` | Últimos 20 movimientos |
| GET | `/api/v1/inventario/alertas` | Alertas de stock pendientes |

### Proformas y Motor APU
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/v1/proformas?proyectoId=` | Listar proformas por proyecto |
| POST | `/api/v1/proformas` | Crear proforma con partidas |
| **POST** | **`/api/v1/proformas/{id}/calcular`** | **Ejecutar motor de cálculo APU** |
| GET | `/api/v1/proformas/{id}/requerimientos` | Ver requerimientos calculados |

### Órdenes de Compra
| Método | Ruta | Descripción |
|---|---|---|
| POST | `/api/v1/ordenes/generar?proformaId=` | Generar OCs desde proforma |
| POST | `/api/v1/ordenes/{id}/aprobar` | Aprobar orden (GERENTE) |
| POST | `/api/v1/ordenes/{id}/recibir` | Recibir materiales + ingreso automático |

### Reportes
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/v1/reportes/dashboard` | KPIs del sistema |
| GET | `/api/v1/reportes/stock` | Resumen de stock por estado |
| GET | `/api/v1/reportes/movimientos` | Últimos 50 movimientos |

---

## Cómo Ejecutar el Proyecto

### Backend (Docker — recomendado)

```bash
# 1. Clonar el repositorio
git clone <URL_REPOSITORIO>
cd inventario-civil-backend

# 2. Levantar con Docker Compose
docker-compose up --build
```

> La API estará disponible en: `http://localhost:8080`  
> Swagger UI: `http://localhost:8080/swagger-ui.html`

### Backend (Sin Docker)

```bash
# Requiere: Java 17 + Maven + PostgreSQL local
export DB_HOST=localhost
export DB_USER=postgres
export DB_PASSWORD=postgres

mvn spring-boot:run
```

### Frontend (Flutter)

```bash
cd inventario-civil-flutter

# 1. Instalar dependencias
flutter pub get

# 2. Configurar URL del backend en:
#    lib/core/constants/app_constants.dart
#    static const String baseUrl = 'http://localhost:8080/api/v1';

# 3. Ejecutar
flutter run -d macos     # macOS
flutter run -d chrome    # Web
flutter run              # Android/iOS
```

---

## Variables de Entorno

| Variable | Descripción | Valor por defecto |
|---|---|---|
| `DB_HOST` | Host de PostgreSQL | `localhost` |
| `DB_PORT` | Puerto de PostgreSQL | `5432` |
| `DB_NAME` | Nombre de la base de datos | `inventario_civil` |
| `DB_USER` | Usuario de PostgreSQL | `postgres` |
| `DB_PASSWORD` | Contraseña de PostgreSQL | `postgres` |
| `JWT_SECRET` | Clave secreta para firmar JWT | ver `application.yml` |

---

## Credenciales por Defecto

Al arrancar el sistema por primera vez, el `DataSeeder` crea automáticamente:

```
Email:    admin@inventariocivil.bo
Password: Admin2025#
Rol:      ADMINISTRADOR
```

También se crean 10 materiales de construcción y 3 APUs de ejemplo (Hormigón Ciclópeo H-150, Hormigón Simple H-180, Muro de Ladrillo 6 Huecos).

---

## Motor de Cálculo APU

El núcleo del sistema calcula automáticamente los requerimientos de materiales a partir de las partidas de una proforma:

```
cantidad_requerida = cantidad_obra × cantidad_por_unidad × (1 + rendimiento / 100)
```

**Ejemplo:** Proforma con 45 m³ de Hormigón H-180 (APU-002):
- Cemento: `45 × 6.50 × 1.05 = 307.125 sacos`
- Arena: `45 × 0.55 × 1.03 = 25.49 m³`
- Grava: `45 × 0.75 × 1.03 = 34.76 m³`

Los resultados se comparan con el stock disponible y se calcula automáticamente cuánto hay que comprar.

---

## Control de Versiones

```
main       ← producción
develop    ← integración
feature/   ← funcionalidades por historia de usuario
```

**Historial de commits:**
- `feat: commit 1` — Arquitectura base, JWT, entidades dominio
- `feat: commit 2` — Auth funcional, CRUD materiales, Dashboard
- `feat: commit 3` — Módulo inventario completo (ingresos, salidas, alertas)
- `feat: commit 4` — APUs, proformas, motor de cálculo de requerimientos
- `feat: commit 5` — Órdenes de compra, reportes KPIs, flujo end-to-end

---

## Equipo

| Nombre | Rol |
|---|---|
| Mireya Nataly Huanca Marca | Desarrolladora Full Stack |
| Por asignar | Tutor |
| Msc. Orlando Rivera Jurado | Revisor |

**Programa:** Maestría Full Stack Development — Fase 2 Especialidad  
**Universidad:** Universidad Católica Boliviana "San Pablo"  
**Gestión:** 2025