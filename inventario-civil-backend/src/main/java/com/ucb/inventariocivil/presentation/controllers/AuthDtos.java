package com.ucb.inventariocivil.presentation.controllers;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public class AuthDtos {

    public record LoginRequest(
        @Email(message = "Formato de correo inválido")
        @NotBlank(message = "El correo es requerido")
        String email,

        @NotBlank(message = "La contraseña es requerida")
        String password
    ) {}

    public record LoginResponse(
        String accessToken,
        String tokenType,
        String id,
        String nombre,
        String email,
        String rol
    ) {}

    public record ApiResponse<T>(
        boolean success,
        String mensaje,
        T data
    ) {
        public static <T> ApiResponse<T> ok(String mensaje, T data) {
            return new ApiResponse<>(true, mensaje, data);
        }
        public static <T> ApiResponse<T> error(String mensaje) {
            return new ApiResponse<>(false, mensaje, null);
        }
    }
}
