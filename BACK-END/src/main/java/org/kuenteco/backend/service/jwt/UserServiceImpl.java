package org.kuenteco.backend.service.jwt;

import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.repository.UserRepository;
import lombok.NoArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
@NoArgsConstructor
public class UserServiceImpl implements UserService {
    private UserRepository userRepository;

    @Autowired
    public UserServiceImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + email));
        SimpleGrantedAuthority authority = new SimpleGrantedAuthority(user.getRole().getName().toString());

        return new org.springframework.security.core.userdetails.User(user.getEmail(), user.getPassword(),
                Collections.singleton(authority));
    }

    public User findByUserName(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + email));
    }

    public boolean existsByUserName(String email) {
        return userRepository.existsByEmail(email);
    }

    public void saveUser(User user) {
        userRepository.save(user);
    }

    public User getUserDetails() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();

        return findByUserName(email);
    }

}
