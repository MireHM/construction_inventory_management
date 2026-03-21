package com.ucb.inventariocivil.domain.entities;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Entidad de dominio Material.
 * Capa de Dominio – contiene reglas de negocio puras.
 */
public class Material {

    private Long id;
    private String codigo;
    private String nombre;
    private String descripcion;
    private Long categoriaId;
    private Long unidadMedidaId;
    private BigDecimal precioReferencia;
    private BigDecimal stockActual;
    private BigDecimal stockMinimo;
    private BigDecimal stockMaximo;
    private boolean activo;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Material() {}

    // Regla de negocio: ¿el stock está en nivel crítico?
    public boolean esCritico() {
        return stockActual != null && stockMinimo != null
                && stockActual.compareTo(BigDecimal.ZERO) == 0;
    }

    // Regla de negocio: ¿el stock está por debajo del mínimo?
    public boolean estaBajoMinimo() {
        return stockActual != null && stockMinimo != null
                && stockActual.compareTo(stockMinimo) < 0;
    }

    // Regla de negocio: ¿hay suficiente stock para una cantidad dada?
    public boolean tieneStockSuficiente(BigDecimal cantidadRequerida) {
        return stockActual != null
                && stockActual.compareTo(cantidadRequerida) >= 0;
    }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public Long getCategoriaId() { return categoriaId; }
    public void setCategoriaId(Long categoriaId) { this.categoriaId = categoriaId; }

    public Long getUnidadMedidaId() { return unidadMedidaId; }
    public void setUnidadMedidaId(Long unidadMedidaId) { this.unidadMedidaId = unidadMedidaId; }

    public BigDecimal getPrecioReferencia() { return precioReferencia; }
    public void setPrecioReferencia(BigDecimal precioReferencia) { this.precioReferencia = precioReferencia; }

    public BigDecimal getStockActual() { return stockActual; }
    public void setStockActual(BigDecimal stockActual) { this.stockActual = stockActual; }

    public BigDecimal getStockMinimo() { return stockMinimo; }
    public void setStockMinimo(BigDecimal stockMinimo) { this.stockMinimo = stockMinimo; }

    public BigDecimal getStockMaximo() { return stockMaximo; }
    public void setStockMaximo(BigDecimal stockMaximo) { this.stockMaximo = stockMaximo; }

    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
