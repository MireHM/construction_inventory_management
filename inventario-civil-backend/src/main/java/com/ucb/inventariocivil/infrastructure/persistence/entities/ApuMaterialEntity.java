package com.ucb.inventariocivil.infrastructure.persistence.entities;

import jakarta.persistence.*;
import java.math.BigDecimal;

/**
 * Detalle de materiales de un APU.
 * cantidad_por_unidad: cuánto de ese material se necesita por 1 unidad de obra.
 * rendimiento_porcentaje: % de desperdicio adicional (ej: 5% = factor 1.05).
 */
@Entity
@Table(name = "apu_materiales",
       uniqueConstraints = @UniqueConstraint(columnNames = {"apu_id","material_id"}))
public class ApuMaterialEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "apu_id", nullable = false)
    private ApuEntity apu;

    @Column(name = "material_id", nullable = false)
    private Long materialId;

    @Column(name = "cantidad_por_unidad", nullable = false, precision = 12, scale = 4)
    private BigDecimal cantidadPorUnidad;

    @Column(name = "rendimiento_porcentaje", precision = 5, scale = 2)
    private BigDecimal rendimientoPorcentaje = BigDecimal.ZERO;

    @Column(length = 255)
    private String notas;

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public ApuEntity getApu() { return apu; }
    public void setApu(ApuEntity apu) { this.apu = apu; }
    public Long getMaterialId() { return materialId; }
    public void setMaterialId(Long materialId) { this.materialId = materialId; }
    public BigDecimal getCantidadPorUnidad() { return cantidadPorUnidad; }
    public void setCantidadPorUnidad(BigDecimal cantidadPorUnidad) { this.cantidadPorUnidad = cantidadPorUnidad; }
    public BigDecimal getRendimientoPorcentaje() { return rendimientoPorcentaje; }
    public void setRendimientoPorcentaje(BigDecimal rendimientoPorcentaje) { this.rendimientoPorcentaje = rendimientoPorcentaje; }
    public String getNotas() { return notas; }
    public void setNotas(String notas) { this.notas = notas; }
}
