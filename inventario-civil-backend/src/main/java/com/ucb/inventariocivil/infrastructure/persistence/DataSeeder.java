package com.ucb.inventariocivil.infrastructure.persistence;

import com.ucb.inventariocivil.infrastructure.persistence.entities.*;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;

@Component
public class DataSeeder implements CommandLineRunner {

    private final RolJpaRepository        rolRepository;
    private final UsuarioJpaRepository    usuarioRepository;
    private final MaterialJpaRepository   materialRepository;
    private final ApuJpaRepository        apuRepository;
    private final ProyectoJpaRepository   proyectoRepository;
    private final ProveedorJpaRepository  proveedorRepository;
    private final CategoriaJpaRepository  categoriaRepository;
    private final UnidadMedidaJpaRepository unidadMedidaRepository;
    private final PasswordEncoder         passwordEncoder;

    public DataSeeder(RolJpaRepository r, UsuarioJpaRepository u,
                      MaterialJpaRepository m, ApuJpaRepository a,
                      ProyectoJpaRepository pr, ProveedorJpaRepository pv,
                      CategoriaJpaRepository cat, UnidadMedidaJpaRepository um,
                      PasswordEncoder p) {
        rolRepository = r; usuarioRepository = u;
        materialRepository = m; apuRepository = a;
        proyectoRepository = pr; proveedorRepository = pv;
        categoriaRepository = cat; unidadMedidaRepository = um;
        passwordEncoder = p;
    }

    @Override
    public void run(String... args) {
        seedCategorias(); seedUnidadesMedida();
        seedRoles(); seedAdminUser(); seedMateriales(); seedApus();
        seedProyectos(); seedProveedores();
    }

    private void seedCategorias() {
        if (categoriaRepository.count() > 0) return;
        String[][] cats = {
            {"Áridos y Pétreos","Arena, grava, piedra y materiales granulares"},
            {"Cementos y Conglomerantes","Cemento, cal, yeso"},
            {"Acero y Fierro","Varillas, perfiles, mallas de acero"},
            {"Maderas y Carpintería","Tablones, vigas, encofrados de madera"},
            {"Instalaciones Eléctricas","Cables, tuberías, accesorios eléctricos"},
            {"Pinturas y Revestimientos","Pinturas, selladores, barnices"},
            {"Instalaciones Sanitarias","Tuberías, válvulas, sanitarios"},
            {"Cerámicos y Mampostería","Ladrillos, bloques, cerámicos"},
        };
        for (String[] c : cats) {
            if (!categoriaRepository.existsByNombre(c[0])) {
                CategoriaEntity cat = new CategoriaEntity();
                cat.setNombre(c[0]); cat.setDescripcion(c[1]);
                categoriaRepository.save(cat);
            }
        }
        System.out.println("✅ Categorías creadas.");
    }

    private void seedUnidadesMedida() {
        if (unidadMedidaRepository.count() > 0) return;
        String[][] ums = {
            {"barra","Barra"},
            {"kg","Kilogramo"},
            {"m3","Metro cúbico"},
            {"m2","Metro cuadrado"},
            {"pza","Pieza"},
            {"ml","Metro lineal"},
            {"litro","Litro"},
            {"bolsa","Bolsa"},
            {"galón","Galón"},
        };
        for (String[] u : ums) {
            if (!unidadMedidaRepository.existsBySimbolo(u[0])) {
                UnidadMedidaEntity um = new UnidadMedidaEntity();
                um.setSimbolo(u[0]); um.setNombre(u[1]);
                unidadMedidaRepository.save(um);
            }
        }
        System.out.println("✅ Unidades de medida creadas.");
    }

    private void seedRoles() {
        List.of("ADMINISTRADOR","ALMACENERO","RESIDENTE","GERENTE").forEach(n -> {
            if (!rolRepository.existsByNombre(n)) {
                RolEntity r = new RolEntity(); r.setNombre(n); r.setDescripcion("Rol "+n);
                rolRepository.save(r);
            }
        });
    }

    private void seedAdminUser() {
        String email = "admin@inventariocivil.bo";
        if (!usuarioRepository.existsByEmail(email)) {
            RolEntity rol = rolRepository.findByNombre("ADMINISTRADOR").orElseThrow();
            UsuarioEntity u = new UsuarioEntity();
            u.setNombre("Administrador del Sistema"); u.setEmail(email);
            u.setPasswordHash(passwordEncoder.encode("Admin2025#"));
            u.setActivo(true); u.setRoles(Set.of(rol));
            usuarioRepository.save(u);
            System.out.println("✅ Admin: " + email + " / Admin2025#");
        }
    }

    private void seedMateriales() {
        if (materialRepository.count() > 0) return;
        Object[][] mats = {
            {"MAT-001","Cemento Portland IP-30 (50kg)",2L,8L,55.00,50.0,200.0},
            {"MAT-002","Arena fina cernida",1L,3L,120.00,10.0,50.0},
            {"MAT-003","Grava 1/2\"",1L,3L,90.00,10.0,50.0},
            {"MAT-004","Piedra bolón",1L,3L,75.00,5.0,30.0},
            {"MAT-005","Varilla corrugada Ø12mm",3L,1L,68.00,20.0,100.0},
            {"MAT-006","Varilla corrugada Ø8mm",3L,1L,32.00,30.0,150.0},
            {"MAT-007","Ladrillo 6 huecos 18x12x8cm",8L,5L,1.20,500.0,3000.0},
            {"MAT-008","Arena gruesa para mortero",1L,3L,95.00,5.0,30.0},
            {"MAT-009","Pintura látex interior blanca",6L,9L,35.00,10.0,60.0},
            {"MAT-010","Madera encofrado 1x6 pie",4L,5L,4.50,200.0,1500.0},
        };
        for (Object[] m : mats) {
            if (!materialRepository.existsByCodigo((String)m[0])) {
                MaterialEntity mat = new MaterialEntity();
                mat.setCodigo((String)m[0]); mat.setNombre((String)m[1]);
                mat.setCategoriaId((Long)m[2]); mat.setUnidadMedidaId((Long)m[3]);
                mat.setPrecioReferencia(BigDecimal.valueOf((Double)m[4]));
                mat.setStockMinimo(BigDecimal.valueOf((Double)m[5]));
                mat.setStockMaximo(BigDecimal.valueOf((Double)m[6]));
                mat.setStockActual(BigDecimal.valueOf((Double)m[5]*3));
                materialRepository.save(mat);
            }
        }
        System.out.println("✅ Materiales creados.");
    }

