package com.ucb.inventariocivil.application.usecases;

import com.ucb.inventariocivil.domain.exceptions.RecursoNoEncontradoException;
import com.ucb.inventariocivil.infrastructure.persistence.entities.*;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * ══════════════════════════════════════════════════════════════════════
 * MOTOR DE CÁLCULO DE REQUERIMIENTOS – Caso de Uso Core del Sistema
 * ══════════════════════════════════════════════════════════════════════
 *
 * Algoritmo:
 * Para cada partida de la proforma:
 *   Para cada material del APU asociado:
 *     cantidadRequerida = cantidadObra × cantidadPorUnidad × (1 + rendimiento/100)
 *
 * Los requerimientos se acumulan por material (un material puede aparecer
 * en múltiples partidas). Luego se comparan con el stock disponible y
 * se calcula cuánto hay que comprar.
 *
 * Ejemplo real:
 *   Partida: Hormigón H-180, cantidad = 45 m³
 *   APU-002: Cemento 6.5 sacos/m³ + 5% desperdicio
 *   → cemento requerido = 45 × 6.5 × 1.05 = 307.125 sacos
 */
@Service
public class CalcularRequerimientosUseCase {

    private final ProformaJpaRepository     proformaRepository;
    private final ApuJpaRepository          apuRepository;
    private final MaterialJpaRepository     materialRepository;
    private final RequerimientoJpaRepository requerimientoRepository;

    public CalcularRequerimientosUseCase(
            ProformaJpaRepository proformaRepository,
            ApuJpaRepository apuRepository,
            MaterialJpaRepository materialRepository,
            RequerimientoJpaRepository requerimientoRepository) {
        this.proformaRepository      = proformaRepository;
        this.apuRepository           = apuRepository;
        this.materialRepository      = materialRepository;
        this.requerimientoRepository = requerimientoRepository;
    }

    @Transactional
    public List<RequerimientoEntity> calcular(Long proformaId, Long usuarioId) {
        // 1. Obtener la proforma con sus partidas
        ProformaEntity proforma = proformaRepository.findById(proformaId)
                .orElseThrow(() -> new RecursoNoEncontradoException("Proforma", proformaId));

        List<PartidaProformaEntity> partidas = proforma.getPartidas();
        if (partidas == null || partidas.isEmpty()) {
            throw new IllegalStateException(
                    "La proforma no tiene partidas registradas.");
        }

        // 2. Acumular requerimientos por materialId
        // Map<materialId, cantidadTotal>
        Map<Long, BigDecimal> acumulado      = new HashMap<>();
        Map<Long, Long>       materialAPartida = new HashMap<>();

        for (PartidaProformaEntity partida : partidas) {
            ApuEntity apu = apuRepository.findById(partida.getApuId())
                    .orElseThrow(() -> new RecursoNoEncontradoException(
                            "APU", partida.getApuId()));

            for (ApuMaterialEntity apuMaterial : apu.getMateriales()) {
                // cantidadRequerida = cantidadObra × cantidadPorUnidad × factor
                BigDecimal factor = BigDecimal.ONE.add(
                        apuMaterial.getRendimientoPorcentaje()
                                .divide(BigDecimal.valueOf(100), 6, RoundingMode.HALF_UP));

                BigDecimal requerido = partida.getCantidadObra()
                        .multiply(apuMaterial.getCantidadPorUnidad())
                        .multiply(factor)
                        .setScale(3, RoundingMode.HALF_UP);

                Long matId = apuMaterial.getMaterialId();
                acumulado.merge(matId, requerido, BigDecimal::add);
                materialAPartida.put(matId, partida.getId());
            }
        }

        // 3. Eliminar requerimientos anteriores de esta proforma
        requerimientoRepository.deleteByProformaId(proformaId);

        // 4. Crear nuevos requerimientos comparando con stock actual
        List<RequerimientoEntity> resultados = new ArrayList<>();

        for (Map.Entry<Long, BigDecimal> entry : acumulado.entrySet()) {
            Long materialId        = entry.getKey();
            BigDecimal calculada   = entry.getValue();

            MaterialEntity material = materialRepository.findById(materialId)
                    .orElseThrow(() -> new RecursoNoEncontradoException(
                            "Material", materialId));

            BigDecimal disponible  = material.getStockActual();
            BigDecimal aComprar    = calculada.subtract(disponible)
                    .max(BigDecimal.ZERO)
                    .setScale(3, RoundingMode.HALF_UP);

            RequerimientoEntity req = new RequerimientoEntity();
            req.setProformaId(proformaId);
            req.setMaterialId(materialId);
            req.setPartidaId(materialAPartida.get(materialId));
            req.setCantidadCalculada(calculada);
            req.setCantidadDisponible(disponible);
            req.setCantidadAComprar(aComprar);
            req.setSolicitadoPor(usuarioId);

            resultados.add(requerimientoRepository.save(req));
        }

        return resultados;
    }

    @Transactional(readOnly = true)
    public List<RequerimientoEntity> obtenerPorProforma(Long proformaId) {
        return requerimientoRepository.findByProformaIdOrderByMaterialId(proformaId);
    }
}
