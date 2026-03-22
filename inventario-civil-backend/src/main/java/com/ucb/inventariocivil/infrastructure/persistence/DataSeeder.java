package com.ucb.inventariocivil.infrastructure.persistence;

import com.ucb.inventariocivil.infrastructure.persistence.entities.RolEntity;
import com.ucb.inventariocivil.infrastructure.persistence.entities.UsuarioEntity;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.RolJpaRepository;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.UsuarioJpaRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Set;

/**
 * Inicializa la base de datos con datos semilla al arrancar la aplicación.
 * Crea los 4 roles y un usuario administrador por defecto si no existen.
 *
 * Credenciales por defecto:
 *   Email:    admin@inventariocivil.bo
 *   Password: Admin2025#
 */
@Component
public class DataSeeder implements CommandLineRunner {

    private final RolJpaRepository rolRepository;
    private final UsuarioJpaRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    public DataSeeder(RolJpaRepository rolRepository,
                      UsuarioJpaRepository usuarioRepository,
                      PasswordEncoder passwordEncoder) {
        this.rolRepository = rolRepository;
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        seedRoles();
        seedAdminUser();
    }

    private void seedRoles() {
        List<String> roles = List.of("ADMINISTRADOR", "ALMACENERO", "RESIDENTE", "GERENTE");
        roles.forEach(nombre -> {
            if (!rolRepository.existsByNombre(nombre)) {
                RolEntity rol = new RolEntity();
                rol.setNombre(nombre);
                rol.setDescripcion("Rol " + nombre);
                rolRepository.save(rol);
            }
        });
    }

    private void seedAdminUser() {
        String adminEmail = "admin@inventariocivil.bo";
        if (!usuarioRepository.existsByEmail(adminEmail)) {
            RolEntity rolAdmin = rolRepository.findByNombre("ADMINISTRADOR").orElseThrow();

            UsuarioEntity admin = new UsuarioEntity();
            admin.setNombre("Administrador del Sistema");
            admin.setEmail(adminEmail);
            admin.setPasswordHash(passwordEncoder.encode("Admin2025#"));
            admin.setActivo(true);
            admin.setRoles(Set.of(rolAdmin));
            usuarioRepository.save(admin);

            System.out.println("✅ Usuario admin creado: " + adminEmail + " / Admin2025#");
        }
    }
}
