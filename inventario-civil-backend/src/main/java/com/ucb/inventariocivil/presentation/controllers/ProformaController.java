package com.ucb.inventariocivil.presentation.controllers;

import com.ucb.inventariocivil.application.usecases.CalcularRequerimientosUseCase;
import com.ucb.inventariocivil.application.usecases.GestionarProformaUseCase;
import com.ucb.inventariocivil.infrastructure.persistence.entities.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Controller REST de Proformas y Motor de Cálculo.
 *
 * GET  /api/v1/proformas?proyectoId=       → listar por proyecto
 * GET  /api/v1/proformas/{id}              → obtener con partidas
 * POST /api/v1/proformas                   → crear proforma con partidas
 * POST /api/v1/proformas/{id}/calcular     → ejecutar motor APU ← PRUEBA TÉCNICA 2
 * GET  /api/v1/proformas/{id}/requerimientos → ver resultados calculados
 */
@Tag(name = "Proformas y Cálculo de Requerimientos")
@SecurityRequirement(name = "bearerAuth")
@RestController
@RequestMapping("/api/v1/proformas")
public class ProformaController {

    private final GestionarProformaUseCase   proformaUseCase;
    private final CalcularRequerimientosUseCase calculoUseCase;

    public ProformaController(GestionarProformaUseCase proformaUseCase,
                               CalcularRequerimientosUseCase calculoUseCase) {
        this.proformaUseCase = proformaUseCase;
        this.calculoUseCase  = calculoUseCase;
    }

    // ── DTOs ─────────────────────────────────────────────────────────────────

    public record PartidaRequest(
        @NotNull Long apuId,
        String itemNumero,
        String descripcion,
        @NotNull @Positive BigDecimal cantidadObra,
        BigDecimal precioUnitario,
        int orden
    ) {}

    public record ProformaRequest(
        @NotNull Long proyectoId,
        @NotBlank String codigo,
        @NotBlank String nombre,
        String descripcion,
        List<PartidaRequest> partidas
    ) {}

    public record PartidaResponse(
        Long id, Long apuId, String itemNumero,
        String descripcion, BigDecimal cantidadObra,
        BigDecimal precioUnitario, int orden
    ) {
        static PartidaResponse from(PartidaProformaEntity e) {
            return new PartidaResponse(e.getId(), e.getApuId(),
                e.getItemNumero(), e.getDescripcion(), e.getCantidadObra(),
                e.getPrecioUnitario(), e.getOrden());
        }
    }

    public record ProformaResponse(
        Long id, Long proyectoId, String codigo, String nombre,
        String descripcion, LocalDate fechaElaboracion,
        String estado, List<PartidaResponse> partidas,
        LocalDateTime createdAt
    ) {
        static ProformaResponse from(ProformaEntity e) {
            List<PartidaResponse> ps = e.getPartidas() == null ? List.of()
                    : e.getPartidas().stream().map(PartidaResponse::from).toList();
            return new ProformaResponse(e.getId(), e.getProyectoId(),
                e.getCodigo(), e.getNombre(), e.getDescripcion(),
                e.getFechaElaboracion(), e.getEstado(), ps, e.getCreatedAt());
        }
    }

    public record RequerimientoResponse(
        Long id, Long materialId, Long partidaId,
        BigDecimal cantidadCalculada, BigDecimal cantidadDisponible,
        BigDecimal cantidadAComprar, LocalDateTime fechaCalculo
    ) {
        static RequerimientoResponse from(RequerimientoEntity e) {
            return new RequerimientoResponse(e.getId(), e.getMaterialId(),
                e.getPartidaId(), e.getCantidadCalculada(),
                e.getCantidadDisponible(), e.getCantidadAComprar(),
                e.getFechaCalculo());
        }
    }

    // ── Endpoints ─────────────────────────────────────────────────────────────

    @Operation(summary = "Listar proformas de un proyecto")
    @GetMapping
    public ResponseEntity<AuthDtos.ApiResponse<List<ProformaResponse>>> listar(
            @RequestParam Long proyectoId) {
        List<ProformaResponse> lista = proformaUseCase.listarPorProyecto(proyectoId)
                .stream().map(ProformaResponse::from).toList();
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", lista));
    }

    @Operation(summary = "Obtener proforma con sus partidas")
    @GetMapping("/{id}")
    public ResponseEntity<AuthDtos.ApiResponse<ProformaResponse>> obtener(
            @PathVariable Long id) {
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK",
                ProformaResponse.from(proformaUseCase.obtenerPorId(id))));
    }

    @Operation(summary = "Crear proforma con partidas de obra")
    @PostMapping
    public ResponseEntity<AuthDtos.ApiResponse<ProformaResponse>> crear(
            @Valid @RequestBody ProformaRequest req) {

        ProformaEntity proforma = new ProformaEntity();
        proforma.setProyectoId(req.proyectoId());
        proforma.setCodigo(req.codigo());
        proforma.setNombre(req.nombre());
        proforma.setDescripcion(req.descripcion());
        proforma.setElaboradoPor(1L); // TODO: extraer del JWT

        if (req.partidas() != null) {
            List<PartidaProformaEntity> partidas = req.partidas().stream()
                    .map(p -> {
                        PartidaProformaEntity partida = new PartidaProformaEntity();
                        partida.setApuId(p.apuId());
                        partida.setItemNumero(p.itemNumero());
                        partida.setDescripcion(p.descripcion());
                        partida.setCantidadObra(p.cantidadObra());
                        partida.setPrecioUnitario(p.precioUnitario());
                        partida.setOrden(p.orden());
                        return partida;
                    }).toList();
            proforma.setPartidas(partidas);
        }

        ProformaEntity creada = proformaUseCase.crear(proforma);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(AuthDtos.ApiResponse.ok("Proforma creada.", ProformaResponse.from(creada)));
    }

    @Operation(summary = "Ejecutar motor de cálculo APU sobre la proforma",
               description = "Calcula automáticamente los requerimientos de materiales " +
                             "multiplicando la cantidad de obra × rendimientos del APU. " +
                             "Este es el endpoint central del sistema (Prueba Técnica 2).")
    @PostMapping("/{id}/calcular")
    public ResponseEntity<AuthDtos.ApiResponse<List<RequerimientoResponse>>> calcular(
            @PathVariable Long id) {

        List<RequerimientoResponse> resultado = calculoUseCase.calcular(id, 1L)
                .stream().map(RequerimientoResponse::from).toList();

        return ResponseEntity.ok(AuthDtos.ApiResponse.ok(
                "Requerimientos calculados. Total materiales: " + resultado.size(),
                resultado));
    }

    @Operation(summary = "Obtener requerimientos ya calculados de una proforma")
    @GetMapping("/{id}/requerimientos")
    public ResponseEntity<AuthDtos.ApiResponse<List<RequerimientoResponse>>> requerimientos(
            @PathVariable Long id) {
        List<RequerimientoResponse> lista = calculoUseCase.obtenerPorProforma(id)
                .stream().map(RequerimientoResponse::from).toList();
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", lista));
    }
}
