package org.kuenteco.backend.service.auth;

import jakarta.servlet.http.HttpServletResponse;

public interface CookieService {
    void addHttpOnlyCookie(String name, String value, int maxAge, HttpServletResponse response);
    void deleteCookie(String name, HttpServletResponse response);
}
