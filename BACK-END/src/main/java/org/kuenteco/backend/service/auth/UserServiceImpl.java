package org.kuenteco.backend.service.auth;

import java.io.IOException;
import java.util.Collections;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.auth.DeleteUserDTO;
import org.kuenteco.backend.dto.auth.UserDetailDTO;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.mapper.auth.UserDetailMapper;
import org.kuenteco.backend.repository.master.MasterUserRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.kuenteco.backend.service.image.auth.UserImageService;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final SlaveUserRepository slaveUserRepository;
    private final MasterUserRepository masterUserRepository;
    private final UserImageService imageService;
    private final UserDetailMapper userDetailMapper;

    @Override
    public UserDetails loadUserByUsername(String nameOrEmail) throws UsernameNotFoundException {
        User user;
        boolean isEmail = nameOrEmail.contains("@");

        if (isEmail) {
            user =
                    slaveUserRepository
                            .findByEmail(nameOrEmail)
                            .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
        } else {
            user =
                    slaveUserRepository
                            .findByUsername(nameOrEmail)
                            .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
        }
        SimpleGrantedAuthority authority =
                new SimpleGrantedAuthority(user.getRole().getName().toString());

        return new org.springframework.security.core.userdetails.User(
                user.getEmail(), user.getPassword(), Collections.singleton(authority));
    }

    @Override
    public UserDetails loadUserByEmail(String email) throws UsernameNotFoundException {
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
        SimpleGrantedAuthority authority =
                new SimpleGrantedAuthority(user.getRole().getName().toString());

        return new org.springframework.security.core.userdetails.User(
                user.getEmail(), user.getPassword(), Collections.singleton(authority));
    }

    @Override
    public User findByNameOrEmail(String nameOrEmail) {
        boolean isEmail = nameOrEmail.contains("@");

        if (isEmail) {
            return slaveUserRepository
                    .findByEmail(nameOrEmail)
                    .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
        } else {
            return slaveUserRepository
                    .findByUsername(nameOrEmail)
                    .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
        }
    }

    @Override
    public boolean existsByUserName(String username) {
        return slaveUserRepository.existsByUsername(username);
    }

    @Override
    public boolean existsByUserEmail(String email) {
        return slaveUserRepository.existsByEmail(email);
    }

    @Override
    public void saveUser(User user) {
        masterUserRepository.save(user);
    }

    @Override
    public void deletePendingEmail(String email) {
        User user = new User();
        if (user.getState() == State.PENDING) masterUserRepository.removeUserByEmail(email);
    }

    public User getUserDetails() {
        String nameOrEmail = SecurityContextHolder.getContext().getAuthentication().getName();

        return findByNameOrEmail(nameOrEmail);
    }

    @Override
    public UserDetailDTO getUserDetailsDTO() {
        User user = getUserDetails();
        return userDetailMapper.toDto(user);
    }

    @Override
    public void deteleUser(DeleteUserDTO deleteUserDTOid) throws IOException {
        User user =
                slaveUserRepository
                        .findById(deleteUserDTOid.getId())
                        .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado"));

        if (user.getImage() != null) {
            imageService.removeImage(user.getImage());
        }

        masterUserRepository.delete(user);
    }
}
