package com.ucb.inventariocivil.presentation.controllers;

import com.ucb.inventariocivil.application.usecases.GestionarProveedorUseCase;
import com.ucb.inventariocivil.infrastructure.persistence.entities.ProveedorEntity;
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

@Tag(name = "Proveedores")
@SecurityRequirement(name = "bearerAuth")
@RestController
@RequestMapping("/api/v1/proveedores")
public class ProveedorController {

    private final GestionarProveedorUseCase useCase;

    public ProveedorController(GestionarProveedorUseCase useCase) {
        this.useCase = useCase;
    }

    // ── DTOs ────────────────────────────────────────────────────────────────

    public record CrearProveedorRequest(
        @NotBlank String nombre,
        String nit,
        String telefono,
        String email,
        String direccion,
        String contacto
    ) {}

    public record ActualizarProveedorRequest(
        String nombre,
        String telefono,
        String email,
        String direccion,
        String contacto
    ) {}

    // ── Endpoints ────────────────────────────────────────────────────────────

    @Operation(summary = "Listar proveedores activos")
    @GetMapping
    public ResponseEntity<AuthDtos.ApiResponse<List<ProveedorEntity>>> listar() {
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Proveedores obtenidos", useCase.listarActivos()));
    }

    @Operation(summary = "Obtener proveedor por ID")
    @GetMapping("/{id}")
    public ResponseEntity<AuthDtos.ApiResponse<ProveedorEntity>> obtener(@PathVariable Long id) {
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Proveedor encontrado", useCase.obtenerPorId(id)));
    }

    @Operation(summary = "Crear nuevo proveedor")
    @PostMapping
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','ALMACENERO')")
    public ResponseEntity<AuthDtos.ApiResponse<ProveedorEntity>> crear(@Valid @RequestBody CrearProveedorRequest req) {
        ProveedorEntity proveedor = useCase.crear(req.nombre(), req.nit(), req.telefono(),
                req.email(), req.direccion(), req.contacto());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(AuthDtos.ApiResponse.ok("Proveedor creado exitosamente", proveedor));
    }

    @Operation(summary = "Actualizar proveedor")
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMINISTRADOR','ALMACENERO')")
    public ResponseEntity<AuthDtos.ApiResponse<ProveedorEntity>> actualizar(
            @PathVariable Long id,
            @Valid @RequestBody ActualizarProveedorRequest req) {
        ProveedorEntity proveedor = useCase.actualizar(id, req.nombre(), req.telefono(),
                req.email(), req.direccion(), req.contacto());
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Proveedor actualizado", proveedor));
    }

    @Operation(summary = "Desactivar proveedor")
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<Void>> desactivar(@PathVariable Long id) {
        useCase.desactivar(id);
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Proveedor desactivado", null));
    }
}
