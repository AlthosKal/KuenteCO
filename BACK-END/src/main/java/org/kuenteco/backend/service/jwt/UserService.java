package org.kuenteco.backend.service.jwt;

import org.kuenteco.backend.entity.User;
import org.springframework.security.core.userdetails.UserDetailsService;

public interface UserService extends UserDetailsService {
    User getUserDetails();
}