    private void seedApus() {
        if (apuRepository.count() > 0) return;
        // APU-001: Hormigón Ciclópeo H-150 por m³
        saveApu("APU-001","Hormigón Ciclópeo H-150","Mezcla 1:3:5","m3",
            new long[]{1,2,3,4},
            new String[]{"2.80","0.45","0.65","0.40"},
            new String[]{"5.00","3.00","3.00","2.00"});
        // APU-002: Hormigón Simple H-180 por m³
        saveApu("APU-002","Hormigón Simple H-180","Mezcla 1:2:3","m3",
            new long[]{1,2,3},
            new String[]{"6.50","0.55","0.75"},
            new String[]{"5.00","3.00","3.00"});
        // APU-003: Muro Ladrillo por m²
        saveApu("APU-003","Muro Ladrillo 6 Huecos 15cm","Espesor 15cm","m2",
            new long[]{7,1,8},
            new String[]{"55.0","0.22","0.04"},
            new String[]{"5.00","5.00","3.00"});
        System.out.println("✅ APUs creados.");
    }

    private void seedProyectos() {
        if (proyectoRepository.count() > 0) return;
        Object[][] proyectos = {
            {"PROY-001","Edificio Central UCB","Construcción edificio 5 pisos","EN_EJECUCION",
             "2025-01-15","2026-12-31",1L,2500000.00},
            {"PROY-002","Puente Río Choqueyapu","Puente peatonal 30m","PLANIFICACION",
             "2026-03-01","2027-06-30",1L,800000.00},
            {"PROY-003","Pavimentación Av. Brasil","Repavimentación 2km","PLANIFICACION",
             "2026-07-01","2027-01-31",1L,450000.00},
        };
        for (Object[] p : proyectos) {
            if (!proyectoRepository.existsByCodigo((String)p[0])) {
                ProyectoEntity proyecto = new ProyectoEntity();
                proyecto.setCodigo((String)p[0]);
                proyecto.setNombre((String)p[1]);
                proyecto.setDescripcion((String)p[2]);
                proyecto.setEstado((String)p[3]);
                proyecto.setFechaInicio(LocalDate.parse((String)p[4]));
                proyecto.setFechaFinEstimada(LocalDate.parse((String)p[5]));
                proyecto.setResponsableId((Long)p[6]);
                proyecto.setPresupuesto(BigDecimal.valueOf((Double)p[7]));
                proyecto.setActivo(true);
                proyectoRepository.save(proyecto);
            }
        }
        System.out.println("✅ Proyectos creados.");
    }

    private void seedProveedores() {
        if (proveedorRepository.count() > 0) return;
        Object[][] proveedores = {
            {"SOBOCE S.A.","1234567","76543210","ventas@soboce.com","Av. Arce 2631, La Paz","Juan Pérez"},
            {"VIABOL Constructora","2345678","75432109","info@viabol.com","Calle 21 de Calacoto 789, La Paz","María López"},
            {"FERRETERÍA EL CONSTRUCTOR","3456789","74321098","ferretero@gmail.com","Mercado Rodríguez, La Paz","Carlos Mamani"},
        };
        for (Object[] pv : proveedores) {
            if (!proveedorRepository.existsByNit((String)pv[1])) {
                ProveedorEntity proveedor = new ProveedorEntity();
                proveedor.setNombre((String)pv[0]);
                proveedor.setNit((String)pv[1]);
                proveedor.setTelefono((String)pv[2]);
                proveedor.setEmail((String)pv[3]);
                proveedor.setDireccion((String)pv[4]);
                proveedor.setContacto((String)pv[5]);
                proveedor.setActivo(true);
                proveedorRepository.save(proveedor);
            }
        }
        System.out.println("✅ Proveedores creados.");
    }

    private void saveApu(String codigo, String nombre, String desc, String unidad,
                         long[] matIds, String[] cantidades, String[] rendimientos) {
        if (apuRepository.existsByCodigo(codigo)) return;
        ApuEntity apu = new ApuEntity();
        apu.setCodigo(codigo); apu.setNombre(nombre);
        apu.setDescripcion(desc); apu.setUnidadObra(unidad);
        List<ApuMaterialEntity> items = new java.util.ArrayList<>();
        for (int i = 0; i < matIds.length; i++) {
            ApuMaterialEntity m = new ApuMaterialEntity();
            m.setApu(apu); m.setMaterialId(matIds[i]);
            m.setCantidadPorUnidad(new BigDecimal(cantidades[i]));
            m.setRendimientoPorcentaje(new BigDecimal(rendimientos[i]));
            items.add(m);
        }
        apu.setMateriales(items);
        apuRepository.save(apu);
    }
}
