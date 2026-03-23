package com.ucb.inventariocivil.infrastructure.persistence.jpa;

import com.ucb.inventariocivil.infrastructure.persistence.entities.MovimientoInventarioEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface MovimientoJpaRepository
        extends JpaRepository<MovimientoInventarioEntity, Long> {

    List<MovimientoInventarioEntity> findByMaterialIdOrderByFechaMovimientoDesc(
            Long materialId);

    Page<MovimientoInventarioEntity> findByProyectoIdOrderByFechaMovimientoDesc(
            Long proyectoId, Pageable pageable);

    Page<MovimientoInventarioEntity> findAllByOrderByFechaMovimientoDesc(
            Pageable pageable);

    @Query("SELECT m FROM MovimientoInventarioEntity m " +
           "WHERE m.fechaMovimiento BETWEEN :desde AND :hasta " +
           "ORDER BY m.fechaMovimiento DESC")
    List<MovimientoInventarioEntity> findByRangoFecha(
            @Param("desde") LocalDateTime desde,
            @Param("hasta") LocalDateTime hasta);

    @Query("SELECT m FROM MovimientoInventarioEntity m " +
           "ORDER BY m.fechaMovimiento DESC")
    List<MovimientoInventarioEntity> findUltimos(Pageable pageable);
}
