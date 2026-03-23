package com.ucb.inventariocivil.application.usecases;

import com.ucb.inventariocivil.domain.exceptions.DomainException;
import com.ucb.inventariocivil.domain.exceptions.RecursoNoEncontradoException;
import com.ucb.inventariocivil.infrastructure.persistence.entities.AlertaStockEntity;
import com.ucb.inventariocivil.infrastructure.persistence.entities.MaterialEntity;
import com.ucb.inventariocivil.infrastructure.persistence.entities.MovimientoInventarioEntity;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.AlertaStockJpaRepository;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.MaterialJpaRepository;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.MovimientoJpaRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

/**
 * Caso de uso: Registrar Movimiento de Inventario.
 * Capa de Aplicación – aplica las reglas de negocio del inventario:
 *  - Actualiza el stock del material atómicamente.
 *  - Impide salidas que dejen stock negativo.
 *  - Genera alertas automáticas si el stock cae por debajo del mínimo.
 */
@Service
public class RegistrarMovimientoInventarioUseCase {

    private final MovimientoJpaRepository movimientoRepository;
    private final MaterialJpaRepository   materialRepository;
    private final AlertaStockJpaRepository alertaRepository;

    public RegistrarMovimientoInventarioUseCase(
            MovimientoJpaRepository movimientoRepository,
            MaterialJpaRepository materialRepository,
            AlertaStockJpaRepository alertaRepository) {
        this.movimientoRepository = movimientoRepository;
        this.materialRepository   = materialRepository;
        this.alertaRepository     = alertaRepository;
    }

    // ── Registrar movimiento ─────────────────────────────────────────────────

    @Transactional
    public MovimientoInventarioEntity registrar(MovimientoInventarioEntity movimiento) {
        MaterialEntity material = materialRepository.findById(movimiento.getMaterialId())
                .orElseThrow(() -> new RecursoNoEncontradoException(
                        "Material", movimiento.getMaterialId()));

        BigDecimal stockAnterior = material.getStockActual();
        BigDecimal cantidad      = movimiento.getCantidad();
        BigDecimal stockNuevo;

        switch (movimiento.getTipo().toUpperCase()) {
            case "INGRESO":
            case "DEVOLUCION":
                stockNuevo = stockAnterior.add(cantidad);
                break;
            case "SALIDA":
                if (stockAnterior.compareTo(cantidad) < 0) {
                    throw new DomainException(
                            "Stock insuficiente. Disponible: " + stockAnterior
                            + ", solicitado: " + cantidad);
                }
                stockNuevo = stockAnterior.subtract(cantidad);
                break;
            case "AJUSTE":
                stockNuevo = cantidad; // ajuste directo al valor indicado
                break;
            default:
                throw new DomainException("Tipo de movimiento inválido: " + movimiento.getTipo());
        }

        // Persistir el movimiento con el snapshot del stock
        movimiento.setStockAnterior(stockAnterior);
        movimiento.setStockResultante(stockNuevo);
        MovimientoInventarioEntity guardado = movimientoRepository.save(movimiento);

        // Actualizar stock del material
        material.setStockActual(stockNuevo);
        materialRepository.save(material);

        // Generar alerta si el stock cae por debajo del mínimo
        generarAlertaSiCorresponde(material, stockNuevo);

        return guardado;
    }

    // ── Consultas ────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<MovimientoInventarioEntity> historialPorMaterial(Long materialId) {
        return movimientoRepository
                .findByMaterialIdOrderByFechaMovimientoDesc(materialId);
    }

    @Transactional(readOnly = true)
    public List<MovimientoInventarioEntity> ultimos(int cantidad) {
        return movimientoRepository.findUltimos(PageRequest.of(0, cantidad));
    }

    @Transactional(readOnly = true)
    public List<AlertaStockEntity> alertasPendientes() {
        return alertaRepository.findByAtendidaFalseOrderByCreatedAtDesc();
    }

    // ── Lógica de alertas ────────────────────────────────────────────────────

    private void generarAlertaSiCorresponde(MaterialEntity material, BigDecimal stockNuevo) {
        String tipoAlerta = null;

        if (stockNuevo.compareTo(BigDecimal.ZERO) == 0) {
            tipoAlerta = "SIN_STOCK";
        } else if (stockNuevo.compareTo(material.getStockMinimo()) < 0) {
            tipoAlerta = "STOCK_MINIMO";
        } else if (material.getStockMaximo() != null
                && stockNuevo.compareTo(material.getStockMaximo()) > 0) {
            tipoAlerta = "STOCK_MAXIMO";
        }

        if (tipoAlerta != null) {
            AlertaStockEntity alerta = new AlertaStockEntity();
            alerta.setMaterialId(material.getId());
            alerta.setTipo(tipoAlerta);
            alerta.setStockAlMomento(stockNuevo);
            alertaRepository.save(alerta);
        }
    }
}
