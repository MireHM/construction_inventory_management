package com.ucb.inventariocivil.application.usecases;

import com.ucb.inventariocivil.domain.exceptions.RecursoNoEncontradoException;
import com.ucb.inventariocivil.infrastructure.persistence.entities.MaterialEntity;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.MaterialJpaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("GestionarMaterialUseCase")
class GestionarMaterialUseCaseTest {

    @Mock MaterialJpaRepository materialRepository;

    GestionarMaterialUseCase useCase;

    @BeforeEach
    void setUp() {
        useCase = new GestionarMaterialUseCase(materialRepository);
    }

    private MaterialEntity buildMaterial(Long id, String codigo) {
        MaterialEntity m = new MaterialEntity();
        m.setId(id);
        m.setCodigo(codigo);
        m.setNombre("Cemento Portland " + codigo);
        m.setCategoriaId(2L);
        m.setUnidadMedidaId(8L);
        m.setPrecioReferencia(new BigDecimal("55.00"));
        m.setStockActual(new BigDecimal("150.00"));
        m.setStockMinimo(new BigDecimal("50.00"));
        m.setActivo(true);
        return m;
    }

    @Test
    @DisplayName("listarActivos debe retornar solo materiales activos")
    void listarActivos_retornaMaterialesActivos() {
        List<MaterialEntity> activos = List.of(buildMaterial(1L, "MAT-001"));
        when(materialRepository.findByActivoTrue()).thenReturn(activos);

        List<MaterialEntity> resultado = useCase.listarActivos();

        assertThat(resultado).hasSize(1);
        assertThat(resultado.get(0).getCodigo()).isEqualTo("MAT-001");
        verify(materialRepository).findByActivoTrue();
    }

    @Test
    @DisplayName("obtenerPorId debe lanzar RecursoNoEncontradoException cuando no existe")
    void obtenerPorId_noExiste_lanzaExcepcion() {
        when(materialRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> useCase.obtenerPorId(99L))
                .isInstanceOf(RecursoNoEncontradoException.class);
    }

    @Test
    @DisplayName("obtenerPorId debe retornar material cuando existe")
    void obtenerPorId_existe_retornaMaterial() {
        MaterialEntity mat = buildMaterial(1L, "MAT-001");
        when(materialRepository.findById(1L)).thenReturn(Optional.of(mat));

        MaterialEntity resultado = useCase.obtenerPorId(1L);

        assertThat(resultado.getCodigo()).isEqualTo("MAT-001");
    }

    @Test
    @DisplayName("crear debe guardar material cuando código no existe")
    void crear_codigoNuevo_guardaMaterial() {
        MaterialEntity mat = buildMaterial(null, "MAT-NEW");
        when(materialRepository.existsByCodigo("MAT-NEW")).thenReturn(false);
        when(materialRepository.save(mat)).thenReturn(mat);

        MaterialEntity creado = useCase.crear(mat);

        assertThat(creado).isNotNull();
        verify(materialRepository).save(mat);
    }

    @Test
    @DisplayName("crear debe lanzar excepción cuando código ya existe")
    void crear_codigoDuplicado_lanzaExcepcion() {
        MaterialEntity mat = buildMaterial(null, "MAT-001");
        when(materialRepository.existsByCodigo("MAT-001")).thenReturn(true);

        assertThatThrownBy(() -> useCase.crear(mat))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("MAT-001");

        verify(materialRepository, never()).save(any());
    }

    @Test
    @DisplayName("desactivar debe cambiar activo a false")
    void desactivar_materialExistente_desactiva() {
        MaterialEntity mat = buildMaterial(1L, "MAT-001");
        when(materialRepository.findById(1L)).thenReturn(Optional.of(mat));
        when(materialRepository.save(mat)).thenReturn(mat);

        useCase.desactivar(1L);

        assertThat(mat.isActivo()).isFalse();
        verify(materialRepository).save(mat);
    }
}
