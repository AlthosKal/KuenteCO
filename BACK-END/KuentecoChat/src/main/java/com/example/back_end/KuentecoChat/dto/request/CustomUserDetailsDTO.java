package com.example.back_end.KuentecoChat.dto.request;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

public class CustomUserDetailsDTO implements UserDetails {

    private final String username;
    private String password; // Typically you wouldn't need the password if JWT is used for authentication
    private List<SimpleGrantedAuthority> authorities;

    public CustomUserDetailsDTO(String username, List<SimpleGrantedAuthority> authorities) {
        this.username = username;
        // ✅ MEJORA: Protección contra null
        this.authorities = authorities != null ? authorities : List.of();
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return null; // No password is needed if using JWT
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}