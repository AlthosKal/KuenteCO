package org.kuenteco.backend.config.jwt;

import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.enums.UserType;

public record AuthCredentials(
        String email,
        RoleList role
) {}
