package org.kuenteco.backend.service.auth;

import java.io.IOException;
import org.kuenteco.backend.dto.auth.DeleteUserDTO;
import org.kuenteco.backend.dto.auth.UserDetailDTO;
import org.kuenteco.backend.entity.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

public interface UserService extends UserDetailsService {
    UserDetails loadUserByEmail(String email) throws UsernameNotFoundException;

    User findByNameOrEmail(String nameOrEmail);

    boolean existsByUserName(String username);

    boolean existsByUserEmail(String email);

    void saveUser(User user);

    void deletePendingEmail(String email);

    UserDetailDTO getUserDetailsDTO();

    void deteleUser(DeleteUserDTO deleteUserDTO) throws IOException;
}
