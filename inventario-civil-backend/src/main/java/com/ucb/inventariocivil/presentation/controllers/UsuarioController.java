package com.ucb.inventariocivil.presentation.controllers;

import com.ucb.inventariocivil.application.usecases.GestionarUsuarioUseCase;
import com.ucb.inventariocivil.infrastructure.persistence.entities.UsuarioEntity;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "Usuarios")
@SecurityRequirement(name = "bearerAuth")
@RestController
@RequestMapping("/api/v1/usuarios")
public class UsuarioController {

    private final GestionarUsuarioUseCase useCase;

    public UsuarioController(GestionarUsuarioUseCase useCase) {
        this.useCase = useCase;
    }

    // ── DTOs ────────────────────────────────────────────────────────────────

    public record CrearUsuarioRequest(
        @NotBlank String nombre,
        @Email @NotBlank String email,
        @NotBlank @Size(min = 8) String password,
        String telefono
    ) {}

    public record ActualizarUsuarioRequest(String nombre, String telefono) {}

    public record AsignarRolesRequest(@NotBlank List<Long> rolIds) {}

    public record AsignarProyectosRequest(@NotBlank List<Long> proyectoIds) {}

    public record CambiarPasswordRequest(@NotBlank @Size(min = 8) String nuevaPassword) {}

    // ── Endpoints ────────────────────────────────────────────────────────────

    @Operation(summary = "Listar todos los usuarios activos")
    @GetMapping
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<List<UsuarioEntity>>> listar() {
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Usuarios obtenidos", useCase.listarActivos()));
    }

    @Operation(summary = "Obtener usuario por ID")
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<UsuarioEntity>> obtener(@PathVariable Long id) {
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Usuario encontrado", useCase.obtenerPorId(id)));
    }

    @Operation(summary = "Crear nuevo usuario")
    @PostMapping
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<UsuarioEntity>> crear(@Valid @RequestBody CrearUsuarioRequest req) {
        UsuarioEntity usuario = useCase.crear(req.nombre(), req.email(), req.password(), req.telefono());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(AuthDtos.ApiResponse.ok("Usuario creado exitosamente", usuario));
    }

    @Operation(summary = "Actualizar nombre/teléfono de usuario")
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<UsuarioEntity>> actualizar(
            @PathVariable Long id,
            @Valid @RequestBody ActualizarUsuarioRequest req) {
        UsuarioEntity usuario = useCase.actualizar(id, req.nombre(), req.telefono());
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Usuario actualizado", usuario));
    }

    @Operation(summary = "Activar o desactivar usuario")
    @PatchMapping("/{id}/toggle-activo")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<Map<String, Object>>> toggleActivo(@PathVariable Long id) {
        UsuarioEntity usuario = useCase.toggleActivo(id);
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok(
                "Estado actualizado",
                Map.of("id", usuario.getId(), "activo", usuario.isActivo())));
    }

    @Operation(summary = "Asignar roles a un usuario")
    @PatchMapping("/{id}/roles")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<UsuarioEntity>> asignarRoles(
            @PathVariable Long id,
            @Valid @RequestBody AsignarRolesRequest req) {
        UsuarioEntity usuario = useCase.asignarRoles(id, req.rolIds());
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Roles asignados", usuario));
    }

    @Operation(summary = "Asignar proyectos a un usuario")
    @PatchMapping("/{id}/proyectos")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<UsuarioEntity>> asignarProyectos(
            @PathVariable Long id,
            @Valid @RequestBody AsignarProyectosRequest req) {
        UsuarioEntity usuario = useCase.asignarProyectos(id, req.proyectoIds());
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Proyectos asignados", usuario));
    }

    @Operation(summary = "Cambiar contraseña de usuario")
    @PatchMapping("/{id}/password")
    @PreAuthorize("hasRole('ADMINISTRADOR')")
    public ResponseEntity<AuthDtos.ApiResponse<Void>> cambiarPassword(
            @PathVariable Long id,
            @Valid @RequestBody CambiarPasswordRequest req) {
        useCase.cambiarPassword(id, req.nuevaPassword());
        return ResponseEntity.ok(AuthDtos.ApiResponse.ok("Contraseña actualizada", null));
    }
}
