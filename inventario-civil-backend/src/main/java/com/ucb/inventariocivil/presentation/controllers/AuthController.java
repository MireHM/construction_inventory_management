package com.ucb.inventariocivil.presentation.controllers;

import com.ucb.inventariocivil.application.usecases.AutenticarUsuarioUseCase;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador REST de Autenticación.
 * Capa de Presentación – recibe HTTP, delega al use case, retorna respuesta.
 *
 * Endpoints:
 *   POST /api/v1/auth/login  → Login con email + password, retorna JWT
 */
@Tag(name = "Autenticación", description = "Registro e inicio de sesión")
@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AutenticarUsuarioUseCase autenticarUseCase;

    public AuthController(AutenticarUsuarioUseCase autenticarUseCase) {
        this.autenticarUseCase = autenticarUseCase;
    }

    @Operation(summary = "Iniciar sesión",
               description = "Autentica al usuario y retorna un JWT válido por 24 horas.")
    @PostMapping("/login")
    public ResponseEntity<AuthDtos.ApiResponse<AuthDtos.LoginResponse>> login(
            @Valid @RequestBody AuthDtos.LoginRequest request) {

        AuthDtos.LoginResponse response = autenticarUseCase.ejecutar(
                request.email(),
                request.password()
        );

        return ResponseEntity.ok(
                AuthDtos.ApiResponse.ok("Inicio de sesión exitoso.", response)
        );
    }
}
