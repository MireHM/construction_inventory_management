package com.ucb.inventariocivil.infrastructure.persistence.entities;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "alertas_stock")
public class AlertaStockEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "material_id", nullable = false)
    private Long materialId;

    @Column(nullable = false, length = 20)
    private String tipo; // STOCK_MINIMO | STOCK_MAXIMO | SIN_STOCK

    @Column(name = "stock_al_momento", nullable = false, precision = 14, scale = 3)
    private BigDecimal stockAlMomento;

    @Column(nullable = false)
    private boolean atendida = false;

    @Column(name = "atendida_por")
    private Long atendidaPor;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() { createdAt = LocalDateTime.now(); }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getMaterialId() { return materialId; }
    public void setMaterialId(Long materialId) { this.materialId = materialId; }
    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }
    public BigDecimal getStockAlMomento() { return stockAlMomento; }
    public void setStockAlMomento(BigDecimal v) { this.stockAlMomento = v; }
    public boolean isAtendida() { return atendida; }
    public void setAtendida(boolean atendida) { this.atendida = atendida; }
    public Long getAtendidaPor() { return atendidaPor; }
    public void setAtendidaPor(Long atendidaPor) { this.atendidaPor = atendidaPor; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
