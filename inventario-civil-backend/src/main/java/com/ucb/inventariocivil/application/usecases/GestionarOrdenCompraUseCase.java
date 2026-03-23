package com.ucb.inventariocivil.application.usecases;

import com.ucb.inventariocivil.domain.exceptions.DomainException;
import com.ucb.inventariocivil.domain.exceptions.RecursoNoEncontradoException;
import com.ucb.inventariocivil.infrastructure.persistence.entities.OrdenCompraEntity;
import com.ucb.inventariocivil.infrastructure.persistence.entities.RequerimientoEntity;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.OrdenCompraJpaRepository;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.RequerimientoJpaRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Caso de uso: Gestión de Órdenes de Compra.
 * - Genera OCs a partir de requerimientos con cantidadAComprar > 0.
 * - Maneja el ciclo de vida: PENDIENTE → APROBADA → RECIBIDA.
 * - Al RECIBIR una OC registra automáticamente el ingreso al inventario.
 */
@Service
public class GestionarOrdenCompraUseCase {

    private final OrdenCompraJpaRepository       ocRepository;
    private final RequerimientoJpaRepository     requerimientoRepository;
    private final RegistrarMovimientoInventarioUseCase movimientoUseCase;

    public GestionarOrdenCompraUseCase(
            OrdenCompraJpaRepository ocRepository,
            RequerimientoJpaRepository requerimientoRepository,
            RegistrarMovimientoInventarioUseCase movimientoUseCase) {
        this.ocRepository            = ocRepository;
        this.requerimientoRepository = requerimientoRepository;
        this.movimientoUseCase       = movimientoUseCase;
    }

    /** Genera una OC por cada requerimiento con cantidadAComprar > 0 */
    @Transactional
    public List<OrdenCompraEntity> generarDesdeProforma(Long proformaId, Long usuarioId) {
        List<RequerimientoEntity> requerimientos =
                requerimientoRepository.findByProformaIdOrderByMaterialId(proformaId);

        if (requerimientos.isEmpty()) {
            throw new DomainException(
                    "No hay requerimientos calculados para esta proforma. " +
                    "Ejecuta primero el cálculo APU.");
        }

        List<OrdenCompraEntity> ordenes = new ArrayList<>();

        for (RequerimientoEntity req : requerimientos) {
            if (req.getCantidadAComprar() == null ||
                req.getCantidadAComprar().signum() <= 0) continue;

            OrdenCompraEntity oc = new OrdenCompraEntity();
            oc.setRequerimientoId(req.getId());
            oc.setMaterialId(req.getMaterialId());
            oc.setCantidad(req.getCantidadAComprar());
            oc.setGeneradaPor(usuarioId);
            oc.setEstado("PENDIENTE");
            ordenes.add(ocRepository.save(oc));
        }

        if (ordenes.isEmpty()) {
            throw new DomainException(
                    "No hay materiales que comprar: el stock cubre todos los requerimientos.");
        }

        return ordenes;
    }

    /** Aprobar una OC pendiente */
    @Transactional
    public OrdenCompraEntity aprobar(Long ocId, Long usuarioId) {
        OrdenCompraEntity oc = obtenerPorId(ocId);
        if (!"PENDIENTE".equals(oc.getEstado())) {
            throw new DomainException("Solo se pueden aprobar órdenes en estado PENDIENTE.");
        }
        oc.setEstado("APROBADA");
        oc.setAprobadaPor(usuarioId);
        oc.setFechaAprobacion(LocalDateTime.now());
        return ocRepository.save(oc);
    }

    /** Rechazar una OC pendiente */
    @Transactional
    public OrdenCompraEntity rechazar(Long ocId, String observaciones) {
        OrdenCompraEntity oc = obtenerPorId(ocId);
        if (!"PENDIENTE".equals(oc.getEstado())) {
            throw new DomainException("Solo se pueden rechazar órdenes en estado PENDIENTE.");
        }
        oc.setEstado("RECHAZADA");
        oc.setObservaciones(observaciones);
        return ocRepository.save(oc);
    }

    /**
     * Registrar recepción de materiales.
     * Al recibir la OC se registra automáticamente un INGRESO en el inventario.
     */
    @Transactional
    public OrdenCompraEntity recibirMateriales(Long ocId, Long usuarioId) {
        OrdenCompraEntity oc = obtenerPorId(ocId);
        if (!"APROBADA".equals(oc.getEstado())) {
            throw new DomainException("Solo se pueden recibir órdenes en estado APROBADA.");
        }

        // Registrar ingreso automático al inventario
        var movimiento = new com.ucb.inventariocivil.infrastructure.persistence.entities
                .MovimientoInventarioEntity();
        movimiento.setMaterialId(oc.getMaterialId());
        movimiento.setCantidad(oc.getCantidad());
        movimiento.setPrecioUnitario(oc.getPrecioUnitario());
        movimiento.setTipo("INGRESO");
        movimiento.setResponsableId(usuarioId);
        movimiento.setMotivo("Recepción automática de Orden de Compra #" + ocId);
        movimientoUseCase.registrar(movimiento);

        oc.setEstado("RECIBIDA");
        oc.setFechaRecepcion(LocalDateTime.now());
        return ocRepository.save(oc);
    }

    @Transactional(readOnly = true)
    public OrdenCompraEntity obtenerPorId(Long id) {
        return ocRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Orden de Compra", id));
    }

    @Transactional(readOnly = true)
    public List<OrdenCompraEntity> listarRecientes(int cantidad) {
        return ocRepository.findAllByOrderByFechaGeneracionDesc(
                PageRequest.of(0, cantidad)).getContent();
    }

    @Transactional(readOnly = true)
    public List<OrdenCompraEntity> listarPorEstado(String estado) {
        return ocRepository.findByEstadoOrderByFechaGeneracionDesc(estado);
    }
}
