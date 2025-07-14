package org.kuenteco.backend.service.user;

import static org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials;

import java.io.IOException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.dto.auth.DeleteUserDTO;
import org.kuenteco.backend.dto.auth.UserDetailDTO;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.mapper.auth.UserDetailMapper;
import org.kuenteco.backend.repository.master.MasterUserRepository;
import org.kuenteco.backend.repository.slave.SlaveSubscriptionRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.kuenteco.backend.service.image.ImageService;
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
    private final SlaveSubscriptionRepository slaveSubscriptionRepository;

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

    @Override
    public UserDetailDTO getUserDetails() {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();
        if (role == RoleList.ROLE_PROFILE) {
            throw new UsernameNotFoundException("Endpoint solo disponible para usuarios");
        }
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado"));
        Subscription subscription =
                slaveSubscriptionRepository
                        .findFirstByUserOrderByIdDesc(user)
                        .orElseThrow(
                                () -> new UsernameNotFoundException("Subscripción no encontrada"));

        return userDetailMapper.toDto(user, subscription.getType());
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
