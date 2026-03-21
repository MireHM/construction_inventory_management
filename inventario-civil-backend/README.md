# inventario-civil-backend

Backend de la **Plataforma Full Stack para la Automatización del Control de Inventario y Estimación de Requerimientos en Proyectos de Construcción Urbana**.

**Proyecto de Especialidad – Maestría Full Stack UCB**
**Estudiante:** Mireya Nataly Huanca Marca

---

## Stack Tecnológico

| Componente | Tecnología |
|---|---|
| Lenguaje | Java 17 |
| Framework | Spring Boot 3.2.x |
| Seguridad | Spring Security + JWT (HS256) |
| Base de Datos | PostgreSQL 15 |
| ORM | Spring Data JPA + Hibernate |
| Documentación | SpringDoc OpenAPI (Swagger UI) |
| Contenedores | Docker + Docker Compose |

## Arquitectura

```
src/main/java/com/ucb/inventariocivil/
├── domain/               ← Entidades y puertos (sin dependencias externas)
│   ├── entities/
│   ├── repositories/     ← Interfaces (ports)
│   └── exceptions/
├── application/          ← Casos de uso (use cases)
├── infrastructure/       ← Implementaciones concretas
│   ├── persistence/      ← JPA entities + repositorios
│   └── security/         ← JWT + Spring Security
└── presentation/         ← Controllers REST
```

## Cómo ejecutar localmente

### Con Docker Compose (recomendado)

```bash
docker-compose up --build
```

El backend estará disponible en: `http://localhost:8080`
Swagger UI: `http://localhost:8080/swagger-ui.html`

### Sin Docker (requiere PostgreSQL local)

```bash
# 1. Crear la base de datos
createdb inventario_civil

# 2. Configurar variables de entorno
export DB_HOST=localhost
export DB_USER=postgres
export DB_PASSWORD=postgres

# 3. Ejecutar
mvn spring-boot:run
```

## Variables de entorno

| Variable | Descripción | Valor por defecto |
|---|---|---|
| `DB_HOST` | Host de PostgreSQL | `localhost` |
| `DB_PORT` | Puerto de PostgreSQL | `5432` |
| `DB_NAME` | Nombre de la base de datos | `inventario_civil` |
| `DB_USER` | Usuario de PostgreSQL | `postgres` |
| `DB_PASSWORD` | Contraseña de PostgreSQL | `postgres` |
| `JWT_SECRET` | Clave secreta para firmar JWT | ver application.yml |

## Endpoints disponibles (Commit 1)

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/v1/health` | Estado del sistema |
| POST | `/api/v1/auth/login` | Próximo commit |
| GET | `/swagger-ui.html` | Documentación interactiva |

## Control de versiones

```
main     ← producción
develop  ← integración
feature/ ← funcionalidades por historia de usuario
```
