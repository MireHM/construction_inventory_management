package com.ucb.inventariocivil.infrastructure.persistence.jpa;

import com.ucb.inventariocivil.infrastructure.persistence.entities.AlertaStockEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AlertaStockJpaRepository extends JpaRepository<AlertaStockEntity, Long> {
    List<AlertaStockEntity> findByAtendidaFalseOrderByCreatedAtDesc();
    List<AlertaStockEntity> findByMaterialIdOrderByCreatedAtDesc(Long materialId);
}
