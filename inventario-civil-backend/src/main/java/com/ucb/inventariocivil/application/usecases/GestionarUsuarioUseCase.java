package com.ucb.inventariocivil.application.usecases;

import com.ucb.inventariocivil.domain.exceptions.RecursoNoEncontradoException;
import com.ucb.inventariocivil.infrastructure.persistence.entities.ProyectoEntity;
import com.ucb.inventariocivil.infrastructure.persistence.entities.RolEntity;
import com.ucb.inventariocivil.infrastructure.persistence.entities.UsuarioEntity;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.ProyectoJpaRepository;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.RolJpaRepository;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.UsuarioJpaRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
public class GestionarUsuarioUseCase {

    private final UsuarioJpaRepository usuarioRepository;
    private final RolJpaRepository rolRepository;
    private final ProyectoJpaRepository proyectoRepository;
    private final PasswordEncoder passwordEncoder;

    public GestionarUsuarioUseCase(UsuarioJpaRepository usuarioRepository,
                                   RolJpaRepository rolRepository,
                                   ProyectoJpaRepository proyectoRepository,
                                   PasswordEncoder passwordEncoder) {
        this.usuarioRepository = usuarioRepository;
        this.rolRepository = rolRepository;
        this.proyectoRepository = proyectoRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional(readOnly = true)
    public List<UsuarioEntity> listarTodos() {
        return usuarioRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<UsuarioEntity> listarActivos() {
        return usuarioRepository.findByActivoTrue();
    }

    @Transactional(readOnly = true)
    public UsuarioEntity obtenerPorId(Long id) {
        return usuarioRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado con id: " + id));
    }

    @Transactional
    public UsuarioEntity crear(String nombre, String email, String password, String telefono) {
        if (usuarioRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Ya existe un usuario con email: " + email);
        }
        UsuarioEntity usuario = new UsuarioEntity();
        usuario.setNombre(nombre);
        usuario.setEmail(email);
        usuario.setPasswordHash(passwordEncoder.encode(password));
        usuario.setTelefono(telefono);
        usuario.setActivo(true);
        return usuarioRepository.save(usuario);
    }

    @Transactional
    public UsuarioEntity actualizar(Long id, String nombre, String telefono) {
        UsuarioEntity usuario = obtenerPorId(id);
        if (nombre != null && !nombre.isBlank()) usuario.setNombre(nombre);
        if (telefono != null) usuario.setTelefono(telefono);
        return usuarioRepository.save(usuario);
    }

    @Transactional
    public UsuarioEntity cambiarPassword(Long id, String nuevaPassword) {
        UsuarioEntity usuario = obtenerPorId(id);
        usuario.setPasswordHash(passwordEncoder.encode(nuevaPassword));
        return usuarioRepository.save(usuario);
    }

    @Transactional
    public UsuarioEntity toggleActivo(Long id) {
        UsuarioEntity usuario = obtenerPorId(id);
        usuario.setActivo(!usuario.isActivo());
        return usuarioRepository.save(usuario);
    }

    @Transactional
    public UsuarioEntity asignarRoles(Long usuarioId, List<Long> rolIds) {
        UsuarioEntity usuario = obtenerPorId(usuarioId);
        Set<RolEntity> roles = new HashSet<>();
        for (Long rolId : rolIds) {
            RolEntity rol = rolRepository.findById(rolId)
                    .orElseThrow(() -> new RecursoNoEncontradoException("Rol no encontrado con id: " + rolId));
            roles.add(rol);
        }
        usuario.setRoles(roles);
        return usuarioRepository.save(usuario);
    }

    @Transactional
    public UsuarioEntity asignarProyectos(Long usuarioId, List<Long> proyectoIds) {
        UsuarioEntity usuario = obtenerPorId(usuarioId);
        Set<ProyectoEntity> proyectos = new HashSet<>();
        for (Long proyectoId : proyectoIds) {
            ProyectoEntity proyecto = proyectoRepository.findById(proyectoId)
                    .orElseThrow(() -> new RecursoNoEncontradoException("Proyecto no encontrado con id: " + proyectoId));
            proyectos.add(proyecto);
        }
        usuario.setProyectos(proyectos);
        return usuarioRepository.save(usuario);
    }
}
