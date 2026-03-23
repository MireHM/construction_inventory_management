package com.ucb.inventariocivil.presentation.controllers;

import com.ucb.inventariocivil.application.usecases.GestionarOrdenCompraUseCase;
import com.ucb.inventariocivil.infrastructure.persistence.entities.OrdenCompraEntity;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Controller REST de Órdenes de Compra.
 *
 * POST /api/v1/ordenes/generar?proformaId=   → generar OCs desde proforma
 * GET  /api/v1/ordenes                       → listar recientes (20)
 * GET  /api/v1/ordenes/pendientes            → solo pendientes
 * GET  /api/v1/ordenes/{id}                  → detalle
 * POST /api/v1/ordenes/{id}/aprobar          → aprobar (GERENTE)
 * POST /api/v1/ordenes/{id}/rechazar         → rechazar (GERENTE)
 * POST /api/v1/ordenes/{id}/recibir          → recibir + ingreso automático (ALMACENERO)
 */
@Tag(name = "Órdenes de Compra")
@SecurityRequirement(name = "bearerAuth")
@RestController
@RequestMapping("/api/v1/ordenes")
public class OrdenCompraController {

    private final GestionarOrdenCompraUseCase useCase;

    public OrdenCompraController(GestionarOrdenCompraUseCase useCase) {
        this.useCase = useCase;
    }

    // ── DTO ─────────────────────────────────────────────────────────────────

    public record OrdenCompraResponse(
        Long id, Long requerimientoId, Long materialId,
        String nombreProveedor, BigDecimal cantidad,
        BigDecimal precioUnitario, BigDecimal costoEstimado,
        String estado, LocalDateTime fechaGeneracion,
        LocalDateTime fechaAprobacion, LocalDateTime fechaRecepcion,
        String observaciones
    ) {
        static OrdenCompraResponse from(OrdenCompraEntity e) {
            return new OrdenCompraResponse(
                e.getId(), e.getRequerimientoId(), e.getMaterialId(),
                e.getNombreProveedor(), e.getCantidad(),
                e.getPrecioUnitario(), e.getCostoEstimado(),
                e.getEstado(), e.getFechaGeneracion(),
                e.getFechaAprobacion(), e.getFechaRecepcion(),
                e.getObservaciones()
            );
        }
    }

    public record RechazarRequest(String observaciones) {}

    // ── Endpoints ───────────────────────────────────────────────────────────

    @Operation(summary = "Generar órdenes de compra desde requerimientos de una proforma")
    @PostMapping("/generar")
    public ResponseEntity<AuthDtos.ApiResponse<List<OrdenCompraResponse>>> generar(
            @RequestParam Long proformaId) {
        List<OrdenCompraResponse> lista = useCase.generarDesdeProforma(proformaId, 1L)
                .stream().map(OrdenCompraResponse::from).toList();
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(AuthDtos.ApiResponse.ok(
                        lista.size() + " orden(es) de compra generada(s).", lista));
    }

    @Operation(summary = "Listar las 20 órdenes más recientes")
    @GetMapping
    public ResponseEntity<AuthDtos.ApiResponse<List<OrdenCompraResponse>>> listar() {
        List<OrdenCompraResponse> lista = useCase.listarRecientes(20)
                .stream().map(OrdenCompraResponse::from).toList();
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", lista));
    }

    @Operation(summary = "Listar órdenes pendientes de aprobación")
    @GetMapping("/pendientes")
    public ResponseEntity<AuthDtos.ApiResponse<List<OrdenCompraResponse>>> pendientes() {
        List<OrdenCompraResponse> lista = useCase.listarPorEstado("PENDIENTE")
                .stream().map(OrdenCompraResponse::from).toList();
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", lista));
    }

    @Operation(summary = "Obtener detalle de una orden")
    @GetMapping("/{id}")
    public ResponseEntity<AuthDtos.ApiResponse<OrdenCompraResponse>> obtener(
            @PathVariable Long id) {
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK",
                OrdenCompraResponse.from(useCase.obtenerPorId(id))));
    }

    @Operation(summary = "Aprobar orden de compra (solo GERENTE)")
    @PostMapping("/{id}/aprobar")
    @PreAuthorize("hasRole('GERENTE') or hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<OrdenCompraResponse>> aprobar(
            @PathVariable Long id) {
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok(
                "Orden aprobada.",
                OrdenCompraResponse.from(useCase.aprobar(id, 1L))));
    }

    @Operation(summary = "Rechazar orden de compra (solo GERENTE)")
    @PostMapping("/{id}/rechazar")
    @PreAuthorize("hasRole('GERENTE') or hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<OrdenCompraResponse>> rechazar(
            @PathVariable Long id,
            @RequestBody(required = false) RechazarRequest req) {
        String obs = req != null ? req.observaciones() : null;
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok(
                "Orden rechazada.",
                OrdenCompraResponse.from(useCase.rechazar(id, obs))));
    }

    @Operation(summary = "Registrar recepción de materiales – genera ingreso automático al inventario")
    @PostMapping("/{id}/recibir")
    @PreAuthorize("hasRole('ALMACENERO') or hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<OrdenCompraResponse>> recibir(
            @PathVariable Long id) {
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok(
                "Materiales recibidos. Stock actualizado.",
                OrdenCompraResponse.from(useCase.recibirMateriales(id, 1L))));
    }
}
