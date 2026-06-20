-- V5: Datos de demostración para defensa de tesis
-- Columnas basadas en entidades JPA reales (no en el esquema V1).
-- Tablas afectadas: movimientos_inventario, alertas_stock, proformas,
--   partidas_proforma, requerimientos, ordenes_compra.

DO $$
DECLARE
  v_admin_id    BIGINT;
  v_proj1_id    BIGINT;
  v_proj2_id    BIGINT;
  v_mat1_id     BIGINT;
  v_mat2_id     BIGINT;
  v_mat3_id     BIGINT;
  v_mat5_id     BIGINT;
  v_mat6_id     BIGINT;
  v_mat7_id     BIGINT;
  v_mat9_id     BIGINT;
  v_prov1_id    BIGINT;
  v_prov2_id    BIGINT;
  v_prov3_id    BIGINT;
  v_apu2_id     BIGINT;
  v_apu3_id     BIGINT;
  v_proforma_id BIGINT;
  v_req1_id     BIGINT;
  v_req2_id     BIGINT;
  v_req3_id     BIGINT;
  v_req4_id     BIGINT;
BEGIN
  SELECT id INTO v_admin_id FROM usuarios  WHERE email   = 'admin@inventariocivil.bo';
  SELECT id INTO v_proj1_id FROM proyectos WHERE codigo  = 'PROY-001';
  SELECT id INTO v_proj2_id FROM proyectos WHERE codigo  = 'PROY-002';
  SELECT id INTO v_mat1_id  FROM materiales WHERE codigo = 'MAT-001';
  SELECT id INTO v_mat2_id  FROM materiales WHERE codigo = 'MAT-002';
  SELECT id INTO v_mat3_id  FROM materiales WHERE codigo = 'MAT-003';
  SELECT id INTO v_mat5_id  FROM materiales WHERE codigo = 'MAT-005';
  SELECT id INTO v_mat6_id  FROM materiales WHERE codigo = 'MAT-006';
  SELECT id INTO v_mat7_id  FROM materiales WHERE codigo = 'MAT-007';
  SELECT id INTO v_mat9_id  FROM materiales WHERE codigo = 'MAT-009';
  SELECT id INTO v_prov1_id FROM proveedores WHERE nit   = '1234567';
  SELECT id INTO v_prov2_id FROM proveedores WHERE nit   = '2345678';
  SELECT id INTO v_prov3_id FROM proveedores WHERE nit   = '3456789';
  SELECT id INTO v_apu2_id  FROM apus WHERE codigo       = 'APU-002';
  SELECT id INTO v_apu3_id  FROM apus WHERE codigo       = 'APU-003';

  -- ── MOVIMIENTOS DE INVENTARIO ────────────────────────────────────────────
  -- created_at es NOT NULL sin DEFAULT — se debe incluir explícitamente.
  IF (SELECT COUNT(*) FROM movimientos_inventario) = 0 THEN

    INSERT INTO movimientos_inventario
      (material_id, proyecto_id, tipo, cantidad, precio_unitario,
       proveedor_id, numero_factura, responsable_id,
       stock_anterior, stock_resultante, fecha_movimiento, created_at)
    VALUES
      (v_mat1_id, v_proj1_id,'INGRESO', 200, 55.00, v_prov1_id,'FACT-2026-001', v_admin_id,    0,  200, NOW()-INTERVAL '60 days', NOW()-INTERVAL '60 days'),
      (v_mat2_id, v_proj1_id,'INGRESO',  50,120.00, v_prov1_id,'FACT-2026-001', v_admin_id,    0,   50, NOW()-INTERVAL '60 days', NOW()-INTERVAL '60 days'),
      (v_mat3_id, v_proj1_id,'INGRESO',  50, 90.00, v_prov1_id,'FACT-2026-001', v_admin_id,    0,   50, NOW()-INTERVAL '60 days', NOW()-INTERVAL '60 days'),
      (v_mat5_id, v_proj1_id,'INGRESO', 100, 68.00, v_prov2_id,'FACT-2026-002', v_admin_id,    0,  100, NOW()-INTERVAL '55 days', NOW()-INTERVAL '55 days'),
      (v_mat6_id, v_proj1_id,'INGRESO', 150, 32.00, v_prov2_id,'FACT-2026-002', v_admin_id,    0,  150, NOW()-INTERVAL '55 days', NOW()-INTERVAL '55 days'),
      (v_mat7_id, v_proj1_id,'INGRESO',3000,  1.20, v_prov3_id,'FACT-2026-003', v_admin_id,    0, 3000, NOW()-INTERVAL '50 days', NOW()-INTERVAL '50 days'),
      (v_mat9_id, v_proj1_id,'INGRESO',  60, 35.00, v_prov1_id,'FACT-2026-004', v_admin_id,    0,   60, NOW()-INTERVAL '45 days', NOW()-INTERVAL '45 days');

    INSERT INTO movimientos_inventario
      (material_id, proyecto_id, tipo, cantidad, responsable_id,
       stock_anterior, stock_resultante, motivo, fecha_movimiento, created_at)
    VALUES
      (v_mat1_id, v_proj1_id,'SALIDA',  80, v_admin_id, 200, 120,'Hormigón cimentación bloque A',    NOW()-INTERVAL '45 days', NOW()-INTERVAL '45 days'),
      (v_mat2_id, v_proj1_id,'SALIDA',  20, v_admin_id,  50,  30,'Mortero paredes nivel 1',           NOW()-INTERVAL '40 days', NOW()-INTERVAL '40 days'),
      (v_mat5_id, v_proj1_id,'SALIDA',  60, v_admin_id, 100,  40,'Armado columnas sótano',            NOW()-INTERVAL '35 days', NOW()-INTERVAL '35 days'),
      (v_mat6_id, v_proj1_id,'SALIDA',  90, v_admin_id, 150,  60,'Losas nivel 1 y 2',                NOW()-INTERVAL '30 days', NOW()-INTERVAL '30 days'),
      (v_mat7_id, v_proj1_id,'SALIDA',1200, v_admin_id,3000,1800,'Muros divisorios nivel 1 y 2',     NOW()-INTERVAL '25 days', NOW()-INTERVAL '25 days'),
      (v_mat1_id, v_proj1_id,'SALIDA',  75, v_admin_id, 120,  45,'Hormigón armado columnas nivel 2', NOW()-INTERVAL '20 days', NOW()-INTERVAL '20 days'),
      (v_mat9_id, v_proj1_id,'SALIDA',  45, v_admin_id,  60,  15,'Primera mano pintura exterior',    NOW()-INTERVAL '15 days', NOW()-INTERVAL '15 days'),
      (v_mat3_id, v_proj1_id,'SALIDA',  25, v_admin_id,  50,   5,'Subbase piso planta baja',         NOW()-INTERVAL '10 days', NOW()-INTERVAL '10 days');

    UPDATE materiales SET stock_actual =   45, updated_at = NOW() WHERE codigo = 'MAT-001';
    UPDATE materiales SET stock_actual =   30, updated_at = NOW() WHERE codigo = 'MAT-002';
    UPDATE materiales SET stock_actual =    5, updated_at = NOW() WHERE codigo = 'MAT-003';
    UPDATE materiales SET stock_actual =   30, updated_at = NOW() WHERE codigo = 'MAT-004';
    UPDATE materiales SET stock_actual =   40, updated_at = NOW() WHERE codigo = 'MAT-005';
    UPDATE materiales SET stock_actual =   60, updated_at = NOW() WHERE codigo = 'MAT-006';
    UPDATE materiales SET stock_actual = 1800, updated_at = NOW() WHERE codigo = 'MAT-007';
    UPDATE materiales SET stock_actual =   30, updated_at = NOW() WHERE codigo = 'MAT-008';
    UPDATE materiales SET stock_actual =   15, updated_at = NOW() WHERE codigo = 'MAT-009';
    UPDATE materiales SET stock_actual =  600, updated_at = NOW() WHERE codigo = 'MAT-010';

    -- created_at en alertas_stock también es NOT NULL sin DEFAULT
    INSERT INTO alertas_stock (material_id, tipo, stock_al_momento, atendida, created_at)
    VALUES
      (v_mat1_id,'STOCK_MINIMO', 45, false, NOW()-INTERVAL '20 days'),
      (v_mat3_id,'SIN_STOCK',     5, false, NOW()-INTERVAL '10 days'),
      (v_mat9_id,'STOCK_MINIMO', 15, false, NOW()-INTERVAL '15 days');
  END IF;

  -- ── PROFORMAS ────────────────────────────────────────────────────────────
  IF (SELECT COUNT(*) FROM proformas) = 0 THEN

    INSERT INTO proformas
      (proyecto_id, codigo, nombre, descripcion,
       fecha_elaboracion, elaborado_por, estado, created_at, updated_at)
    VALUES (
      v_proj1_id, 'PRO-001', 'Estructura Edificio Central UCB',
      'Hormigón armado H-180 y mampostería para estructura principal — 5 pisos',
      CURRENT_DATE - INTERVAL '30 days', v_admin_id, 'VIGENTE',
      NOW()-INTERVAL '30 days', NOW()-INTERVAL '29 days'
    ) RETURNING id INTO v_proforma_id;

    -- partidas_proforma: columna es "cantidad_obra" (no "cantidad"), sin created_at
    INSERT INTO partidas_proforma (proforma_id, apu_id, cantidad_obra, orden) VALUES
      (v_proforma_id, v_apu2_id,  45.0, 1),
      (v_proforma_id, v_apu3_id, 120.0, 2);

    -- requerimientos: columnas reales son cantidad_calculada, cantidad_disponible,
    --   cantidad_a_comprar, solicitado_por, fecha_calculo (sin created_at)
    -- Cemento:  45 × 6.50 × 1.05 = 307.13  | disp=120 (stock tras ingresos) | comprar=187.13
    -- Arena:    45 × 0.55 × 1.03 = 25.49   | disp=30                        | comprar=0
    -- Grava:    45 × 0.75 × 1.03 = 34.76   | disp=5                         | comprar=29.76
    -- Ladrillo: 120 × 55  × 1.05 = 6930    | disp=1800                      | comprar=5130
    INSERT INTO requerimientos
      (proforma_id, material_id, cantidad_calculada, cantidad_disponible, cantidad_a_comprar,
       solicitado_por, fecha_calculo)
    VALUES (v_proforma_id, v_mat1_id, 307.13, 120.00, 187.13, v_admin_id, NOW()-INTERVAL '29 days')
    RETURNING id INTO v_req1_id;

    INSERT INTO requerimientos
      (proforma_id, material_id, cantidad_calculada, cantidad_disponible, cantidad_a_comprar,
       solicitado_por, fecha_calculo)
    VALUES (v_proforma_id, v_mat2_id, 25.49, 30.00, 0, v_admin_id, NOW()-INTERVAL '29 days')
    RETURNING id INTO v_req2_id;

    INSERT INTO requerimientos
      (proforma_id, material_id, cantidad_calculada, cantidad_disponible, cantidad_a_comprar,
       solicitado_por, fecha_calculo)
    VALUES (v_proforma_id, v_mat3_id, 34.76, 5.00, 29.76, v_admin_id, NOW()-INTERVAL '29 days')
    RETURNING id INTO v_req3_id;

    INSERT INTO requerimientos
      (proforma_id, material_id, cantidad_calculada, cantidad_disponible, cantidad_a_comprar,
       solicitado_por, fecha_calculo)
    VALUES (v_proforma_id, v_mat7_id, 6930, 1800.00, 5130, v_admin_id, NOW()-INTERVAL '29 days')
    RETURNING id INTO v_req4_id;

    INSERT INTO proformas
      (proyecto_id, codigo, nombre, descripcion,
       fecha_elaboracion, elaborado_por, estado, created_at, updated_at)
    VALUES (
      v_proj2_id, 'PRO-002', 'Superestructura Puente Río Choqueyapu',
      'Hormigón armado para tablero del puente peatonal de 30m de luz',
      CURRENT_DATE - INTERVAL '10 days', v_admin_id, 'BORRADOR',
      NOW()-INTERVAL '10 days', NOW()-INTERVAL '10 days'
    );

  ELSE
    SELECT id INTO v_proforma_id FROM proformas ORDER BY id LIMIT 1;
    SELECT id INTO v_req1_id FROM requerimientos WHERE proforma_id = v_proforma_id ORDER BY id       LIMIT 1;
    SELECT id INTO v_req2_id FROM requerimientos WHERE proforma_id = v_proforma_id ORDER BY id OFFSET 1 LIMIT 1;
    SELECT id INTO v_req3_id FROM requerimientos WHERE proforma_id = v_proforma_id ORDER BY id OFFSET 2 LIMIT 1;
    SELECT id INTO v_req4_id FROM requerimientos WHERE proforma_id = v_proforma_id ORDER BY id OFFSET 3 LIMIT 1;
  END IF;

  -- ── ÓRDENES DE COMPRA ────────────────────────────────────────────────────
  IF (SELECT COUNT(*) FROM ordenes_compra) = 0 AND v_req1_id IS NOT NULL THEN

    INSERT INTO ordenes_compra
      (requerimiento_id, material_id, proveedor_id, nombre_proveedor,
       cantidad, precio_unitario, costo_estimado,
       estado, generada_por, fecha_generacion, observaciones)
    VALUES (v_req1_id, v_mat1_id, v_prov1_id, 'SOBOCE S.A.',
            300, 55.00, 16500.00, 'PENDIENTE', v_admin_id,
            NOW()-INTERVAL '5 days',
            'Reposición urgente — stock cayó por debajo del mínimo operativo');

    INSERT INTO ordenes_compra
      (requerimiento_id, material_id, proveedor_id, nombre_proveedor,
       cantidad, precio_unitario, costo_estimado,
       estado, generada_por, aprobada_por,
       fecha_generacion, fecha_aprobacion, observaciones)
    VALUES (v_req3_id, v_mat3_id, v_prov1_id, 'SOBOCE S.A.',
            50, 90.00, 4500.00, 'APROBADA', v_admin_id, v_admin_id,
            NOW()-INTERVAL '8 days', NOW()-INTERVAL '6 days',
            'Aprobada por Gerencia — entrega programada semana siguiente');

    INSERT INTO ordenes_compra
      (requerimiento_id, material_id, proveedor_id, nombre_proveedor,
       cantidad, precio_unitario, costo_estimado,
       estado, generada_por, aprobada_por,
       fecha_generacion, fecha_aprobacion, fecha_recepcion)
    VALUES (v_req4_id, v_mat7_id, v_prov3_id, 'FERRETERÍA EL CONSTRUCTOR',
            2000, 1.20, 2400.00, 'RECIBIDA', v_admin_id, v_admin_id,
            NOW()-INTERVAL '40 days', NOW()-INTERVAL '38 days', NOW()-INTERVAL '35 days');

  END IF;

END $$;
