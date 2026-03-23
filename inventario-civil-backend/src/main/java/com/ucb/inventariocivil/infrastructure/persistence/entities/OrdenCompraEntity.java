package com.ucb.inventariocivil.infrastructure.persistence.entities;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Orden de Compra generada a partir de un requerimiento.
 * Estados: PENDIENTE → APROBADA → RECIBIDA | RECHAZADA | ANULADA
 */
@Entity
@Table(name = "ordenes_compra")
public class OrdenCompraEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "requerimiento_id", nullable = false)
    private Long requerimientoId;

    @Column(name = "material_id", nullable = false)
    private Long materialId;

    @Column(name = "proveedor_id")
    private Long proveedorId;

    @Column(name = "nombre_proveedor", length = 200)
    private String nombreProveedor;

    @Column(nullable = false, precision = 14, scale = 3)
    private BigDecimal cantidad;

    @Column(name = "precio_unitario", precision = 12, scale = 2)
    private BigDecimal precioUnitario;

    @Column(name = "costo_estimado", precision = 14, scale = 2)
    private BigDecimal costoEstimado;

    @Column(nullable = false, length = 20)
    private String estado = "PENDIENTE";

    @Column(name = "generada_por", nullable = false)
    private Long generadaPor;

    @Column(name = "aprobada_por")
    private Long aprobadaPor;

    @Column(name = "fecha_generacion", nullable = false)
    private LocalDateTime fechaGeneracion;

    @Column(name = "fecha_aprobacion")
    private LocalDateTime fechaAprobacion;

    @Column(name = "fecha_recepcion")
    private LocalDateTime fechaRecepcion;

    @Column(columnDefinition = "TEXT")
    private String observaciones;

    @PrePersist
    protected void onCreate() {
        if (fechaGeneracion == null) fechaGeneracion = LocalDateTime.now();
        if (costoEstimado == null && cantidad != null && precioUnitario != null) {
            costoEstimado = cantidad.multiply(precioUnitario);
        }
    }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getRequerimientoId() { return requerimientoId; }
    public void setRequerimientoId(Long requerimientoId) { this.requerimientoId = requerimientoId; }
    public Long getMaterialId() { return materialId; }
    public void setMaterialId(Long materialId) { this.materialId = materialId; }
    public Long getProveedorId() { return proveedorId; }
    public void setProveedorId(Long proveedorId) { this.proveedorId = proveedorId; }
    public String getNombreProveedor() { return nombreProveedor; }
    public void setNombreProveedor(String nombreProveedor) { this.nombreProveedor = nombreProveedor; }
    public BigDecimal getCantidad() { return cantidad; }
    public void setCantidad(BigDecimal cantidad) { this.cantidad = cantidad; }
    public BigDecimal getPrecioUnitario() { return precioUnitario; }
    public void setPrecioUnitario(BigDecimal precioUnitario) { this.precioUnitario = precioUnitario; }
    public BigDecimal getCostoEstimado() { return costoEstimado; }
    public void setCostoEstimado(BigDecimal costoEstimado) { this.costoEstimado = costoEstimado; }
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    public Long getGeneradaPor() { return generadaPor; }
    public void setGeneradaPor(Long generadaPor) { this.generadaPor = generadaPor; }
    public Long getAprobadaPor() { return aprobadaPor; }
    public void setAprobadaPor(Long aprobadaPor) { this.aprobadaPor = aprobadaPor; }
    public LocalDateTime getFechaGeneracion() { return fechaGeneracion; }
    public void setFechaGeneracion(LocalDateTime fechaGeneracion) { this.fechaGeneracion = fechaGeneracion; }
    public LocalDateTime getFechaAprobacion() { return fechaAprobacion; }
    public void setFechaAprobacion(LocalDateTime fechaAprobacion) { this.fechaAprobacion = fechaAprobacion; }
    public LocalDateTime getFechaRecepcion() { return fechaRecepcion; }
    public void setFechaRecepcion(LocalDateTime fechaRecepcion) { this.fechaRecepcion = fechaRecepcion; }
    public String getObservaciones() { return observaciones; }
    public void setObservaciones(String observaciones) { this.observaciones = observaciones; }
}
