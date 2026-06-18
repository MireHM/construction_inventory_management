package com.ucb.inventariocivil.presentation.controllers;

import com.ucb.inventariocivil.domain.exceptions.RecursoNoEncontradoException;
import com.ucb.inventariocivil.infrastructure.persistence.entities.UnidadMedidaEntity;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.UnidadMedidaJpaRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Unidades de Medida")
@SecurityRequirement(name = "bearerAuth")
@RestController
@RequestMapping("/api/v1/unidades-medida")
public class UnidadMedidaController {

    private final UnidadMedidaJpaRepository repository;

    public UnidadMedidaController(UnidadMedidaJpaRepository repository) {
        this.repository = repository;
    }

    public record UnidadMedidaRequest(@NotBlank String simbolo, @NotBlank String nombre) {}

    @Operation(summary = "Listar unidades de medida activas")
    @GetMapping
    public ResponseEntity<AuthDtos.ApiResponse<List<UnidadMedidaEntity>>> listar() {
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", repository.findByActivoTrue()));
    }

    @Operation(summary = "Obtener unidad de medida por ID")
    @GetMapping("/{id}")
    public ResponseEntity<AuthDtos.ApiResponse<UnidadMedidaEntity>> obtener(@PathVariable Long id) {
        UnidadMedidaEntity um = repository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Unidad no encontrada: " + id));
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", um));
    }

    @Operation(summary = "Crear unidad de medida")
    @PostMapping
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<UnidadMedidaEntity>> crear(@Valid @RequestBody UnidadMedidaRequest req) {
        if (repository.existsBySimbolo(req.simbolo())) {
            throw new IllegalArgumentException("Ya existe una unidad con símbolo: " + req.simbolo());
        }
        UnidadMedidaEntity um = new UnidadMedidaEntity();
        um.setSimbolo(req.simbolo());
        um.setNombre(req.nombre());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(AuthDtos.ApiResponse.ok("Unidad creada", repository.save(um)));
    }

    @Operation(summary = "Actualizar unidad de medida")
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<UnidadMedidaEntity>> actualizar(
            @PathVariable Long id, @Valid @RequestBody UnidadMedidaRequest req) {
        UnidadMedidaEntity um = repository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Unidad no encontrada: " + id));
        um.setSimbolo(req.simbolo());
        um.setNombre(req.nombre());
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Unidad actualizada", repository.save(um)));
    }

    @Operation(summary = "Desactivar unidad de medida")
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<Void>> desactivar(@PathVariable Long id) {
        UnidadMedidaEntity um = repository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Unidad no encontrada: " + id));
        um.setActivo(false);
        repository.save(um);
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Unidad desactivada", null));
    }
}
