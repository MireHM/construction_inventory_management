package com.ucb.inventariocivil.domain.repositories;

import com.ucb.inventariocivil.domain.entities.Usuario;

import java.util.List;
import java.util.Optional;

/**
 * Puerto (Port) del repositorio de Usuario.
 * Capa de Dominio – interfaz pura, sin dependencias de JPA.
 * La implementación concreta vive en la capa de Infraestructura.
 */
public interface UsuarioRepository {

    Optional<Usuario> findById(Long id);

    Optional<Usuario> findByEmail(String email);

    boolean existsByEmail(String email);

    List<Usuario> findAll();

    Usuario save(Usuario usuario);

    void deleteById(Long id);
}
