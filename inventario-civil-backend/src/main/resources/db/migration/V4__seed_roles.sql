-- V4: Datos críticos de arranque — roles y usuario admin
-- Se ejecuta ANTES de que DataSeeder (CommandLineRunner) corra,
-- garantizando que el login funcione incluso si DataSeeder es interrumpido.

-- Asegurar columna activo en roles (V1 la omitió; Hibernate la creó vía ddl-auto:update)
ALTER TABLE roles ADD COLUMN IF NOT EXISTS activo BOOLEAN NOT NULL DEFAULT TRUE;

-- Insertar los 4 roles base
INSERT INTO roles (nombre, descripcion, activo) VALUES
  ('ADMINISTRADOR', 'Administrador del sistema con acceso completo', true),
  ('ALMACENERO',    'Gestiona el inventario y movimientos de materiales', true),
  ('RESIDENTE',     'Residente de obra, solicita y registra materiales', true),
  ('GERENTE',       'Gerente de proyecto, aprueba órdenes de compra', true)
ON CONFLICT (nombre) DO NOTHING;

-- Insertar usuario administrador inicial
-- Password: Admin2025#  (bcrypt strength=12)
INSERT INTO usuarios (nombre, email, password_hash, activo)
VALUES (
  'Administrador del Sistema',
  'admin@inventariocivil.bo',
  '$2a$12$ach7uWNbJ0WPbUlEkN10zuDQQ9mNxeVMnO2aG03wuYkRwDu8Gw/OC',
  true
)
ON CONFLICT (email) DO NOTHING;

-- Asignar rol ADMINISTRADOR al usuario admin
INSERT INTO usuario_roles (usuario_id, rol_id)
SELECT u.id, r.id
FROM usuarios u
JOIN roles r ON r.nombre = 'ADMINISTRADOR'
WHERE u.email = 'admin@inventariocivil.bo'
ON CONFLICT (usuario_id, rol_id) DO NOTHING;
