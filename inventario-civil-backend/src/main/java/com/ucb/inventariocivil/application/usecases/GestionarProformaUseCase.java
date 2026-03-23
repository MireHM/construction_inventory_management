package com.ucb.inventariocivil.application.usecases;

import com.ucb.inventariocivil.domain.exceptions.RecursoNoEncontradoException;
import com.ucb.inventariocivil.infrastructure.persistence.entities.ProformaEntity;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.ProformaJpaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class GestionarProformaUseCase {

    private final ProformaJpaRepository proformaRepository;

    public GestionarProformaUseCase(ProformaJpaRepository proformaRepository) {
        this.proformaRepository = proformaRepository;
    }

    @Transactional(readOnly = true)
    public List<ProformaEntity> listarPorProyecto(Long proyectoId) {
        return proformaRepository.findByProyectoIdOrderByCreatedAtDesc(proyectoId);
    }

    @Transactional(readOnly = true)
    public ProformaEntity obtenerPorId(Long id) {
        return proformaRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Proforma", id));
    }

    @Transactional
    public ProformaEntity crear(ProformaEntity proforma) {
        if (proformaRepository.existsByCodigo(proforma.getCodigo())) {
            throw new IllegalArgumentException(
                    "Ya existe una proforma con el código: " + proforma.getCodigo());
        }
        // Vincular partidas con la proforma
        if (proforma.getPartidas() != null) {
            proforma.getPartidas().forEach(p -> p.setProforma(proforma));
        }
        return proformaRepository.save(proforma);
    }

    @Transactional
    public ProformaEntity actualizarEstado(Long id, String estado) {
        ProformaEntity proforma = obtenerPorId(id);
        proforma.setEstado(estado);
        return proformaRepository.save(proforma);
    }
}
