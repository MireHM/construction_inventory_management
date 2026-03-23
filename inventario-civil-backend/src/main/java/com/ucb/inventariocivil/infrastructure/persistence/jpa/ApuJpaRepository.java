package com.ucb.inventariocivil.infrastructure.persistence.jpa;

import com.ucb.inventariocivil.infrastructure.persistence.entities.ApuEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface ApuJpaRepository extends JpaRepository<ApuEntity, Long> {
    Optional<ApuEntity> findByCodigo(String codigo);
    List<ApuEntity> findByActivoTrue();
    boolean existsByCodigo(String codigo);
}
