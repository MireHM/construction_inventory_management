package com.ucb.inventariocivil.presentation.controllers;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * DTOs para el módulo de autenticación.
 * Registros de Java 17 para inmutabilidad y concisión.
 */
public class AuthDtos {

    // ── REQUEST ──────────────────────────────────────────────────────────────

    public record LoginRequest(
            @NotBlank(message = "El email es requerido")
            @Email(message = "Formato de email inválido")
            String email,

            @NotBlank(message = "La contraseña es requerida")
            @Size(min = 6, message = "La contraseña debe tener al menos 6 caracteres")
            String password
    ) {}

    // ── RESPONSE ─────────────────────────────────────────────────────────────

    public record LoginResponse(
            String accessToken,
            String tokenType,
            String id,
            String nombre,
            String email,
            String rol
    ) {
        public static LoginResponse of(String token, String id,
                                       String nombre, String email, String rol) {
            return new LoginResponse(token, "Bearer", id, nombre, email, rol);
        }
    }

    public record ApiResponse<T>(
            boolean success,
            String message,
            T data
    ) {
        public static <T> ApiResponse<T> ok(String message, T data) {
            return new ApiResponse<>(true, message, data);
        }

        public static <T> ApiResponse<T> error(String message) {
            return new ApiResponse<>(false, message, null);
        }
    }
}
