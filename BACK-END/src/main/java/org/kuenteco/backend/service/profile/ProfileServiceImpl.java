package org.kuenteco.backend.service.profile;

import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.auth.TokenResponseDTO;
import org.kuenteco.backend.dto.profile.LoginProfileDTO;
import org.kuenteco.backend.dto.profile.NewProfileDTO;
import org.kuenteco.backend.dto.profile.ProfileDetailDTO;
import org.kuenteco.backend.dto.profile.UpdateProfileDTO;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.UserType;
import org.kuenteco.backend.exception.exceptions.ProfileException;
import org.kuenteco.backend.jwt.JwtUtil;
import org.kuenteco.backend.mapper.profile.NewProfileMapper;
import org.kuenteco.backend.mapper.profile.ProfileDetailMapper;
import org.kuenteco.backend.mapper.profile.UpdateProfileMapper;
import org.kuenteco.backend.repository.master.MasterProfileRepository;
import org.kuenteco.backend.repository.slave.SlaveProfileRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.kuenteco.backend.service.auth.CookieService;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProfileServiceImpl implements ProfileService {
    private final MasterProfileRepository masterProfileRepository;
    private final SlaveProfileRepository slaveProfileRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final NewProfileMapper newProfileMapper;
    private final UpdateProfileMapper updateProfileMapper;
    private final ProfileDetailMapper profileDetailMapper;
    private final AuthenticationManagerBuilder authenticationManagerBuilder;
    private final TransactionTemplate transactionTemplate;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;
    private final CookieService cookieService;

    @Override
    public TokenResponseDTO authenticate(LoginProfileDTO dto, HttpServletResponse response) {
        // Verificar si la cuenta está activa antes de autenticar
        // Determinar si es un email o nombre de usuario
        Profile profile =
                Optional.ofNullable(findByNameOrEmail(dto.nameOrEmail))
                        .orElseThrow(() -> new ProfileException("Perfil no existente"));

        // Crea el token de Autenticación con email y contraseña
        UsernamePasswordAuthenticationToken authenticationToken =
                new UsernamePasswordAuthenticationToken(profile.getEmail(), dto.password);
        // Autentica al usuario
        Authentication authResult =
                authenticationManagerBuilder.getObject().authenticate(authenticationToken);
        SecurityContextHolder.getContext().setAuthentication(authResult);

        String jwt = jwtUtil.generateToken(authResult);
        cookieService.addHttpOnlyCookie("jwt", jwt, 7 * 24 * 60 * 60, response);

        return new TokenResponseDTO(jwt, profile.getUsername().toString());
    }

    public Object getProfiles() {
        // Obtener el usuario autenticado
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user =
                slaveUserRepository
                        .findByEmail(authentication.getName())
                        .orElseThrow(() -> new ProfileException("Usuario no encontrado"));

        // Obtener las cuentas del usuario
        List<Profile> profile = slaveProfileRepository.findByUser(user);

        // Verificar si las cuentas están vacías o nulas
        if (profile == null || profile.isEmpty()) {
            return "No tienes cuentas registradas";
        }

        // Devolver las cuentas del usuario
        return profileDetailMapper.toDto(profile);
    }

    public void registerProfile(NewProfileDTO dto) {
        // Obtener el usuario autenticado
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user =
                slaveUserRepository
                        .findByEmail(authentication.getName())
                        .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));
        if (user.getType().equals(UserType.PERSONAL)) {
            throw new ProfileException(
                    "Los usuarios con cuenta personal no pueden registrar perfiles");
        } else if (existsByProfileName(dto.getUsername()))
            throw new ProfileException("Cuenta con este nombre ya existente");

        log.info("Registrando nuevo perfil {}", dto.getEmail());

        transactionTemplate.execute(
                status -> {
                    Profile profile = newProfileMapper.toEntity(dto);
                    profile.setPassword(passwordEncoder.encode(dto.getPassword()));
                    profile.setUser(user);

                    masterProfileRepository.save(profile);
                    return "Perfil registrado correctamente";
                });
    }

    @Override
    public void updateProfile(UpdateProfileDTO dto) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user =
                slaveUserRepository
                        .findByEmail(authentication.getName())
                        .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));
        if (existsByProfileName(dto.getUsername()))
            throw new ProfileException("Cuenta con este nombre ya existente");
        log.info("Actualizando nuevo perfil {}", dto.getEmail());

        transactionTemplate.execute(
                status -> {
                    Profile profile = updateProfileMapper.toEntity(dto);
                    profile.setPassword(passwordEncoder.encode(dto.getPassword()));
                    profile.setUser(user);

                    masterProfileRepository.save(profile);
                    return "Perfil actualizado correctamente";
                });
    }

    @Override
    public void deleteProfile(Profile profile) {
        masterProfileRepository.delete(profile);
    }

    public Profile findByNameOrEmail(String nameOrEmail) {
        boolean isEmail = nameOrEmail.contains("@");

        if (isEmail) {
            return slaveProfileRepository
                    .findByEmail(nameOrEmail)
                    .orElseThrow(() -> new ProfileException("Datos Invalidos"));
        } else {
            return slaveProfileRepository
                    .findByUsername(nameOrEmail)
                    .orElseThrow(() -> new ProfileException("Datos Invalidos"));
        }
    }

    public boolean existsByProfileName(String username) {
        return slaveProfileRepository.existsByUsername(username);
    }
}
