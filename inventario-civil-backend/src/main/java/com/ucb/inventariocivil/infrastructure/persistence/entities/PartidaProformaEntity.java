package com.ucb.inventariocivil.infrastructure.persistence.entities;

import jakarta.persistence.*;
import java.math.BigDecimal;

/**
 * Partida de una proforma de obra.
 * Vincula un APU con la cantidad de obra a ejecutar.
 * Ej: APU-002 (Hormigón H-180) con 45 m³ de cantidad de obra.
 */
@Entity
@Table(name = "partidas_proforma")
public class PartidaProformaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "proforma_id", nullable = false)
    private ProformaEntity proforma;

    @Column(name = "apu_id", nullable = false)
    private Long apuId;

    @Column(name = "item_numero", length = 20)
    private String itemNumero; // 1.1, 1.2, 2.1...

    @Column(length = 300)
    private String descripcion;

    @Column(name = "cantidad_obra", nullable = false, precision = 14, scale = 4)
    private BigDecimal cantidadObra;

    @Column(name = "precio_unitario", precision = 12, scale = 2)
    private BigDecimal precioUnitario;

    @Column(columnDefinition = "TEXT")
    private String observaciones;

    @Column(nullable = false)
    private int orden = 1;

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public ProformaEntity getProforma() { return proforma; }
    public void setProforma(ProformaEntity proforma) { this.proforma = proforma; }
    public Long getApuId() { return apuId; }
    public void setApuId(Long apuId) { this.apuId = apuId; }
    public String getItemNumero() { return itemNumero; }
    public void setItemNumero(String itemNumero) { this.itemNumero = itemNumero; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public BigDecimal getCantidadObra() { return cantidadObra; }
    public void setCantidadObra(BigDecimal cantidadObra) { this.cantidadObra = cantidadObra; }
    public BigDecimal getPrecioUnitario() { return precioUnitario; }
    public void setPrecioUnitario(BigDecimal precioUnitario) { this.precioUnitario = precioUnitario; }
    public String getObservaciones() { return observaciones; }
    public void setObservaciones(String observaciones) { this.observaciones = observaciones; }
    public int getOrden() { return orden; }
    public void setOrden(int orden) { this.orden = orden; }
}
