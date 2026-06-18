package com.ucb.inventariocivil.application.usecases;

import com.ucb.inventariocivil.infrastructure.persistence.entities.RolEntity;
import com.ucb.inventariocivil.infrastructure.persistence.entities.UsuarioEntity;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.UsuarioJpaRepository;
import com.ucb.inventariocivil.infrastructure.security.JwtTokenProvider;
import com.ucb.inventariocivil.presentation.controllers.AuthDtos;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;

import java.util.Optional;
import java.util.Set;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("AutenticarUsuarioUseCase")
class AutenticarUsuarioUseCaseTest {

    @Mock AuthenticationManager authenticationManager;
    @Mock JwtTokenProvider jwtTokenProvider;
    @Mock UsuarioJpaRepository usuarioJpaRepository;
    @Mock Authentication authentication;

    AutenticarUsuarioUseCase useCase;

    @BeforeEach
    void setUp() {
        useCase = new AutenticarUsuarioUseCase(authenticationManager, jwtTokenProvider, usuarioJpaRepository);
    }

    @Test
    @DisplayName("debe retornar LoginResponse con token cuando credenciales son válidas")
    void ejecutar_credencialesValidas_retornaLoginResponse() {
        // Arrange
        String email = "admin@test.bo";
        String password = "Admin2025#";
        String tokenEsperado = "jwt.token.aqui";

        RolEntity rol = new RolEntity();
        rol.setNombre("ADMINISTRADOR");

        UsuarioEntity usuario = new UsuarioEntity();
        usuario.setId(1L);
        usuario.setNombre("Administrador");
        usuario.setEmail(email);
        usuario.setPasswordHash("$2a$12$hash");
        usuario.setRoles(Set.of(rol));

        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenReturn(authentication);
        when(jwtTokenProvider.generateToken(authentication)).thenReturn(tokenEsperado);
        when(usuarioJpaRepository.findByEmail(email)).thenReturn(Optional.of(usuario));

        // Act
        AuthDtos.LoginResponse response = useCase.ejecutar(email, password);

        // Assert
        assertThat(response).isNotNull();
        assertThat(response.accessToken()).isEqualTo(tokenEsperado);
        assertThat(response.email()).isEqualTo(email);
        assertThat(response.nombre()).isEqualTo("Administrador");
        assertThat(response.rol()).isEqualTo("ADMINISTRADOR");
        assertThat(response.tokenType()).isEqualTo("Bearer");
        verify(authenticationManager).authenticate(any());
        verify(jwtTokenProvider).generateToken(authentication);
    }

    @Test
    @DisplayName("debe usar ALMACENERO como rol por defecto cuando el usuario no tiene roles")
    void ejecutar_sinRoles_retornaRolPorDefecto() {
        String email = "sin_rol@test.bo";

        UsuarioEntity usuario = new UsuarioEntity();
        usuario.setId(2L);
        usuario.setNombre("Sin Rol");
        usuario.setEmail(email);
        usuario.setPasswordHash("$2a$12$hash");
        usuario.setRoles(Set.of());

        when(authenticationManager.authenticate(any())).thenReturn(authentication);
        when(jwtTokenProvider.generateToken(authentication)).thenReturn("token");
        when(usuarioJpaRepository.findByEmail(email)).thenReturn(Optional.of(usuario));

        AuthDtos.LoginResponse response = useCase.ejecutar(email, "password");

        assertThat(response.rol()).isEqualTo("ALMACENERO");
    }

    @Test
    @DisplayName("debe lanzar excepción cuando credenciales son inválidas")
    void ejecutar_credencialesInvalidas_lanzaExcepcion() {
        when(authenticationManager.authenticate(any()))
                .thenThrow(new BadCredentialsException("Credenciales inválidas"));

        assertThatThrownBy(() -> useCase.ejecutar("bad@test.bo", "wrong"))
                .isInstanceOf(BadCredentialsException.class);

        verify(jwtTokenProvider, never()).generateToken(any());
        verify(usuarioJpaRepository, never()).findByEmail(any());
    }
}
