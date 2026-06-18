package com.ucb.inventariocivil.application.usecases;

import com.ucb.inventariocivil.domain.exceptions.RecursoNoEncontradoException;
import com.ucb.inventariocivil.infrastructure.persistence.entities.ProveedorEntity;
import com.ucb.inventariocivil.infrastructure.persistence.jpa.ProveedorJpaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class GestionarProveedorUseCase {

    private final ProveedorJpaRepository proveedorRepository;

    public GestionarProveedorUseCase(ProveedorJpaRepository proveedorRepository) {
        this.proveedorRepository = proveedorRepository;
    }

    @Transactional(readOnly = true)
    public List<ProveedorEntity> listarActivos() {
        return proveedorRepository.findByActivoTrue();
    }

    @Transactional(readOnly = true)
    public List<ProveedorEntity> listarTodos() {
        return proveedorRepository.findAll();
    }

    @Transactional(readOnly = true)
    public ProveedorEntity obtenerPorId(Long id) {
        return proveedorRepository.findById(id)
                .orElseThrow(() -> new RecursoNoEncontradoException("Proveedor no encontrado con id: " + id));
    }

    @Transactional
    public ProveedorEntity crear(String nombre, String nit, String telefono,
                                 String email, String direccion, String contacto) {
        if (nit != null && !nit.isBlank() && proveedorRepository.existsByNit(nit)) {
            throw new IllegalArgumentException("Ya existe un proveedor con NIT: " + nit);
        }
        ProveedorEntity proveedor = new ProveedorEntity();
        proveedor.setNombre(nombre);
        proveedor.setNit(nit);
        proveedor.setTelefono(telefono);
        proveedor.setEmail(email);
        proveedor.setDireccion(direccion);
        proveedor.setContacto(contacto);
        proveedor.setActivo(true);
        return proveedorRepository.save(proveedor);
    }

    @Transactional
    public ProveedorEntity actualizar(Long id, String nombre, String telefono,
                                      String email, String direccion, String contacto) {
        ProveedorEntity proveedor = obtenerPorId(id);
        if (nombre != null && !nombre.isBlank()) proveedor.setNombre(nombre);
        if (telefono != null) proveedor.setTelefono(telefono);
        if (email != null) proveedor.setEmail(email);
        if (direccion != null) proveedor.setDireccion(direccion);
        if (contacto != null) proveedor.setContacto(contacto);
        return proveedorRepository.save(proveedor);
    }

    @Transactional
    public void desactivar(Long id) {
        ProveedorEntity proveedor = obtenerPorId(id);
        proveedor.setActivo(false);
        proveedorRepository.save(proveedor);
    }
}
