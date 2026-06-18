package com.ucb.inventariocivil.application.usecases;

import com.ucb.inventariocivil.domain.exceptions.DomainException;
import com.ucb.inventariocivil.domain.exceptions.RecursoNoEncontradoException;
import com.ucb.inventariocivil.infrastructure.persistence.entities.MaterialEntity;
import com.ucb.inventariocivil.infrastructure.persistence.entities.MovimientoInventarioEntity;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.AlertaStockJpaRepository;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.MaterialJpaRepository;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.MovimientoJpaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("RegistrarMovimientoInventarioUseCase")
class RegistrarMovimientoInventarioUseCaseTest {

    @Mock MovimientoJpaRepository movimientoRepository;
    @Mock MaterialJpaRepository materialRepository;
    @Mock AlertaStockJpaRepository alertaRepository;

    RegistrarMovimientoInventarioUseCase useCase;

    @BeforeEach
    void setUp() {
        useCase = new RegistrarMovimientoInventarioUseCase(
                movimientoRepository, materialRepository, alertaRepository);
    }

    private MaterialEntity buildMaterial(BigDecimal stock, BigDecimal minimo) {
        MaterialEntity m = new MaterialEntity();
        m.setId(1L);
        m.setCodigo("MAT-001");
        m.setNombre("Cemento");
        m.setCategoriaId(2L);
        m.setUnidadMedidaId(8L);
        m.setPrecioReferencia(new BigDecimal("55.00"));
        m.setStockActual(stock);
        m.setStockMinimo(minimo);
        m.setActivo(true);
        return m;
    }

    private MovimientoInventarioEntity buildMovimiento(String tipo, BigDecimal cantidad) {
        MovimientoInventarioEntity mov = new MovimientoInventarioEntity();
        mov.setMaterialId(1L);
        mov.setTipo(tipo);
        mov.setCantidad(cantidad);
        return mov;
    }

    @Test
    @DisplayName("INGRESO debe incrementar el stock del material")
    void registrar_ingreso_incrementaStock() {
        MaterialEntity material = buildMaterial(new BigDecimal("100"), new BigDecimal("50"));
        MovimientoInventarioEntity mov = buildMovimiento("INGRESO", new BigDecimal("50"));
        when(materialRepository.findById(1L)).thenReturn(Optional.of(material));
        when(movimientoRepository.save(any())).thenReturn(mov);
        when(materialRepository.save(any())).thenReturn(material);

        useCase.registrar(mov);

        assertThat(material.getStockActual()).isEqualByComparingTo("150");
        verify(materialRepository).save(material);
    }

    @Test
    @DisplayName("SALIDA debe decrementar el stock cuando hay suficiente disponible")
    void registrar_salida_decrementaStock() {
        MaterialEntity material = buildMaterial(new BigDecimal("200"), new BigDecimal("50"));
        MovimientoInventarioEntity mov = buildMovimiento("SALIDA", new BigDecimal("30"));
        when(materialRepository.findById(1L)).thenReturn(Optional.of(material));
        when(movimientoRepository.save(any())).thenReturn(mov);
        when(materialRepository.save(any())).thenReturn(material);

        useCase.registrar(mov);

        assertThat(material.getStockActual()).isEqualByComparingTo("170");
    }

    @Test
    @DisplayName("SALIDA debe lanzar DomainException cuando el stock es insuficiente")
    void registrar_salidaInsuficiente_lanzaExcepcion() {
        MaterialEntity material = buildMaterial(new BigDecimal("10"), new BigDecimal("5"));
        MovimientoInventarioEntity mov = buildMovimiento("SALIDA", new BigDecimal("50"));
        when(materialRepository.findById(1L)).thenReturn(Optional.of(material));

        assertThatThrownBy(() -> useCase.registrar(mov))
                .isInstanceOf(DomainException.class)
                .hasMessageContaining("Stock insuficiente");

        verify(movimientoRepository, never()).save(any());
    }

    @Test
    @DisplayName("AJUSTE debe establecer el stock al valor indicado")
    void registrar_ajuste_estableceStockDirecto() {
        MaterialEntity material = buildMaterial(new BigDecimal("100"), new BigDecimal("50"));
        MovimientoInventarioEntity mov = buildMovimiento("AJUSTE", new BigDecimal("75"));
        when(materialRepository.findById(1L)).thenReturn(Optional.of(material));
        when(movimientoRepository.save(any())).thenReturn(mov);
        when(materialRepository.save(any())).thenReturn(material);

        useCase.registrar(mov);

        assertThat(material.getStockActual()).isEqualByComparingTo("75");
    }

    @Test
    @DisplayName("debe lanzar RecursoNoEncontradoException cuando el material no existe")
    void registrar_materialNoExiste_lanzaExcepcion() {
        MovimientoInventarioEntity mov = buildMovimiento("INGRESO", new BigDecimal("10"));
        when(materialRepository.findById(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> useCase.registrar(mov))
                .isInstanceOf(RecursoNoEncontradoException.class);
    }

    @Test
    @DisplayName("debe lanzar DomainException para tipo de movimiento inválido")
    void registrar_tipoInvalido_lanzaExcepcion() {
        MaterialEntity material = buildMaterial(new BigDecimal("100"), new BigDecimal("50"));
        MovimientoInventarioEntity mov = buildMovimiento("TIPO_INVALIDO", new BigDecimal("10"));
        when(materialRepository.findById(1L)).thenReturn(Optional.of(material));

        assertThatThrownBy(() -> useCase.registrar(mov))
                .isInstanceOf(DomainException.class)
                .hasMessageContaining("Tipo de movimiento inválido");
    }

    @Test
    @DisplayName("debe generar alerta cuando stock cae a cero")
    void registrar_stockEnCero_generaAlertaSinStock() {
        MaterialEntity material = buildMaterial(new BigDecimal("30"), new BigDecimal("50"));
        MovimientoInventarioEntity mov = buildMovimiento("SALIDA", new BigDecimal("30"));
        when(materialRepository.findById(1L)).thenReturn(Optional.of(material));
        when(movimientoRepository.save(any())).thenReturn(mov);
        when(materialRepository.save(any())).thenReturn(material);

        useCase.registrar(mov);

        verify(alertaRepository).save(argThat(a -> "SIN_STOCK".equals(a.getTipo())));
    }
}
