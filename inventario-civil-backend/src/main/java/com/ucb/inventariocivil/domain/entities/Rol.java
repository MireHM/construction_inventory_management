package com.ucb.inventariocivil.domain.entities;

/**
 * Entidad de dominio Rol.
 * Valores: ADMINISTRADOR, ALMACENERO, RESIDENTE, GERENTE
 */
public class Rol {

    private Long id;
    private String nombre;
    private String descripcion;
    private boolean activo;

    public Rol() {}

    public Rol(Long id, String nombre) {
        this.id = id;
        this.nombre = nombre;
        this.activo = true;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }
}
