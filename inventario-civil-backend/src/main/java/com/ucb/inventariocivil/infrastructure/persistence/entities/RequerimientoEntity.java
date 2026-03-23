package com.ucb.inventariocivil.infrastructure.persistence.entities;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Resultado del motor de cálculo de requerimientos.
 * Por cada material y proforma almacena cuánto se necesita,
 * cuánto hay disponible y cuánto hay que comprar.
 */
@Entity
@Table(name = "requerimientos")
public class RequerimientoEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "proforma_id", nullable = false)
    private Long proformaId;

    @Column(name = "material_id", nullable = false)
    private Long materialId;

    @Column(name = "partida_id")
    private Long partidaId;

    /** Resultado del motor APU: cantidadObra × cantidadPorUnidad × (1 + rendimiento%) */
    @Column(name = "cantidad_calculada", nullable = false, precision = 14, scale = 3)
    private BigDecimal cantidadCalculada;

    /** Stock en el momento del cálculo */
    @Column(name = "cantidad_disponible", nullable = false, precision = 14, scale = 3)
    private BigDecimal cantidadDisponible;

    /** MAX(calculada - disponible, 0) – calculado en Java */
    @Column(name = "cantidad_a_comprar", precision = 14, scale = 3)
    private BigDecimal cantidadAComprar;

    @Column(name = "solicitado_por", nullable = false)
    private Long solicitadoPor;

    @Column(name = "fecha_calculo", nullable = false)
    private LocalDateTime fechaCalculo;

    @Column(columnDefinition = "TEXT")
    private String observaciones;

    @PrePersist
    protected void onCreate() {
        if (fechaCalculo == null) fechaCalculo = LocalDateTime.now();
    }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getProformaId() { return proformaId; }
    public void setProformaId(Long proformaId) { this.proformaId = proformaId; }
    public Long getMaterialId() { return materialId; }
    public void setMaterialId(Long materialId) { this.materialId = materialId; }
    public Long getPartidaId() { return partidaId; }
    public void setPartidaId(Long partidaId) { this.partidaId = partidaId; }
    public BigDecimal getCantidadCalculada() { return cantidadCalculada; }
    public void setCantidadCalculada(BigDecimal cantidadCalculada) { this.cantidadCalculada = cantidadCalculada; }
    public BigDecimal getCantidadDisponible() { return cantidadDisponible; }
    public void setCantidadDisponible(BigDecimal cantidadDisponible) { this.cantidadDisponible = cantidadDisponible; }
    public BigDecimal getCantidadAComprar() { return cantidadAComprar; }
    public void setCantidadAComprar(BigDecimal cantidadAComprar) { this.cantidadAComprar = cantidadAComprar; }
    public Long getSolicitadoPor() { return solicitadoPor; }
    public void setSolicitadoPor(Long solicitadoPor) { this.solicitadoPor = solicitadoPor; }
    public LocalDateTime getFechaCalculo() { return fechaCalculo; }
    public void setFechaCalculo(LocalDateTime fechaCalculo) { this.fechaCalculo = fechaCalculo; }
    public String getObservaciones() { return observaciones; }
    public void setObservaciones(String observaciones) { this.observaciones = observaciones; }
}
