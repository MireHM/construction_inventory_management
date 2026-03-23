package com.ucb.inventariocivil.infrastructure.persistence.jpa;

import com.ucb.inventariocivil.infrastructure.persistence.entities.MaterialEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface MaterialJpaRepository extends JpaRepository<MaterialEntity, Long> {

    Optional<MaterialEntity> findByCodigo(String codigo);
    List<MaterialEntity> findByActivoTrue();
    List<MaterialEntity> findByCategoriaId(Long categoriaId);
    boolean existsByCodigo(String codigo);
    long countByActivoTrue();

    @Query("SELECT m FROM MaterialEntity m WHERE m.activo = true AND m.stockActual < m.stockMinimo")
    List<MaterialEntity> findMaterialesBajoStockMinimo();
}
