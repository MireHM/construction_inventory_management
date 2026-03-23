package com.ucb.inventariocivil.presentation.controllers;

import com.ucb.inventariocivil.application.usecases.RegistrarMovimientoInventarioUseCase;
import com.ucb.inventariocivil.infrastructure.persistence.entities.AlertaStockEntity;
import com.ucb.inventariocivil.infrastructure.persistence.entities.MovimientoInventarioEntity;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Controller REST de Inventario.
 *
 * POST /api/v1/inventario/ingresos           → registrar ingreso de material
 * POST /api/v1/inventario/salidas            → registrar salida de material
 * GET  /api/v1/inventario/materiales/{id}/historial → historial de un material
 * GET  /api/v1/inventario/movimientos/recientes     → últimos 20 movimientos
 * GET  /api/v1/inventario/alertas                   → alertas de stock pendientes
 */
@Tag(name = "Inventario")
@SecurityRequirement(name = "bearerAuth")
@RestController
@RequestMapping("/api/v1/inventario")
public class InventarioController {

    private final RegistrarMovimientoInventarioUseCase useCase;

    public InventarioController(RegistrarMovimientoInventarioUseCase useCase) {
        this.useCase = useCase;
    }

    // ── DTOs ─────────────────────────────────────────────────────────────────

    public record IngresoRequest(
        @NotNull Long materialId,
        @NotNull @Positive BigDecimal cantidad,
        BigDecimal precioUnitario,
        Long proveedorId,
        String numeroFactura,
        Long proyectoId,
        String motivo
    ) {}

    public record SalidaRequest(
        @NotNull Long materialId,
        @NotNull @Positive BigDecimal cantidad,
        @NotNull Long proyectoId,
        @NotBlank String frenteObra,
        String motivo
    ) {}

    public record MovimientoResponse(
        Long id,
        Long materialId,
        Long proyectoId,
        String tipo,
        BigDecimal cantidad,
        BigDecimal precioUnitario,
        String numeroFactura,
        String frenteObra,
        String motivo,
        BigDecimal stockAnterior,
        BigDecimal stockResultante,
        LocalDateTime fechaMovimiento
    ) {
        public static MovimientoResponse from(MovimientoInventarioEntity e) {
            return new MovimientoResponse(
                e.getId(), e.getMaterialId(), e.getProyectoId(),
                e.getTipo(), e.getCantidad(), e.getPrecioUnitario(),
                e.getNumeroFactura(), e.getFrenteObra(), e.getMotivo(),
                e.getStockAnterior(), e.getStockResultante(), e.getFechaMovimiento()
            );
        }
    }

    public record AlertaResponse(
        Long id,
        Long materialId,
        String tipo,
        BigDecimal stockAlMomento,
        boolean atendida,
        LocalDateTime createdAt
    ) {
        public static AlertaResponse from(AlertaStockEntity e) {
            return new AlertaResponse(
                e.getId(), e.getMaterialId(), e.getTipo(),
                e.getStockAlMomento(), e.isAtendida(), e.getCreatedAt()
            );
        }
    }

    // ── Endpoints ─────────────────────────────────────────────────────────────

    @Operation(summary = "Registrar ingreso de material al almacén")
    @PostMapping("/ingresos")
    public ResponseEntity<AuthDtos.ApiResponse<MovimientoResponse>> registrarIngreso(
            @Valid @RequestBody IngresoRequest req,
            @AuthenticationPrincipal UserDetails user) {

        MovimientoInventarioEntity m = buildMovimiento(req.materialId(),
                "INGRESO", req.cantidad(), req.proyectoId());
        m.setPrecioUnitario(req.precioUnitario());
        m.setProveedorId(req.proveedorId());
        m.setNumeroFactura(req.numeroFactura());
        m.setMotivo(req.motivo());

        MovimientoInventarioEntity guardado = useCase.registrar(m);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(AuthDtos.ApiResponse.ok(
                        "Ingreso registrado. Stock actualizado.",
                        MovimientoResponse.from(guardado)));
    }

    @Operation(summary = "Registrar salida de material del almacén")
    @PostMapping("/salidas")
    public ResponseEntity<AuthDtos.ApiResponse<MovimientoResponse>> registrarSalida(
            @Valid @RequestBody SalidaRequest req,
            @AuthenticationPrincipal UserDetails user) {

        MovimientoInventarioEntity m = buildMovimiento(req.materialId(),
                "SALIDA", req.cantidad(), req.proyectoId());
        m.setFrenteObra(req.frenteObra());
        m.setMotivo(req.motivo());

        MovimientoInventarioEntity guardado = useCase.registrar(m);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(AuthDtos.ApiResponse.ok(
                        "Salida registrada. Stock actualizado.",
                        MovimientoResponse.from(guardado)));
    }

    @Operation(summary = "Historial de movimientos de un material")
    @GetMapping("/materiales/{materialId}/historial")
    public ResponseEntity<AuthDtos.ApiResponse<List<MovimientoResponse>>> historial(
            @PathVariable Long materialId) {
        List<MovimientoResponse> lista = useCase.historialPorMaterial(materialId)
                .stream().map(MovimientoResponse::from).toList();
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", lista));
    }

    @Operation(summary = "Últimos 20 movimientos del sistema")
    @GetMapping("/movimientos/recientes")
    public ResponseEntity<AuthDtos.ApiResponse<List<MovimientoResponse>>> recientes() {
        List<MovimientoResponse> lista = useCase.ultimos(20)
                .stream().map(MovimientoResponse::from).toList();
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", lista));
    }

    @Operation(summary = "Alertas de stock pendientes")
    @GetMapping("/alertas")
    public ResponseEntity<AuthDtos.ApiResponse<List<AlertaResponse>>> alertas() {
        List<AlertaResponse> lista = useCase.alertasPendientes()
                .stream().map(AlertaResponse::from).toList();
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", lista));
    }

    // ── Helper ────────────────────────────────────────────────────────────────

    private MovimientoInventarioEntity buildMovimiento(
            Long materialId, String tipo, BigDecimal cantidad, Long proyectoId) {
        MovimientoInventarioEntity m = new MovimientoInventarioEntity();
        m.setMaterialId(materialId);
        m.setTipo(tipo);
        m.setCantidad(cantidad);
        m.setProyectoId(proyectoId);
        m.setResponsableId(1L); // TODO: extraer del JWT en próximo commit
        return m;
    }
}
