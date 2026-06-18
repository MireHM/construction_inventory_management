package com.ucb.inventariocivil.presentation.controllers;

import com.ucb.inventariocivil.domain.exceptions.RecursoNoEncontradoException;
import com.ucb.inventariocivil.infrastructure.persistence.entities.CategoriaEntity;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.CategoriaJpaRepository;
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

@Tag(name = "Categorías")
@SecurityRequirement(name = "bearerAuth")
@RestController
@RequestMapping("/api/v1/categorias")
public class CategoriaController {

    private final CategoriaJpaRepository repository;

    public CategoriaController(CategoriaJpaRepository repository) {
        this.repository = repository;
    }

    public record CategoriaRequest(@NotBlank String nombre, String descripcion) {}

    @Operation(summary = "Listar categorías activas")
    @GetMapping
    public ResponseEntity<AuthDtos.ApiResponse<List<CategoriaEntity>>> listar() {
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", repository.findByActivoTrue()));
    }

    @Operation(summary = "Obtener categoría por ID")
    @GetMapping("/{id}")
    public ResponseEntity<AuthDtos.ApiResponse<CategoriaEntity>> obtener(@PathVariable Long id) {
        CategoriaEntity cat = repository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Categoría no encontrada: " + id));
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("OK", cat));
    }

    @Operation(summary = "Crear categoría")
    @PostMapping
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<CategoriaEntity>> crear(@Valid @RequestBody CategoriaRequest req) {
        if (repository.existsByNombre(req.nombre())) {
            throw new IllegalArgumentException("Ya existe una categoría con nombre: " + req.nombre());
        }
        CategoriaEntity cat = new CategoriaEntity();
        cat.setNombre(req.nombre());
        cat.setDescripcion(req.descripcion());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(AuthDtos.ApiResponse.ok("Categoría creada", repository.save(cat)));
    }

    @Operation(summary = "Actualizar categoría")
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<CategoriaEntity>> actualizar(
            @PathVariable Long id, @Valid @RequestBody CategoriaRequest req) {
        CategoriaEntity cat = repository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Categoría no encontrada: " + id));
        cat.setNombre(req.nombre());
        cat.setDescripcion(req.descripcion());
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Categoría actualizada", repository.save(cat)));
    }

    @Operation(summary = "Desactivar categoría")
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<Void>> desactivar(@PathVariable Long id) {
        CategoriaEntity cat = repository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Categoría no encontrada: " + id));
        cat.setActivo(false);
        repository.save(cat);
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Categoría desactivada", null));
    }
}
