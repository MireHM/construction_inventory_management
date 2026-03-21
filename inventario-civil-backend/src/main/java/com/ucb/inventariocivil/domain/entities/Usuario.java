package com.ucb.inventariocivil.domain.entities;

import java.time.LocalDateTime;
import java.util.Set;

/**
 * Entidad de dominio Usuario.
 * Capa de Dominio – sin dependencias de frameworks externos.
 */
public class Usuario {

    private Long id;
    private String nombre;
    private String email;
    private String passwordHash;
    private String telefono;
    private boolean activo;
    private Set<Rol> roles;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Usuario() {}

    public Usuario(Long id, String nombre, String email,
                   String passwordHash, boolean activo, Set<Rol> roles) {
        this.id = id;
        this.nombre = nombre;
        this.email = email;
        this.passwordHash = passwordHash;
        this.activo = activo;
        this.roles = roles;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public boolean tieneRol(String nombreRol) {
        return roles != null && roles.stream()
                .anyMatch(r -> r.getNombre().equalsIgnoreCase(nombreRol));
    }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }

    public Set<Rol> getRoles() { return roles; }
    public void setRoles(Set<Rol> roles) { this.roles = roles; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
