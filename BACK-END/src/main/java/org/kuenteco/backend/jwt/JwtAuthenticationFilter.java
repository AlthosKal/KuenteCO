package org.kuenteco.backend.jwt;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.service.auth.TokenBlacklistService;
import org.kuenteco.backend.service.auth.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.util.WebUtils;

import java.io.IOException;
import java.util.Date;

@NoArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    @Autowired
    private JwtUtil jwtUtil;
    @Autowired
    private UserService userService;
    @Autowired
    private TokenBlacklistService tokenBlacklistService;

    private static final Logger log = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String email = null;
        String jwt = null;
        try {
            jwt = getJWT(request);
            if (jwt != null) {
                // Verificar la expiración del JWT
                if (tokenBlacklistService.isBlacklisted(jwt)) {
                    response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Token invalidado");
                    return;
                }
                email = jwtUtil.extractEmail(jwt);
            }

            if (email != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                UserDetails userDetails = userService.loadUserByUsername(email);

                if (jwtUtil.validateToken(jwt, userDetails)) {
                    UsernamePasswordAuthenticationToken usernamePasswordAuthenticationToken = new UsernamePasswordAuthenticationToken(
                            userDetails, null, userDetails.getAuthorities());
                    usernamePasswordAuthenticationToken
                            .setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(usernamePasswordAuthenticationToken);
                }
            }
        } catch (io.jsonwebtoken.ExpiredJwtException e) {
            log.error(
                    "JWT expired at {}. Current time: {}, a difference of {} milliseconds. Allowed clock skew: {} milliseconds.",
                    e.getClaims().getExpiration(), new Date(),
                    new Date().getTime() - e.getClaims().getExpiration().getTime(), 0);
            // No establecer autenticación, dejará que el endpoint protegido devuelva 401
        } catch (Exception e) {
            log.error("Error processing JWT: {}", e.getMessage());
        }
        filterChain.doFilter(request, response);
    }

    private String getJWT(HttpServletRequest request) {
        // Primero intentar obtener de header Authorization (Bearer token)
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }

        // Si no está en el header, intentar obtener de cookie
        Cookie cookie = WebUtils.getCookie(request, "jwt");
        return cookie != null ? cookie.getValue() : null;
    }
}
