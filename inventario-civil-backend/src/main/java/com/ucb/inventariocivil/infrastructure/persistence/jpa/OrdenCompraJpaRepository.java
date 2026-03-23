package com.ucb.inventariocivil.infrastructure.persistence.jpa;

import com.ucb.inventariocivil.infrastructure.persistence.entities.OrdenCompraEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.math.BigDecimal;
import java.util.List;

public interface OrdenCompraJpaRepository
        extends JpaRepository<OrdenCompraEntity, Long> {

    List<OrdenCompraEntity> findByEstadoOrderByFechaGeneracionDesc(String estado);

    Page<OrdenCompraEntity> findAllByOrderByFechaGeneracionDesc(Pageable pageable);

    List<OrdenCompraEntity> findByMaterialIdOrderByFechaGeneracionDesc(Long materialId);

    @Query("SELECT COUNT(o) FROM OrdenCompraEntity o WHERE o.estado = 'PENDIENTE'")
    long countPendientes();

    @Query("SELECT COALESCE(SUM(o.costoEstimado), 0) " +
           "FROM OrdenCompraEntity o WHERE o.estado IN ('APROBADA','RECIBIDA')")
    BigDecimal totalCostoAprobado();
}
