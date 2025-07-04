package org.kuenteco.backend.service.user;

import java.io.IOException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.auth.DeleteUserDTO;
import org.kuenteco.backend.dto.auth.UserDetailDTO;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.mapper.auth.UserDetailMapper;
import org.kuenteco.backend.repository.master.MasterUserRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.kuenteco.backend.service.image.ImageService;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final SlaveUserRepository slaveUserRepository;
    private final MasterUserRepository masterUserRepository;
    private final ImageService imageService;
    private final UserDetailMapper userDetailMapper;

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
    public void deletePendingEmail(String email) {
        User user = new User();
        if (user.getState() == State.PENDING) masterUserRepository.removeUserByEmail(email);
    }

    private User getDetails() {
        String nameOrEmail = SecurityContextHolder.getContext().getAuthentication().getName();

        return findByNameOrEmail(nameOrEmail);
    }

    @Override
    public UserDetailDTO getUserDetails() {
        User user = getDetails();
        return userDetailMapper.toDto(user);
    }

    @Override
    public void deleteUser(DeleteUserDTO deleteUserDTOid) throws IOException {
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
