package org.kuenteco.backend.service.user;

import java.io.IOException;
import org.kuenteco.backend.dto.auth.UserDetailDTO;
import org.kuenteco.backend.entity.User;

public interface UserService {
    User findByNameOrEmail(String nameOrEmail);

    boolean existsByUserName(String username);

    boolean existsByUserEmail(String email);

    void deletePendingEmail(String email);

    UserDetailDTO getUserDetails();

    void deleteUser() throws IOException;
}
