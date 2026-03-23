package com.ucb.inventariocivil.infrastructure.persistence.entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Análisis de Precios Unitarios (APU).
 * Define qué materiales y en qué cantidad se necesitan por cada
 * unidad de obra ejecutada (ej: 6.5 sacos de cemento por 1 m³ de hormigón).
 */
@Entity
@Table(name = "apus")
public class ApuEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 30)
    private String codigo;

    @Column(nullable = false, length = 200)
    private String nombre;

    @Column(columnDefinition = "TEXT")
    private String descripcion;

    @Column(name = "unidad_obra", nullable = false, length = 50)
    private String unidadObra; // m2, m3, ml, und, kg, etc.

    @Column(nullable = false)
    private boolean activo = true;

    @OneToMany(mappedBy = "apu", cascade = CascadeType.ALL, orphanRemoval = true,
               fetch = FetchType.EAGER)
    private List<ApuMaterialEntity> materiales;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() { updatedAt = LocalDateTime.now(); }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public String getUnidadObra() { return unidadObra; }
    public void setUnidadObra(String unidadObra) { this.unidadObra = unidadObra; }
    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }
    public List<ApuMaterialEntity> getMateriales() { return materiales; }
    public void setMateriales(List<ApuMaterialEntity> materiales) { this.materiales = materiales; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
