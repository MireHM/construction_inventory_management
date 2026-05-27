package com.ucb.inventariocivil.presentation.controllers;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * Endpoint de salud del sistema.
 * Permite verificar que el backend está corriendo correctamente.
 */
@RestController
public class HealthController {

    /** Raíz del servicio — visible en el navegador sin autenticación. */
    @GetMapping("/")
    public ResponseEntity<Map<String, Object>> root() {
        return ResponseEntity.ok(Map.of(
            "app",     "InventarioPro — Control de Inventario para Obras Civiles",
            "version", "1.0.0",
            "status",  "UP",
            "docs",    "/swagger-ui.html",
            "health",  "/api/v1/health"
        ));
    }

    @GetMapping("/api/v1/health")
    public ResponseEntity<Map<String, Object>> health() {
        return ResponseEntity.ok(Map.of(
            "status",    "UP",
            "service",   "inventario-civil-backend",
            "version",   "1.0.0",
            "timestamp", LocalDateTime.now().toString()
        ));
    }
}
