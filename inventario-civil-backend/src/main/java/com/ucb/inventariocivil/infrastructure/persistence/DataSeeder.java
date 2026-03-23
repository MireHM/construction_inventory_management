package com.ucb.inventariocivil.infrastructure.persistence;

import com.ucb.inventariocivil.infrastructure.persistence.entities.*;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import java.math.BigDecimal;
import java.util.List;
import java.util.Set;

@Component
public class DataSeeder implements CommandLineRunner {

    private final RolJpaRepository      rolRepository;
    private final UsuarioJpaRepository  usuarioRepository;
    private final MaterialJpaRepository materialRepository;
    private final ApuJpaRepository      apuRepository;
    private final PasswordEncoder       passwordEncoder;

    public DataSeeder(RolJpaRepository r, UsuarioJpaRepository u,
                      MaterialJpaRepository m, ApuJpaRepository a,
                      PasswordEncoder p) {
        rolRepository = r; usuarioRepository = u;
        materialRepository = m; apuRepository = a; passwordEncoder = p;
    }

    @Override
    public void run(String... args) {
        seedRoles(); seedAdminUser(); seedMateriales(); seedApus();
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
