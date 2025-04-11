package org.kuenteco.backend.service.auth;

import org.kuenteco.backend.dto.auth.UserDetailDTO;
import org.kuenteco.backend.entity.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

public interface UserService extends UserDetailsService {
    UserDetails loadUserByEmail(String email) throws UsernameNotFoundException;

    User findByUserName(String name);

    User findByEmail(String email);

    User findByNameOrEmail(String nameOrEmail);

    boolean existsByUserName(String name);

    boolean existsByUserEmail(String email);

    void saveUser(User user);

    void deletePendingEmail(String email);

    UserDetailDTO getUserDetailsDTO();

    void deteleUser(User user);
}
