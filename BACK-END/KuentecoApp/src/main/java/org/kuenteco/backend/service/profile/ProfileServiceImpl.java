package org.kuenteco.backend.service.profile;

import static org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.Transactional;
import java.io.IOException;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.config.jwt.JwtUtil;
import org.kuenteco.backend.dto.auth.LoginDTO;
import org.kuenteco.backend.dto.auth.TokenResponseDTO;
import org.kuenteco.backend.dto.profile.ChangePasswordDTO;
import org.kuenteco.backend.dto.profile.NewProfileDTO;
import org.kuenteco.backend.dto.profile.ProfileDetailDTO;
import org.kuenteco.backend.dto.profile.UpdateProfileDTO;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.entity.Role;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.entity.extra.Image;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.SubscriptionType;
import org.kuenteco.backend.enums.UserType;
import org.kuenteco.backend.exception.exceptions.AuthException;
import org.kuenteco.backend.exception.exceptions.ProfileException;
import org.kuenteco.backend.mapper.profile.NewProfileMapper;
import org.kuenteco.backend.mapper.profile.ProfileDetailMapper;
import org.kuenteco.backend.mapper.profile.UpdateProfileMapper;
import org.kuenteco.backend.repository.master.MasterProfileRepository;
import org.kuenteco.backend.repository.master.MasterRoleRepository;
import org.kuenteco.backend.repository.slave.SlaveProfileRepository;
import org.kuenteco.backend.repository.slave.SlaveRoleRepository;
import org.kuenteco.backend.repository.slave.SlaveSubscriptionRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.kuenteco.backend.service.auth.CookieService;
import org.kuenteco.backend.service.auth.TokenBlacklistService;
import org.kuenteco.backend.service.image.ImageService;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.multipart.MultipartFile;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProfileServiceImpl implements ProfileService {
    private final TokenBlacklistService tokenBlacklistService;
    private final MasterRoleRepository masterRoleRepository;
    private final SlaveRoleRepository slaveRoleRepository;
    private final MasterProfileRepository masterProfileRepository;
    private final SlaveProfileRepository slaveProfileRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final NewProfileMapper newProfileMapper;
    private final UpdateProfileMapper updateProfileMapper;
    private final ProfileDetailMapper profileDetailMapper;
    private final AuthenticationManagerBuilder authenticationManagerBuilder;
    private final TransactionTemplate transactionTemplate;
    private final ImageService imageService;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;
    private final CookieService cookieService;
    private final SlaveSubscriptionRepository slaveSubscriptionRepository;

    @Override
    public TokenResponseDTO authenticate(LoginDTO dto, HttpServletResponse response) {
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

        return new TokenResponseDTO(jwt, "PROFILE");
    }

    @Override
    public Object getProfiles() {
        // Obtener el usuario autenticado
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new ProfileException("Endpoint solo disponible para usuarios");
        }
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new ProfileException("Usuario no encontrado"));

        // Obtener las cuentas del usuario
        List<Profile> profile = slaveProfileRepository.findByUser(user);

        // Verificar si las cuentas están vacías o nulas
        if (profile == null || profile.isEmpty()) {
            return "No tienes cuentas registradas";
        }

        // Devolver las cuentas del usuario
        return profileDetailMapper.toDtoList(profile);
    }

    @Override
    public Object getProfileById(Integer id) {
        // Obtener el usuario autenticado
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        if (role == RoleList.ROLE_PROFILE) {
            throw new ProfileException("Endpoint solo disponible para usuarios");
        }
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new ProfileException("Usuario no encontrado"));

        // Obtener las cuentas del usuario
        Profile profile = slaveProfileRepository.findByUserAndId(user, id).orElseThrow(()-> new ProfileException("Perfil no encontrado"));

        // Devolver las cuentas del usuario
        return profileDetailMapper.toDto(profile);
    }



    @Override
    public ProfileDetailDTO getProfileDetails() {
        Profile profile = getDetails();
        return profileDetailMapper.toDto(profile);
    }

    @Override
    public void registerProfile(NewProfileDTO dto) {
        // Obtener el usuario autenticado
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList roleList = credentials.role();

        if (roleList == RoleList.ROLE_PROFILE) {
            throw new ProfileException("Endpoint solo disponible para usuarios");
        } else if (Objects.equals(email, dto.getEmail())) {
            throw new ProfileException("No puedes registrar un perfil con tú correo");
        }
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

        if (user.getType().equals(UserType.PERSONAL)) {
            throw new ProfileException(
                    "Los usuarios con cuenta personal no pueden registrar perfiles");
        } else if (existsByProfileName(dto.getUsername(), user))
            throw new ProfileException("Cuenta con este nombre ya existente");

        Subscription subscription =
                slaveSubscriptionRepository
                        .findByUser(user)
                        .orElseThrow(
                                () -> new IllegalArgumentException("Subscription no encontrada"));
        if (slaveProfileRepository.count() > 3
                && subscription.getType() == SubscriptionType.BASIC) {
            throw new ProfileException(
                    "No puedes registrar mas de 3 perfiles, tienes que actualizar tu plan de subscripción");
        }
        log.info("Registrando nuevo perfil {}", dto.getEmail());

        Role role =
                slaveRoleRepository
                        .findByName(RoleList.ROLE_PROFILE)
                        .orElseThrow(() -> new AuthException("Role no encontrado"));

        // Asegurar que el rol existe en la base de datos maestra
        Role masterRole =
                slaveRoleRepository
                        .findByName(RoleList.ROLE_PROFILE)
                        .orElseGet(() -> masterRoleRepository.save(role));
        transactionTemplate.execute(
                status -> {
                    Profile profile = newProfileMapper.toEntity(dto);
                    profile.setPassword(passwordEncoder.encode(dto.getPassword()));
                    profile.setRole(masterRole);
                    profile.setUser(user);

                    masterProfileRepository.save(profile);
                    return "Perfil registrado correctamente";
                });
    }

    @Override
    @Transactional
    public void updateProfile(UpdateProfileDTO dto, MultipartFile file) throws IOException {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();

        User user = slaveUserRepository
                .findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

        Profile profile = slaveProfileRepository
                .findByUserAndId(user, dto.getId())
                .orElseThrow(() -> new ProfileException("Perfil no encontrado"));

        // Validar email único
        if (dto.getEmail() != null &&
                !dto.getEmail().equalsIgnoreCase(profile.getEmail()) &&
                slaveProfileRepository.existsByEmail(dto.getEmail())) {
            throw new ProfileException("El correo ya está en uso por otro perfil");
        }

        // Actualizar datos básicos
        updateProfileMapper.toEntity(dto, profile);

        // 1️⃣ Eliminar imagen si se solicita
        if (dto.isRemoveImage() && profile.getImage() != null) {
            imageService.removeImage(profile.getImage());
            profile.setImage(null);
        }

        // 2️⃣ Subir nueva imagen si viene archivo
        if (file != null && !file.isEmpty()) {
            Image oldImage = profile.getImage();
            Image newImage = imageService.uploadImage(file);
            profile.setImage(newImage);

            // Si había una imagen previa distinta, la borramos
            if (oldImage != null) {
                imageService.removeImage(oldImage);
            }
        }

        masterProfileRepository.save(profile);
    }


    @Override
    @Transactional
    public String changePassword(ChangePasswordDTO dto) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        // Buscar directamente en la base de datos maestra
        if (dto.getNewPassword().equals(dto.getConfirmPassword())) {
            Profile profile =
                    slaveProfileRepository
                            .findByEmail(email)
                            .orElseThrow(() -> new AuthException("Perfil no encontrado"));

            profile.setPassword(passwordEncoder.encode(dto.getNewPassword()));
            masterProfileRepository.save(profile);

            return "Contraseña actualizada correctamente";
        }

        return "Las contraseñas no coinciden";
    }

    @Override
    public void logout(HttpServletRequest request, HttpServletResponse response) {
        String token = jwtUtil.resolveToken(request);

        if (token == null) {
            throw new AuthException("Token no proporcionado");
        }
        // 1. Invalidar el token
        tokenBlacklistService.addToBlacklist(token);

        // 2. Limpiar la cookie
        cookieService.deleteCookie("jwt", response);

        // 3. Limpiar el contexto de seguridad
        SecurityContextHolder.clearContext();
    }

    @Override
    public void deleteProfile(Integer id) {
        masterProfileRepository.deleteById(id);
    }

    private Profile findByNameOrEmail(String nameOrEmail) {
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

    private Profile getDetails() {
        String nameOrEmail = SecurityContextHolder.getContext().getAuthentication().getName();

        return findByNameOrEmail(nameOrEmail);
    }

    public boolean existsByProfileName(String username, User user) {
        return slaveProfileRepository.existsByUsernameAndUser(username, user);
    }
}
