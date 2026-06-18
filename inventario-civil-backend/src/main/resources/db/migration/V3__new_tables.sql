-- V3: Índice GIN para búsqueda full-text en materiales
-- Las FKs se omiten aquí porque Flyway corre antes que DataSeeder:
-- en el momento en que este script ejecuta, categorias/unidades_medida están vacías
-- pero materiales ya tiene filas con esos IDs → la restricción fallaría.
-- Las entidades usan Long simple (no @ManyToOne), la integridad se garantiza por lógica de aplicación.
CREATE INDEX IF NOT EXISTS idx_materiales_nombre_gin
  ON materiales USING gin(to_tsvector('spanish', nombre));
