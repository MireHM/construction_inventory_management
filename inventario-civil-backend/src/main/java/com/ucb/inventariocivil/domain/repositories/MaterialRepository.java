package com.ucb.inventariocivil.domain.repositories;

import com.ucb.inventariocivil.domain.entities.Material;

import java.util.List;
import java.util.Optional;

/**
 * Puerto (Port) del repositorio de Material.
 * Capa de Dominio – interfaz pura.
 */
public interface MaterialRepository {

    Optional<Material> findById(Long id);

    Optional<Material> findByCodigo(String codigo);

    List<Material> findAll();

    List<Material> findByActivoTrue();

    List<Material> findByCategoriaId(Long categoriaId);

    // Materiales con stock por debajo del mínimo (para alertas)
    List<Material> findMaterialesBajoStockMinimo();

    Material save(Material material);

    void deleteById(Long id);

    boolean existsByCodigo(String codigo);
}
