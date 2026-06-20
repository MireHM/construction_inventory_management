-- V6: Datos adicionales de demostración
-- Usuarios de prueba, 3ª proforma, más movimientos y un segundo proyecto activo.

DO $$
DECLARE
  v_admin_id  BIGINT;
  v_proj1_id  BIGINT;
  v_proj2_id  BIGINT;
  v_proj3_id  BIGINT;
  v_mat1_id   BIGINT;
  v_mat4_id   BIGINT;
  v_mat5_id   BIGINT;
  v_mat8_id   BIGINT;
  v_mat10_id  BIGINT;
  v_prov2_id  BIGINT;
  v_prov3_id  BIGINT;
  v_rol_adm   BIGINT;
  v_rol_alm   BIGINT;
  v_rol_res   BIGINT;
  v_rol_ger   BIGINT;
  v_u2_id     BIGINT;
  v_u3_id     BIGINT;
  v_u4_id     BIGINT;
  v_proforma3 BIGINT;
  v_apu1_id   BIGINT;
BEGIN
  SELECT id INTO v_admin_id FROM usuarios  WHERE email  = 'admin@inventariocivil.bo';
  SELECT id INTO v_proj1_id FROM proyectos WHERE codigo = 'PROY-001';
  SELECT id INTO v_proj2_id FROM proyectos WHERE codigo = 'PROY-002';
  SELECT id INTO v_proj3_id FROM proyectos WHERE codigo = 'PROY-003';
  SELECT id INTO v_mat1_id  FROM materiales WHERE codigo = 'MAT-001';
  SELECT id INTO v_mat4_id  FROM materiales WHERE codigo = 'MAT-004';
  SELECT id INTO v_mat5_id  FROM materiales WHERE codigo = 'MAT-005';
  SELECT id INTO v_mat8_id  FROM materiales WHERE codigo = 'MAT-008';
  SELECT id INTO v_mat10_id FROM materiales WHERE codigo = 'MAT-010';
  SELECT id INTO v_prov2_id FROM proveedores WHERE nit  = '2345678';
  SELECT id INTO v_prov3_id FROM proveedores WHERE nit  = '3456789';
  SELECT id INTO v_apu1_id  FROM apus WHERE codigo      = 'APU-001';
  SELECT id INTO v_rol_adm FROM roles WHERE nombre = 'ADMINISTRADOR';
  SELECT id INTO v_rol_alm FROM roles WHERE nombre = 'ALMACENERO';
  SELECT id INTO v_rol_res FROM roles WHERE nombre = 'RESIDENTE';
  SELECT id INTO v_rol_ger FROM roles WHERE nombre = 'GERENTE';

  -- ── USUARIOS DE PRUEBA ────────────────────────────────────────────────────
  IF (SELECT COUNT(*) FROM usuarios) < 3 THEN

    -- Almacenero
    INSERT INTO usuarios (nombre, email, password_hash, telefono, activo, created_at, updated_at)
    VALUES ('Carlos Mamani Quispe', 'carlos.mamani@inventariocivil.bo',
            '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LkEYQIkW4LS',
            '72345678', true, NOW()-INTERVAL '30 days', NOW()-INTERVAL '30 days')
    RETURNING id INTO v_u2_id;

    INSERT INTO usuario_roles (usuario_id, rol_id) VALUES (v_u2_id, v_rol_alm);
    INSERT INTO usuario_proyectos (usuario_id, proyecto_id) VALUES (v_u2_id, v_proj1_id);

    -- Residente
    INSERT INTO usuarios (nombre, email, password_hash, telefono, activo, created_at, updated_at)
    VALUES ('Ana Flores Condori', 'ana.flores@inventariocivil.bo',
            '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LkEYQIkW4LS',
            '71234567', true, NOW()-INTERVAL '25 days', NOW()-INTERVAL '25 days')
    RETURNING id INTO v_u3_id;

    INSERT INTO usuario_roles (usuario_id, rol_id) VALUES (v_u3_id, v_rol_res);
    INSERT INTO usuario_proyectos (usuario_id, proyecto_id) VALUES (v_u3_id, v_proj1_id);
    INSERT INTO usuario_proyectos (usuario_id, proyecto_id) VALUES (v_u3_id, v_proj2_id);

    -- Gerente
    INSERT INTO usuarios (nombre, email, password_hash, telefono, activo, created_at, updated_at)
    VALUES ('Roberto Soto Vargas', 'roberto.soto@inventariocivil.bo',
            '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LkEYQIkW4LS',
            '79876543', true, NOW()-INTERVAL '20 days', NOW()-INTERVAL '20 days')
    RETURNING id INTO v_u4_id;

    INSERT INTO usuario_roles (usuario_id, rol_id) VALUES (v_u4_id, v_rol_ger);
    INSERT INTO usuario_proyectos (usuario_id, proyecto_id) VALUES (v_u4_id, v_proj1_id);
    INSERT INTO usuario_proyectos (usuario_id, proyecto_id) VALUES (v_u4_id, v_proj2_id);
    INSERT INTO usuario_proyectos (usuario_id, proyecto_id) VALUES (v_u4_id, v_proj3_id);
  END IF;

  -- Asignar admin a todos los proyectos si no está ya
  INSERT INTO usuario_proyectos (usuario_id, proyecto_id)
  SELECT v_admin_id, p.id FROM proyectos p
  WHERE NOT EXISTS (
    SELECT 1 FROM usuario_proyectos up
    WHERE up.usuario_id = v_admin_id AND up.proyecto_id = p.id
  );

  -- ── MOVIMIENTOS ADICIONALES (PROY-002 y PROY-003) ────────────────────────
  IF (SELECT COUNT(*) FROM movimientos_inventario) <= 15 THEN

    -- Ingresos para PROY-002 (puente)
    INSERT INTO movimientos_inventario
      (material_id, proyecto_id, tipo, cantidad, precio_unitario,
       proveedor_id, numero_factura, responsable_id, stock_anterior, stock_resultante, fecha_movimiento, created_at)
    VALUES
      (v_mat4_id,  v_proj2_id,'INGRESO', 40,  75.00, v_prov2_id,'FACT-2026-005', v_admin_id, 30, 70,  NOW()-INTERVAL '30 days', NOW()-INTERVAL '30 days'),
      (v_mat5_id,  v_proj2_id,'INGRESO', 60,  68.00, v_prov2_id,'FACT-2026-005', v_admin_id, 40, 100, NOW()-INTERVAL '30 days', NOW()-INTERVAL '30 days'),
      (v_mat10_id, v_proj2_id,'INGRESO',200,   2.10, v_prov3_id,'FACT-2026-006', v_admin_id,600, 800, NOW()-INTERVAL '25 days', NOW()-INTERVAL '25 days');

    -- Salidas PROY-002
    INSERT INTO movimientos_inventario
      (material_id, proyecto_id, tipo, cantidad, responsable_id,
       stock_anterior, stock_resultante, motivo, fecha_movimiento, created_at)
    VALUES
      (v_mat5_id,  v_proj2_id,'SALIDA', 30, v_admin_id, 100, 70,'Armado tablero puente tramo 1',    NOW()-INTERVAL '20 days', NOW()-INTERVAL '20 days'),
      (v_mat10_id, v_proj2_id,'SALIDA',100, v_admin_id, 800,700,'Encofrado estribos laterales',     NOW()-INTERVAL '15 days', NOW()-INTERVAL '15 days');

    -- Ingresos PROY-003 (residencia)
    INSERT INTO movimientos_inventario
      (material_id, proyecto_id, tipo, cantidad, precio_unitario,
       proveedor_id, numero_factura, responsable_id, stock_anterior, stock_resultante, fecha_movimiento, created_at)
    VALUES
      (v_mat8_id,  v_proj3_id,'INGRESO', 20, 120.00, v_prov3_id,'FACT-2026-007', v_admin_id, 30, 50, NOW()-INTERVAL '15 days', NOW()-INTERVAL '15 days'),
      (v_mat1_id,  v_proj3_id,'INGRESO',100,  55.00, v_prov2_id,'FACT-2026-007', v_admin_id, 45,145, NOW()-INTERVAL '15 days', NOW()-INTERVAL '15 days');

    -- Salidas PROY-003
    INSERT INTO movimientos_inventario
      (material_id, proyecto_id, tipo, cantidad, responsable_id,
       stock_anterior, stock_resultante, motivo, fecha_movimiento, created_at)
    VALUES
      (v_mat8_id,  v_proj3_id,'SALIDA', 10, v_admin_id,  50, 40,'Instalación sanitaria piso 1',    NOW()-INTERVAL '5 days', NOW()-INTERVAL '5 days'),
      (v_mat1_id,  v_proj3_id,'SALIDA', 30, v_admin_id, 145,115,'Contrapiso habitaciones nivel 1', NOW()-INTERVAL '3 days', NOW()-INTERVAL '3 days');

    -- Actualizar stocks finales tras todos los movimientos
    UPDATE materiales SET stock_actual =  70, updated_at = NOW() WHERE codigo = 'MAT-004';
    UPDATE materiales SET stock_actual =  70, updated_at = NOW() WHERE codigo = 'MAT-005';
    UPDATE materiales SET stock_actual =  40, updated_at = NOW() WHERE codigo = 'MAT-008';
    UPDATE materiales SET stock_actual = 700, updated_at = NOW() WHERE codigo = 'MAT-010';
    UPDATE materiales SET stock_actual = 115, updated_at = NOW() WHERE codigo = 'MAT-001';
  END IF;

  -- ── PROFORMA 3: CALCULADA para PROY-003 ─────────────────────────────────
  IF (SELECT COUNT(*) FROM proformas) < 3 THEN
    INSERT INTO proformas
      (proyecto_id, codigo, nombre, descripcion,
       fecha_elaboracion, elaborado_por, estado, created_at, updated_at)
    VALUES (
      v_proj3_id, 'PRO-003',
      'Estructura Residencia Los Andes',
      'Replantillo, cimentación y columnas de hormigón ciclópeo para 2 plantas',
      CURRENT_DATE - INTERVAL '5 days', v_admin_id, 'VIGENTE',
      NOW()-INTERVAL '5 days', NOW()-INTERVAL '4 days'
    ) RETURNING id INTO v_proforma3;

    INSERT INTO partidas_proforma (proforma_id, apu_id, cantidad, created_at) VALUES
      (v_proforma3, v_apu1_id, 18.0, NOW()-INTERVAL '5 days');

    INSERT INTO requerimientos (proforma_id, material_id, cantidad, created_at)
    VALUES (v_proforma3, v_mat1_id, 140.40, NOW()-INTERVAL '4 days');

    INSERT INTO requerimientos (proforma_id, material_id, cantidad, created_at)
    VALUES (v_proforma3, v_mat4_id,  11.70, NOW()-INTERVAL '4 days');
  END IF;

END $$;
