package com.ucb.inventariocivil.application.usecases;

import com.ucb.inventariocivil.domain.exceptions.RecursoNoEncontradoException;
import com.ucb.inventariocivil.infrastructure.persistence.entities.MaterialEntity;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.MaterialJpaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Caso de uso: Gestión de Materiales (CRUD).
 * Capa de Aplicación.
 */
@Service
public class GestionarMaterialUseCase {

    private final MaterialJpaRepository materialRepository;

    public GestionarMaterialUseCase(MaterialJpaRepository materialRepository) {
        this.materialRepository = materialRepository;
    }

    @Transactional(readOnly = true)
    public List<MaterialEntity> listarActivos() {
        return materialRepository.findByActivoTrue();
    }

    @Transactional(readOnly = true)
    public MaterialEntity obtenerPorId(Long id) {
        return materialRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Material", id));
    }

    @Transactional(readOnly = true)
    public List<MaterialEntity> listarBajoStockMinimo() {
        return materialRepository.findMaterialesBajoStockMinimo();
    }

    @Transactional
    public MaterialEntity crear(MaterialEntity material) {
        if (materialRepository.existsByCodigo(material.getCodigo())) {
            throw new IllegalArgumentException(
                    "Ya existe un material con el código: " + material.getCodigo());
        }
        return materialRepository.save(material);
    }

    @Transactional
    public MaterialEntity actualizar(Long id, MaterialEntity datos) {
        MaterialEntity existente = obtenerPorId(id);
        existente.setNombre(datos.getNombre());
        existente.setDescripcion(datos.getDescripcion());
        existente.setPrecioReferencia(datos.getPrecioReferencia());
        existente.setStockMinimo(datos.getStockMinimo());
        existente.setStockMaximo(datos.getStockMaximo());
        existente.setCategoriaId(datos.getCategoriaId());
        existente.setUnidadMedidaId(datos.getUnidadMedidaId());
        return materialRepository.save(existente);
    }

    @Transactional
    public void desactivar(Long id) {
        MaterialEntity material = obtenerPorId(id);
        material.setActivo(false);
        materialRepository.save(material);
    }
}
