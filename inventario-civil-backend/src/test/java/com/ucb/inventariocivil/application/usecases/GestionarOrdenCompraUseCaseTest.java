package com.ucb.inventariocivil.application.usecases;

import com.ucb.inventariocivil.domain.exceptions.DomainException;
import com.ucb.inventariocivil.domain.exceptions.RecursoNoEncontradoException;
import com.ucb.inventariocivil.infrastructure.persistence.entities.OrdenCompraEntity;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.OrdenCompraJpaRepository;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.RequerimientoJpaRepository;
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
@DisplayName("GestionarOrdenCompraUseCase")
class GestionarOrdenCompraUseCaseTest {

    @Mock OrdenCompraJpaRepository ordenRepository;
    @Mock RequerimientoJpaRepository requerimientoRepository;
    @Mock RegistrarMovimientoInventarioUseCase movimientoUseCase;

    GestionarOrdenCompraUseCase useCase;

    @BeforeEach
    void setUp() {
        useCase = new GestionarOrdenCompraUseCase(
                ordenRepository, requerimientoRepository, movimientoUseCase);
    }

    private OrdenCompraEntity buildOrden(Long id, String estado) {
        OrdenCompraEntity oc = new OrdenCompraEntity();
        oc.setId(id);
        oc.setEstado(estado);
        oc.setMaterialId(1L);
        oc.setRequerimientoId(1L);
        oc.setGeneradaPor(1L);
        oc.setCantidad(new BigDecimal("10"));
        oc.setPrecioUnitario(new BigDecimal("55.00"));
        return oc;
    }

    @Test
    @DisplayName("aprobar debe cambiar estado a APROBADA cuando está PENDIENTE")
    void aprobar_estadoPendiente_cambiaaAprobada() {
        OrdenCompraEntity orden = buildOrden(1L, "PENDIENTE");
        when(ordenRepository.findById(1L)).thenReturn(Optional.of(orden));
        when(ordenRepository.save(any())).thenReturn(orden);

        OrdenCompraEntity resultado = useCase.aprobar(1L, 1L);

        assertThat(resultado.getEstado()).isEqualTo("APROBADA");
        verify(ordenRepository).save(orden);
    }

    @Test
    @DisplayName("aprobar debe lanzar DomainException cuando la orden no está PENDIENTE")
    void aprobar_estadoNoValido_lanzaExcepcion() {
        OrdenCompraEntity orden = buildOrden(1L, "APROBADA");
        when(ordenRepository.findById(1L)).thenReturn(Optional.of(orden));

        assertThatThrownBy(() -> useCase.aprobar(1L, 1L))
                .isInstanceOf(DomainException.class);
    }

    @Test
    @DisplayName("rechazar debe cambiar estado a RECHAZADA cuando está PENDIENTE")
    void rechazar_estadoPendiente_cambiaArechazada() {
        OrdenCompraEntity orden = buildOrden(1L, "PENDIENTE");
        when(ordenRepository.findById(1L)).thenReturn(Optional.of(orden));
        when(ordenRepository.save(any())).thenReturn(orden);

        OrdenCompraEntity resultado = useCase.rechazar(1L, "Precio muy alto");

        assertThat(resultado.getEstado()).isEqualTo("RECHAZADA");
        assertThat(resultado.getObservaciones()).isEqualTo("Precio muy alto");
    }

    @Test
    @DisplayName("rechazar debe lanzar DomainException cuando la orden no está PENDIENTE")
    void rechazar_estadoNoValido_lanzaExcepcion() {
        OrdenCompraEntity orden = buildOrden(1L, "RECIBIDA");
        when(ordenRepository.findById(1L)).thenReturn(Optional.of(orden));

        assertThatThrownBy(() -> useCase.rechazar(1L, "motivo"))
                .isInstanceOf(DomainException.class);
    }

    @Test
    @DisplayName("debe lanzar RecursoNoEncontradoException cuando la orden no existe")
    void aprobar_ordenNoExiste_lanzaExcepcion() {
        when(ordenRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> useCase.aprobar(99L, 1L))
                .isInstanceOf(RecursoNoEncontradoException.class);
    }
}
