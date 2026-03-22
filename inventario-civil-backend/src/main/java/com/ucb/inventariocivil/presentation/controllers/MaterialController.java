package com.ucb.inventariocivil.presentation.controllers;

import com.ucb.inventariocivil.application.usecases.GestionarMaterialUseCase;
import com.ucb.inventariocivil.infrastructure.persistence.entities.MaterialEntity;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

/**
 * Controller REST de Materiales.
 * GET  /api/v1/materiales         → listar activos
 * GET  /api/v1/materiales/{id}    → obtener por id
 * GET  /api/v1/materiales/alertas → materiales bajo stock mínimo
 * POST /api/v1/materiales         → crear (ADMIN)
 * PUT  /api/v1/materiales/{id}    → actualizar (ADMIN)
 * DELETE /api/v1/materiales/{id}  → desactivar (ADMIN)
 */
@Tag(name = "Materiales")
@SecurityRequirement(name = "bearerAuth")
@RestController
@RequestMapping("/api/v1/materiales")
public class MaterialController {

    private final GestionarMaterialUseCase useCase;

    public MaterialController(GestionarMaterialUseCase useCase) {
        this.useCase = useCase;
    }

    // ── DTOs internos ────────────────────────────────────────────────────────

    public record MaterialRequest(
        @NotBlank String codigo,
        @NotBlank String nombre,
        String descripcion,
        @NotNull Long categoriaId,
        @NotNull Long unidadMedidaId,
        @NotNull @PositiveOrZero BigDecimal precioReferencia,
        @NotNull @PositiveOrZero BigDecimal stockMinimo,
        BigDecimal stockMaximo
    ) {}

    public record MaterialResponse(
        Long id,
        String codigo,
        String nombre,
        String descripcion,
        Long categoriaId,
        Long unidadMedidaId,
        BigDecimal precioReferencia,
        BigDecimal stockActual,
        BigDecimal stockMinimo,
        BigDecimal stockMaximo,
        boolean activo,
        String estadoStock
    ) {
        public static MaterialResponse from(MaterialEntity e) {
            String estado;
            if (e.getStockActual().compareTo(BigDecimal.ZERO) == 0) {
                estado = "CRITICO";
            } else if (e.getStockActual().compareTo(e.getStockMinimo()) < 0) {
                estado = "BAJO";
            } else {
                estado = "NORMAL";
            }
            return new MaterialResponse(
                e.getId(), e.getCodigo(), e.getNombre(), e.getDescripcion(),
                e.getCategoriaId(), e.getUnidadMedidaId(), e.getPrecioReferencia(),
                e.getStockActual(), e.getStockMinimo(), e.getStockMaximo(),
                e.isActivo(), estado
            );
        }
    }

    // ── Endpoints ────────────────────────────────────────────────────────────

    @Operation(summary = "Listar todos los materiales activos")
    @GetMapping
    public ResponseEntity<AuthDtos.ApiResponse<List<MaterialResponse>>> listar() {
        List<MaterialResponse> lista = useCase.listarActivos()
                .stream().map(MaterialResponse::from).toList();
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", lista));
    }

    @Operation(summary = "Obtener material por ID")
    @GetMapping("/{id}")
    public ResponseEntity<AuthDtos.ApiResponse<MaterialResponse>> obtener(
            @PathVariable Long id) {
        return ResponseEntity.ok(
                AuthDtos.ApiResponse.ok("OK", MaterialResponse.from(useCase.obtenerPorId(id))));
    }

    @Operation(summary = "Materiales con stock bajo el mínimo (alertas)")
    @GetMapping("/alertas")
    public ResponseEntity<AuthDtos.ApiResponse<List<MaterialResponse>>> alertas() {
        List<MaterialResponse> lista = useCase.listarBajoStockMinimo()
                .stream().map(MaterialResponse::from).toList();
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", lista));
    }

    @Operation(summary = "Crear material (solo ADMINISTRADOR)")
    @PostMapping
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<MaterialResponse>> crear(
            @Valid @RequestBody MaterialRequest req) {
        MaterialEntity entity = toEntity(req);
        MaterialEntity creado = useCase.crear(entity);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(AuthDtos.ApiResponse.ok("Material creado.", MaterialResponse.from(creado)));
    }

    @Operation(summary = "Actualizar material (solo ADMINISTRADOR)")
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<MaterialResponse>> actualizar(
            @PathVariable Long id, @Valid @RequestBody MaterialRequest req) {
        MaterialEntity actualizado = useCase.actualizar(id, toEntity(req));
        return ResponseEntity.ok(
                AuthDtos.ApiResponse.ok("Material actualizado.", MaterialResponse.from(actualizado)));
    }

    @Operation(summary = "Desactivar material (solo ADMINISTRADOR)")
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<Void>> desactivar(@PathVariable Long id) {
        useCase.desactivar(id);
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Material desactivado.", null));
    }

    private MaterialEntity toEntity(MaterialRequest req) {
        MaterialEntity e = new MaterialEntity();
        e.setCodigo(req.codigo());
        e.setNombre(req.nombre());
        e.setDescripcion(req.descripcion());
        e.setCategoriaId(req.categoriaId());
        e.setUnidadMedidaId(req.unidadMedidaId());
        e.setPrecioReferencia(req.precioReferencia());
        e.setStockMinimo(req.stockMinimo());
        e.setStockMaximo(req.stockMaximo());
        return e;
    }
}
