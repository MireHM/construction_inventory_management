package com.ucb.inventariocivil.infrastructure.security;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import org.springframework.context.annotation.Configuration;

/**
 * Configuración de OpenAPI / Swagger UI.
 * Agrega el esquema de seguridad Bearer JWT para poder probar
 * endpoints protegidos directamente desde Swagger UI.
 */
@Configuration
@OpenAPIDefinition(info = @Info(
    title = "Inventario Civil API",
    version = "1.0.0",
    description = "Plataforma Full Stack – Control de Inventario en Proyectos de Construcción Urbana"
))
@SecurityScheme(
    name = "bearerAuth",
    type = SecuritySchemeType.HTTP,
    scheme = "bearer",
    bearerFormat = "JWT"
)
public class OpenApiConfig {
}
