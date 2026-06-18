package com.ucb.inventariocivil.application.usecases;

import com.ucb.inventariocivil.domain.exceptions.RecursoNoEncontradoException;
import com.ucb.inventariocivil.infrastructure.persistence.entities.ProyectoEntity;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.ProyectoJpaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Service
public class GestionarProyectoUseCase {

    private final ProyectoJpaRepository proyectoRepository;

    public GestionarProyectoUseCase(ProyectoJpaRepository proyectoRepository) {
        this.proyectoRepository = proyectoRepository;
    }

    @Transactional(readOnly = true)
    public List<ProyectoEntity> listarActivos() {
        return proyectoRepository.findByActivoTrue();
    }

    @Transactional(readOnly = true)
    public List<ProyectoEntity> listarTodos() {
        return proyectoRepository.findAll();
    }

    @Transactional(readOnly = true)
    public ProyectoEntity obtenerPorId(Long id) {
        return proyectoRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Proyecto no encontrado con id: " + id));
    }

    @Transactional(readOnly = true)
    public List<ProyectoEntity> listarPorEstado(String estado) {
        return proyectoRepository.findByEstadoAndActivoTrue(estado);
    }

    @Transactional
    public ProyectoEntity crear(String codigo, String nombre, String descripcion,
                                LocalDate fechaInicio, LocalDate fechaFinEstimada,
                                Long responsableId, BigDecimal presupuesto) {
        if (proyectoRepository.existsByCodigo(codigo)) {
            throw new IllegalArgumentException("Ya existe un proyecto con código: " + codigo);
        }
        ProyectoEntity proyecto = new ProyectoEntity();
        proyecto.setCodigo(codigo);
        proyecto.setNombre(nombre);
        proyecto.setDescripcion(descripcion);
        proyecto.setFechaInicio(fechaInicio);
        proyecto.setFechaFinEstimada(fechaFinEstimada);
        proyecto.setResponsableId(responsableId);
        proyecto.setPresupuesto(presupuesto);
        proyecto.setEstado("PLANIFICACION");
        proyecto.setActivo(true);
        return proyectoRepository.save(proyecto);
    }

    @Transactional
    public ProyectoEntity actualizar(Long id, String nombre, String descripcion,
                                     String estado, LocalDate fechaFinEstimada,
                                     BigDecimal presupuesto) {
        ProyectoEntity proyecto = obtenerPorId(id);
        if (nombre != null && !nombre.isBlank()) proyecto.setNombre(nombre);
        if (descripcion != null) proyecto.setDescripcion(descripcion);
        if (estado != null && !estado.isBlank()) proyecto.setEstado(estado);
        if (fechaFinEstimada != null) proyecto.setFechaFinEstimada(fechaFinEstimada);
        if (presupuesto != null) proyecto.setPresupuesto(presupuesto);
        return proyectoRepository.save(proyecto);
    }

    @Transactional
    public void desactivar(Long id) {
        ProyectoEntity proyecto = obtenerPorId(id);
        proyecto.setActivo(false);
        proyectoRepository.save(proyecto);
    }
}
