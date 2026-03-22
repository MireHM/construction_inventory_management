package com.ucb.inventariocivil.presentation.controllers;

import com.ucb.inventariocivil.domain.exceptions.RecursoNoEncontradoException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.stream.Collectors;

/**
 * Manejador global de excepciones.
 * Convierte excepciones del dominio y de Spring en respuestas HTTP estandarizadas.
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<AuthDtos.ApiResponse<Void>> handleBadCredentials(
            BadCredentialsException ex) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(AuthDtos.ApiResponse.error("Credenciales incorrectas."));
    }

    @ExceptionHandler(DisabledException.class)
    public ResponseEntity<AuthDtos.ApiResponse<Void>> handleDisabled(
            DisabledException ex) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(AuthDtos.ApiResponse.error("Usuario inactivo. Contacta al administrador."));
    }

    @ExceptionHandler(RecursoNoEncontradoException.class)
    public ResponseEntity<AuthDtos.ApiResponse<Void>> handleNotFound(
            RecursoNoEncontradoException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(AuthDtos.ApiResponse.error(ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<AuthDtos.ApiResponse<Void>> handleValidation(
            MethodArgumentNotValidException ex) {
        String errores = ex.getBindingResult().getFieldErrors().stream()
                .map(FieldError::getDefaultMessage)
                .collect(Collectors.joining(", "));
        return ResponseEntity.badRequest()
                .body(AuthDtos.ApiResponse.error(errores));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<AuthDtos.ApiResponse<Void>> handleGeneral(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(AuthDtos.ApiResponse.error("Error interno del servidor."));
    }
}
