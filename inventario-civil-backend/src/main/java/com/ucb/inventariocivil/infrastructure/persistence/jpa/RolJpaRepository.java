package com.ucb.inventariocivil.infrastructure.persistence.jpa;

import com.ucb.inventariocivil.infrastructure.persistence.entities.RolEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RolJpaRepository extends JpaRepository<RolEntity, Long> {
    Optional<RolEntity> findByNombre(String nombre);
    boolean existsByNombre(String nombre);
}
