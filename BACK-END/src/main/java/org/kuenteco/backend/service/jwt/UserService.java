package org.kuenteco.backend.service.jwt;

import org.kuenteco.backend.entity.master.MasterUser;
import org.kuenteco.backend.entity.slave.SlaveUser;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

public interface UserService extends UserDetailsService {
    UserDetails loadUserByUsername(String email) throws UsernameNotFoundException;

    SlaveUser findByUserName(String email);

    boolean existsByUserName(String email);

    void saveUser(MasterUser user);

    void deteleUser(MasterUser masterUser);

    void deletePendingEmail(String email);
    SlaveUser getUserDetails();
}
