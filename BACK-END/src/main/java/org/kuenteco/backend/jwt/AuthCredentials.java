package org.kuenteco.backend.jwt;

import org.kuenteco.backend.enums.RoleList;

public record AuthCredentials(String email, RoleList role) {}
