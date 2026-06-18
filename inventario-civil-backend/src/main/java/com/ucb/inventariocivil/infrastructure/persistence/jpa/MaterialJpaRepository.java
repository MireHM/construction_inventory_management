package com.ucb.inventariocivil.infrastructure.persistence.jpa;

import com.ucb.inventariocivil.infrastructure.persistence.entities.MaterialEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

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

    @Query("SELECT m FROM MaterialEntity m WHERE m.activo = true " +
           "AND (:q IS NULL OR LOWER(m.nombre) LIKE LOWER(CONCAT('%',:q,'%')) OR LOWER(m.codigo) LIKE LOWER(CONCAT('%',:q,'%'))) " +
           "AND (:categoriaId IS NULL OR m.categoriaId = :categoriaId)")
    Page<MaterialEntity> buscar(@Param("q") String q,
                                @Param("categoriaId") Long categoriaId,
                                Pageable pageable);

    @Query("SELECT m FROM MaterialEntity m WHERE m.activo = true " +
           "AND (:q IS NULL OR LOWER(m.nombre) LIKE LOWER(CONCAT('%',:q,'%')) OR LOWER(m.codigo) LIKE LOWER(CONCAT('%',:q,'%'))) " +
           "AND (:categoriaId IS NULL OR m.categoriaId = :categoriaId)")
    List<MaterialEntity> buscarSinPaginacion(@Param("q") String q,
                                             @Param("categoriaId") Long categoriaId);
}
