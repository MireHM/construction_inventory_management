package com.ucb.inventariocivil.presentation.controllers;

import com.ucb.inventariocivil.infrastructure.persistence.jpa.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * Controller REST de Reportes y KPIs.
 * Provee los datos para el Dashboard de la app Flutter.
 *
 * GET /api/v1/reportes/dashboard    → KPIs generales del sistema
 * GET /api/v1/reportes/stock        → resumen de stock por estado
 * GET /api/v1/reportes/movimientos  → resumen de movimientos recientes
 */
@Tag(name = "Reportes y KPIs")
@SecurityRequirement(name = "bearerAuth")
@RestController
@RequestMapping("/api/v1/reportes")
public class ReporteController {

    private final MaterialJpaRepository   materialRepository;
    private final MovimientoJpaRepository movimientoRepository;
    private final OrdenCompraJpaRepository ocRepository;
    private final AlertaStockJpaRepository alertaRepository;

    public ReporteController(MaterialJpaRepository materialRepository,
                             MovimientoJpaRepository movimientoRepository,
                             OrdenCompraJpaRepository ocRepository,
                             AlertaStockJpaRepository alertaRepository) {
        this.materialRepository  = materialRepository;
        this.movimientoRepository = movimientoRepository;
        this.ocRepository        = ocRepository;
        this.alertaRepository    = alertaRepository;
    }

    @Operation(summary = "KPIs del Dashboard principal")
    @GetMapping("/dashboard")
    public ResponseEntity<AuthDtos.ApiResponse<Map<String, Object>>> dashboard() {

        long totalMateriales      = materialRepository.countByActivoTrue();
        long materialesBajoMin    = materialRepository.findMaterialesBajoStockMinimo().size();
        long materialesSinStock   = materialRepository.findByActivoTrue().stream()
                .filter(m -> m.getStockActual().compareTo(BigDecimal.ZERO) == 0).count();
        long ocPendientes         = ocRepository.countPendientes();
        BigDecimal costoAprobado  = ocRepository.totalCostoAprobado();
        long alertasPendientes    = alertaRepository.findByAtendidaFalseOrderByCreatedAtDesc().size();

        var ultMovimientos = movimientoRepository
                .findUltimos(PageRequest.of(0, 5))
                .stream()
                .map(m -> {
                    Map<String, Object> item = new java.util.HashMap<>();
                    item.put("id",         m.getId());
                    item.put("tipo",       m.getTipo());
                    item.put("materialId", m.getMaterialId());
                    item.put("cantidad",   m.getCantidad());
                    item.put("fecha",      m.getFechaMovimiento().toString());
                    return item;
                }).toList();

        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", Map.of(
                "totalMateriales",    totalMateriales,
                "materialesBajoMin",  materialesBajoMin,
                "materialesSinStock", materialesSinStock,
                "ocPendientes",       ocPendientes,
                "costoOCAprobado",    costoAprobado,
                "alertasPendientes",  alertasPendientes,
                "ultimosMovimientos", ultMovimientos
        )));
    }

    @Operation(summary = "Resumen de stock por estado (NORMAL / BAJO / CRITICO)")
    @GetMapping("/stock")
    public ResponseEntity<AuthDtos.ApiResponse<Map<String, Object>>> stockResumen() {
        var materiales = materialRepository.findByActivoTrue();

        long normal  = materiales.stream()
                .filter(m -> m.getStockActual().compareTo(BigDecimal.ZERO) > 0
                          && m.getStockActual().compareTo(m.getStockMinimo()) >= 0).count();
        long bajo    = materiales.stream()
                .filter(m -> m.getStockActual().compareTo(BigDecimal.ZERO) > 0
                          && m.getStockActual().compareTo(m.getStockMinimo()) < 0).count();
        long critico = materiales.stream()
                .filter(m -> m.getStockActual().compareTo(BigDecimal.ZERO) == 0).count();

        var detalle = materiales.stream().map(m -> {
            String estado;
            if (m.getStockActual().compareTo(BigDecimal.ZERO) == 0) estado = "CRITICO";
            else if (m.getStockActual().compareTo(m.getStockMinimo()) < 0) estado = "BAJO";
            else estado = "NORMAL";

            Map<String, Object> item = new java.util.HashMap<>();
            item.put("id",          m.getId());
            item.put("codigo",      m.getCodigo());
            item.put("nombre",      m.getNombre());
            item.put("stockActual", m.getStockActual());
            item.put("stockMinimo", m.getStockMinimo());
            item.put("estado",      estado);
            return item;
        }).toList();

        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", Map.of(
                "normal",  normal,
                "bajo",    bajo,
                "critico", critico,
                "total",   materiales.size(),
                "detalle", detalle
        )));
    }

    @Operation(summary = "Resumen de movimientos recientes (últimos 50)")
    @GetMapping("/movimientos")
    public ResponseEntity<AuthDtos.ApiResponse<List<Map<String, Object>>>> movimientos() {
        var lista = movimientoRepository
                .findUltimos(PageRequest.of(0, 50))
                .stream()
                .map(m -> {
                    Map<String, Object> item = new java.util.HashMap<>();
                    item.put("id",              m.getId());
                    item.put("tipo",            m.getTipo());
                    item.put("materialId",      m.getMaterialId());
                    item.put("cantidad",        m.getCantidad());
                    item.put("stockAnterior",   m.getStockAnterior());
                    item.put("stockResultante", m.getStockResultante());
                    item.put("fecha",           m.getFechaMovimiento().toString());
                    return item;
                }).toList();
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", lista));
    }
}
