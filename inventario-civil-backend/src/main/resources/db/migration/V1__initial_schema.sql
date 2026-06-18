-- V1: Esquema inicial del sistema de inventario civil
-- Las tablas ya existen en Render (creadas por Hibernate ddl-auto: update).
-- baseline-on-migrate=true marca V1 como aplicado sin ejecutarlo en DBs existentes.

CREATE TABLE IF NOT EXISTS categorias (
    id          BIGSERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activo      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS unidades_medida (
    id         BIGSERIAL PRIMARY KEY,
    simbolo    VARCHAR(20)  NOT NULL UNIQUE,
    nombre     VARCHAR(100) NOT NULL,
    activo     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS roles (
    id          BIGSERIAL PRIMARY KEY,
    nombre      VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS usuarios (
    id            BIGSERIAL PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    telefono      VARCHAR(20),
    activo        BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS usuario_roles (
    usuario_id BIGINT NOT NULL REFERENCES usuarios(id),
    rol_id     BIGINT NOT NULL REFERENCES roles(id),
    PRIMARY KEY (usuario_id, rol_id)
);

CREATE TABLE IF NOT EXISTS proyectos (
    id                BIGSERIAL PRIMARY KEY,
    codigo            VARCHAR(20)    NOT NULL UNIQUE,
    nombre            VARCHAR(200)   NOT NULL,
    descripcion       TEXT,
    estado            VARCHAR(30)    NOT NULL DEFAULT 'PLANIFICACION',
    fecha_inicio      DATE,
    fecha_fin_estimada DATE,
    responsable_id    BIGINT,
    presupuesto       NUMERIC(16,2),
    activo            BOOLEAN NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS usuario_proyectos (
    usuario_id  BIGINT NOT NULL REFERENCES usuarios(id),
    proyecto_id BIGINT NOT NULL REFERENCES proyectos(id),
    PRIMARY KEY (usuario_id, proyecto_id)
);

CREATE TABLE IF NOT EXISTS proveedores (
    id         BIGSERIAL PRIMARY KEY,
    nombre     VARCHAR(200) NOT NULL,
    nit        VARCHAR(20),
    telefono   VARCHAR(20),
    email      VARCHAR(150),
    direccion  TEXT,
    contacto   VARCHAR(100),
    activo     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS materiales (
    id               BIGSERIAL PRIMARY KEY,
    codigo           VARCHAR(30)    NOT NULL UNIQUE,
    nombre           VARCHAR(200)   NOT NULL,
    descripcion      TEXT,
    categoria_id     BIGINT         NOT NULL,
    unidad_medida_id BIGINT         NOT NULL,
    precio_referencia NUMERIC(12,2) NOT NULL DEFAULT 0,
    stock_actual     NUMERIC(14,3)  NOT NULL DEFAULT 0,
    stock_minimo     NUMERIC(14,3)  NOT NULL DEFAULT 0,
    stock_maximo     NUMERIC(14,3),
    activo           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS movimientos_inventario (
    id               BIGSERIAL PRIMARY KEY,
    material_id      BIGINT        NOT NULL,
    proyecto_id      BIGINT,
    tipo             VARCHAR(20)   NOT NULL,
    cantidad         NUMERIC(14,3) NOT NULL,
    precio_unitario  NUMERIC(12,2),
    proveedor_id     BIGINT,
    numero_factura   VARCHAR(50),
    frente_obra      VARCHAR(200),
    motivo           TEXT,
    responsable_id   BIGINT,
    stock_anterior   NUMERIC(14,3),
    stock_resultante NUMERIC(14,3),
    fecha_movimiento TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS alertas_stock (
    id              BIGSERIAL PRIMARY KEY,
    material_id     BIGINT        NOT NULL,
    tipo            VARCHAR(30)   NOT NULL,
    stock_al_momento NUMERIC(14,3),
    atendida        BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS apus (
    id          BIGSERIAL PRIMARY KEY,
    codigo      VARCHAR(30)  NOT NULL UNIQUE,
    nombre      VARCHAR(200) NOT NULL,
    descripcion TEXT,
    unidad_obra VARCHAR(20),
    activo      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS apu_materiales (
    id                    BIGSERIAL PRIMARY KEY,
    apu_id                BIGINT        NOT NULL REFERENCES apus(id),
    material_id           BIGINT        NOT NULL,
    cantidad_por_unidad   NUMERIC(10,4) NOT NULL,
    rendimiento_porcentaje NUMERIC(5,2)
);

CREATE TABLE IF NOT EXISTS proformas (
    id           BIGSERIAL PRIMARY KEY,
    codigo       VARCHAR(30)  NOT NULL UNIQUE,
    nombre       VARCHAR(200) NOT NULL,
    descripcion  TEXT,
    proyecto_id  BIGINT,
    estado       VARCHAR(30)  NOT NULL DEFAULT 'BORRADOR',
    activo       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS partidas_proforma (
    id          BIGSERIAL PRIMARY KEY,
    proforma_id BIGINT        NOT NULL REFERENCES proformas(id),
    apu_id      BIGINT        NOT NULL,
    cantidad    NUMERIC(14,3) NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS requerimientos (
    id          BIGSERIAL PRIMARY KEY,
    proforma_id BIGINT        NOT NULL,
    material_id BIGINT        NOT NULL,
    cantidad    NUMERIC(14,3) NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ordenes_compra (
    id              BIGSERIAL PRIMARY KEY,
    codigo          VARCHAR(30)    NOT NULL UNIQUE,
    proforma_id     BIGINT,
    proveedor_id    BIGINT,
    nombre_proveedor VARCHAR(200),
    material_id     BIGINT,
    cantidad        NUMERIC(14,3)  NOT NULL,
    precio_unitario NUMERIC(12,2),
    costo_estimado  NUMERIC(16,2),
    estado          VARCHAR(30)    NOT NULL DEFAULT 'PENDIENTE',
    observaciones   TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);
