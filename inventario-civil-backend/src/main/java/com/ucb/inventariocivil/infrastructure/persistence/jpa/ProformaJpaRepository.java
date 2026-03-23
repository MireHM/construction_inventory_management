package com.ucb.inventariocivil.infrastructure.persistence.jpa;

import com.ucb.inventariocivil.infrastructure.persistence.entities.ProformaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface ProformaJpaRepository extends JpaRepository<ProformaEntity, Long> {
    List<ProformaEntity> findByProyectoIdOrderByCreatedAtDesc(Long proyectoId);
    Optional<ProformaEntity> findByCodigo(String codigo);
    boolean existsByCodigo(String codigo);
}
