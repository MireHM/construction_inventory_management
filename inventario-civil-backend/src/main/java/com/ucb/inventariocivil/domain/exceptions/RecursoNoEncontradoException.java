package com.ucb.inventariocivil.domain.exceptions;

public class RecursoNoEncontradoException extends DomainException {
    public RecursoNoEncontradoException(String recurso, Long id) {
        super(recurso + " con id " + id + " no encontrado.");
    }
    public RecursoNoEncontradoException(String mensaje) {
        super(mensaje);
    }
}
