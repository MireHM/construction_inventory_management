package com.ucb.inventariocivil.presentation.controllers;

import com.ucb.inventariocivil.application.usecases.GestionarProyectoUseCase;
import com.ucb.inventariocivil.infrastructure.persistence.entities.ProyectoEntity;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Tag(name = "Proyectos")
@SecurityRequirement(name = "bearerAuth")
@RestController
@RequestMapping("/api/v1/proyectos")
public class ProyectoController {

    private final GestionarProyectoUseCase useCase;

    public ProyectoController(GestionarProyectoUseCase useCase) {
        this.useCase = useCase;
    }

    // ── DTOs ────────────────────────────────────────────────────────────────

    public record CrearProyectoRequest(
        @NotBlank String codigo,
        @NotBlank String nombre,
        String descripcion,
        LocalDate fechaInicio,
        LocalDate fechaFinEstimada,
        Long responsableId,
        BigDecimal presupuesto
    ) {}

    public record ActualizarProyectoRequest(
        String nombre,
        String descripcion,
        String estado,
        LocalDate fechaFinEstimada,
        BigDecimal presupuesto
    ) {}

    // ── Endpoints ────────────────────────────────────────────────────────────

    @Operation(summary = "Listar proyectos activos")
    @GetMapping
    public ResponseEntity<AuthDtos.ApiResponse<List<ProyectoEntity>>> listar(
            @RequestParam(required = false) String estado) {
        List<ProyectoEntity> proyectos = (estado != null && !estado.isBlank())
                ? useCase.listarPorEstado(estado)
                : useCase.listarActivos();
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Proyectos obtenidos", proyectos));
    }

    @Operation(summary = "Obtener proyecto por ID")
    @GetMapping("/{id}")
    public ResponseEntity<AuthDtos.ApiResponse<ProyectoEntity>> obtener(@PathVariable Long id) {
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Proyecto encontrado", useCase.obtenerPorId(id)));
    }

    @Operation(summary = "Crear nuevo proyecto")
    @PostMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','GERENTE')")
    public ResponseEntity<AuthDtos.ApiResponse<ProyectoEntity>> crear(@Valid @RequestBody CrearProyectoRequest req) {
        ProyectoEntity proyecto = useCase.crear(req.codigo(), req.nombre(), req.descripcion(),
                req.fechaInicio(), req.fechaFinEstimada(), req.responsableId(), req.presupuesto());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(AuthDtos.ApiResponse.ok("Proyecto creado exitosamente", proyecto));
    }

    @Operation(summary = "Actualizar proyecto")
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','GERENTE')")
    public ResponseEntity<AuthDtos.ApiResponse<ProyectoEntity>> actualizar(
            @PathVariable Long id,
            @Valid @RequestBody ActualizarProyectoRequest req) {
        ProyectoEntity proyecto = useCase.actualizar(id, req.nombre(), req.descripcion(),
                req.estado(), req.fechaFinEstimada(), req.presupuesto());
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Proyecto actualizado", proyecto));
    }

    @Operation(summary = "Desactivar proyecto")
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<Void>> desactivar(@PathVariable Long id) {
        useCase.desactivar(id);
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Proyecto desactivado", null));
    }
}
