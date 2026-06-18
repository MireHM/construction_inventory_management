-- V2: Índices para optimizar consultas frecuentes

-- Materiales: búsquedas por código, categoría y estado activo
CREATE INDEX IF NOT EXISTS idx_materiales_codigo      ON materiales(codigo);
CREATE INDEX IF NOT EXISTS idx_materiales_categoria   ON materiales(categoria_id);
CREATE INDEX IF NOT EXISTS idx_materiales_activo      ON materiales(activo);
CREATE INDEX IF NOT EXISTS idx_materiales_stock       ON materiales(stock_actual, stock_minimo) WHERE activo = TRUE;

-- Movimientos: historial por material y proyecto (más consultados)
CREATE INDEX IF NOT EXISTS idx_movimientos_material   ON movimientos_inventario(material_id, fecha_movimiento DESC);
CREATE INDEX IF NOT EXISTS idx_movimientos_proyecto   ON movimientos_inventario(proyecto_id, fecha_movimiento DESC);
CREATE INDEX IF NOT EXISTS idx_movimientos_tipo       ON movimientos_inventario(tipo);
CREATE INDEX IF NOT EXISTS idx_movimientos_fecha      ON movimientos_inventario(fecha_movimiento DESC);

-- Alertas: alertas pendientes (consulta más frecuente del dashboard)
CREATE INDEX IF NOT EXISTS idx_alertas_pendientes     ON alertas_stock(atendida, created_at DESC) WHERE atendida = FALSE;
CREATE INDEX IF NOT EXISTS idx_alertas_material       ON alertas_stock(material_id);

-- Órdenes de compra: estado y proveedor
CREATE INDEX IF NOT EXISTS idx_ordenes_estado         ON ordenes_compra(estado);
CREATE INDEX IF NOT EXISTS idx_ordenes_proveedor      ON ordenes_compra(proveedor_id);
CREATE INDEX IF NOT EXISTS idx_ordenes_proforma       ON ordenes_compra(proforma_id);

-- Usuarios: búsqueda por email (login)
CREATE INDEX IF NOT EXISTS idx_usuarios_email         ON usuarios(email);
CREATE INDEX IF NOT EXISTS idx_usuarios_activo        ON usuarios(activo);

-- Proyectos: filtro por estado
CREATE INDEX IF NOT EXISTS idx_proyectos_estado       ON proyectos(estado) WHERE activo = TRUE;
CREATE INDEX IF NOT EXISTS idx_proyectos_codigo       ON proyectos(codigo);

-- Proveedores: NIT
CREATE INDEX IF NOT EXISTS idx_proveedores_nit        ON proveedores(nit) WHERE nit IS NOT NULL;

-- APUs: código
CREATE INDEX IF NOT EXISTS idx_apus_codigo            ON apus(codigo);

-- Proformas: proyecto y estado
CREATE INDEX IF NOT EXISTS idx_proformas_proyecto     ON proformas(proyecto_id);
CREATE INDEX IF NOT EXISTS idx_proformas_estado       ON proformas(estado);
