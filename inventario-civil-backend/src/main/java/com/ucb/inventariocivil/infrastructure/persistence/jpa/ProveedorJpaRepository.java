package com.ucb.inventariocivil.infrastructure.persistence.jpa;

import com.ucb.inventariocivil.infrastructure.persistence.entities.ProveedorEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProveedorJpaRepository extends JpaRepository<ProveedorEntity, Long> {
    List<ProveedorEntity> findByActivoTrue();
    boolean existsByNit(String nit);
}
