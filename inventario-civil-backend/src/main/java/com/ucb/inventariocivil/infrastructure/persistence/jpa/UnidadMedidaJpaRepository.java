package com.ucb.inventariocivil.infrastructure.persistence.jpa;

import com.ucb.inventariocivil.infrastructure.persistence.entities.UnidadMedidaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UnidadMedidaJpaRepository extends JpaRepository<UnidadMedidaEntity, Long> {
    List<UnidadMedidaEntity> findByActivoTrue();
    boolean existsBySimbolo(String simbolo);
}
