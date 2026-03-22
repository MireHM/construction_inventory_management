package com.ucb.inventariocivil.application.usecases;

import com.ucb.inventariocivil.infrastructure.persistence.jpa.UsuarioJpaRepository;
import com.ucb.inventariocivil.infrastructure.security.JwtTokenProvider;
import com.ucb.inventariocivil.presentation.controllers.AuthDtos;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

/**
 * Caso de uso: Autenticar Usuario.
 * Capa de Aplicación – orquesta la autenticación y la generación del JWT.
 */
@Service
public class AutenticarUsuarioUseCase {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final UsuarioJpaRepository usuarioJpaRepository;

    public AutenticarUsuarioUseCase(AuthenticationManager authenticationManager,
                                    JwtTokenProvider jwtTokenProvider,
                                    UsuarioJpaRepository usuarioJpaRepository) {
        this.authenticationManager = authenticationManager;
        this.jwtTokenProvider = jwtTokenProvider;
        this.usuarioJpaRepository = usuarioJpaRepository;
    }

    public AuthDtos.LoginResponse ejecutar(String email, String password) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(email, password)
        );

        String token = jwtTokenProvider.generateToken(authentication);

        var usuario = usuarioJpaRepository.findByEmail(email).orElseThrow();

        String rol = usuario.getRoles().stream()
                .findFirst()
                .map(r -> r.getNombre())
                .orElse("ALMACENERO");

        return new AuthDtos.LoginResponse(
                token,
                "Bearer",
                usuario.getId().toString(),
                usuario.getNombre(),
                usuario.getEmail(),
                rol
        );
    }
}
