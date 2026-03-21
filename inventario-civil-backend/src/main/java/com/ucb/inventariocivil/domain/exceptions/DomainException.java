package com.ucb.inventariocivil.domain.exceptions;

/**
 * Excepción base del dominio.
 */
public class DomainException extends RuntimeException {
    public DomainException(String message) {
        super(message);
    }
    public DomainException(String message, Throwable cause) {
        super(message, cause);
    }
}
