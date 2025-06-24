package org.kuenteco.backend.jwt;

import java.util.Collection;
import java.util.Collections;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.repository.slave.SlaveProfileRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthenticatedUser implements UserDetailsService {
    private final SlaveUserRepository slaveUserRepository;
    private final SlaveProfileRepository slaveProfileRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        log.debug("Buscando usuario/perfil con email: {}", email);

        // Primero intentar buscar en Users
        Optional<User> userOpt = slaveUserRepository.findByEmail(email);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            log.debug("Usuario encontrado: {}", email);
            return createUserDetailsFromUser(user);
        }

        // Si no se encuentra, buscar en Profiles
        Optional<Profile> profileOpt = slaveProfileRepository.findByEmail(email);
        if (profileOpt.isPresent()) {
            Profile profile = profileOpt.get();
            log.debug("Perfil encontrado: {}", email);
            return createUserDetailsFromProfile(profile);
        }

        log.error("Usuario/Perfil no encontrado: {}", email);
        throw new UsernameNotFoundException("Usuario no encontrado: " + email);
    }

    private UserDetails createUserDetailsFromUser(User user) {
        return org.springframework.security.core.userdetails.User.builder()
                .username(user.getEmail())
                .password(user.getPassword())
                .authorities(getUserAuthorities(user))
                .accountExpired(false)
                .accountLocked(false)
                .credentialsExpired(false)
                .disabled(false)
                .build();
    }

    private UserDetails createUserDetailsFromProfile(Profile profile) {
        return org.springframework.security.core.userdetails.User.builder()
                .username(profile.getEmail())
                .password(profile.getPassword())
                .authorities(getProfileAuthorities(profile))
                .accountExpired(false)
                .accountLocked(false)
                .credentialsExpired(false)
                .disabled(false)
                .build();
    }

    private Collection<? extends GrantedAuthority> getUserAuthorities(User user) {
        if (user.getRole() != null && user.getRole().getName() != null) {
            // El enum RoleList ya incluye el prefijo ROLE_, no necesitamos agregarlo
            String roleName = user.getRole().getName().toString();
            return Collections.singletonList(new SimpleGrantedAuthority(roleName));
        }
        // Rol por defecto para usuarios sin rol
        return Collections.singletonList(new SimpleGrantedAuthority(RoleList.ROLE_USER.name()));
    }

    private Collection<? extends GrantedAuthority> getProfileAuthorities(Profile profile) {
        if (profile.getRole() != null && profile.getRole().getName() != null) {
            // El enum RoleList ya incluye el prefijo ROLE_, no necesitamos agregarlo
            String roleName = profile.getRole().getName().toString();
            return Collections.singletonList(new SimpleGrantedAuthority(roleName));
        }
        // Rol por defecto para profiles sin rol específico
        return Collections.singletonList(new SimpleGrantedAuthority(RoleList.ROLE_PROFILE.name()));
    }
}
