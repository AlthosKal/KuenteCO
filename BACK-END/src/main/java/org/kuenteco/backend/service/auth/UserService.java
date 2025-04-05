package org.kuenteco.backend.service.auth;

import org.kuenteco.backend.entity.master.MasterUser;
import org.kuenteco.backend.entity.slave.SlaveUser;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

public interface UserService extends UserDetailsService {
    UserDetails loadUserByUsername(String nameOrEmail) throws UsernameNotFoundException;
    SlaveUser findByNameOrEmail(String nameOrEmail);
    boolean existsByUserName(String name);
    boolean existsByUserEmail(String email);
    void saveUser(MasterUser user);
    void deletePendingEmail(String email);
    SlaveUser getUserDetails();
}
