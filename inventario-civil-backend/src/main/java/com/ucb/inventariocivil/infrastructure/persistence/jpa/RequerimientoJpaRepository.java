package com.ucb.inventariocivil.infrastructure.persistence.jpa;

import com.ucb.inventariocivil.infrastructure.persistence.entities.RequerimientoEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface RequerimientoJpaRepository extends JpaRepository<RequerimientoEntity, Long> {
    List<RequerimientoEntity> findByProformaIdOrderByMaterialId(Long proformaId);
    void deleteByProformaId(Long proformaId);
}
