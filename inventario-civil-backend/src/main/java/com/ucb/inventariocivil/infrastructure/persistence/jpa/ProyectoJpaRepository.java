package com.ucb.inventariocivil.infrastructure.persistence.jpa;

import com.ucb.inventariocivil.infrastructure.persistence.entities.ProyectoEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ProyectoJpaRepository extends JpaRepository<ProyectoEntity, Long> {
    List<ProyectoEntity> findByActivoTrue();
    Optional<ProyectoEntity> findByCodigo(String codigo);
    boolean existsByCodigo(String codigo);
    List<ProyectoEntity> findByEstadoAndActivoTrue(String estado);
}
