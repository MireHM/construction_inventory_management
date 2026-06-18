-- V3: Tablas agregadas en Branch 1 y 2 (categorías, unidades, proyectos, proveedores)
-- Las tablas ya se crean en V1 con IF NOT EXISTS; este script agrega las restricciones FK
-- que Hibernate no crea automáticamente con ddl-auto:validate.

-- FK: materiales → categorias
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'fk_material_categoria'
  ) THEN
    ALTER TABLE materiales
      ADD CONSTRAINT fk_material_categoria
      FOREIGN KEY (categoria_id) REFERENCES categorias(id);
  END IF;
END$$;

-- FK: materiales → unidades_medida
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'fk_material_unidad'
  ) THEN
    ALTER TABLE materiales
      ADD CONSTRAINT fk_material_unidad
      FOREIGN KEY (unidad_medida_id) REFERENCES unidades_medida(id);
  END IF;
END$$;

-- FK: movimientos_inventario → materiales
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'fk_movimiento_material'
  ) THEN
    ALTER TABLE movimientos_inventario
      ADD CONSTRAINT fk_movimiento_material
      FOREIGN KEY (material_id) REFERENCES materiales(id);
  END IF;
END$$;

-- FK: alertas_stock → materiales
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'fk_alerta_material'
  ) THEN
    ALTER TABLE alertas_stock
      ADD CONSTRAINT fk_alerta_material
      FOREIGN KEY (material_id) REFERENCES materiales(id);
  END IF;
END$$;

-- Índice de texto para búsqueda full-text en materiales
CREATE INDEX IF NOT EXISTS idx_materiales_nombre_gin
  ON materiales USING gin(to_tsvector('spanish', nombre));
