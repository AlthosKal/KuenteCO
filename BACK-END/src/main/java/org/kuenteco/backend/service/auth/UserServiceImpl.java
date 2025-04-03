package org.kuenteco.backend.service.auth;

import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.master.MasterUser;
import org.kuenteco.backend.entity.slave.SlaveUser;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.mapper.entity.UserMapper;
import org.kuenteco.backend.repository.master.MasterUserRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
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
    private SlaveUserRepository slaveUserRepository;
    private MasterUserRepository masterUserRepository;
    private UserMapper userMapper;

    @Autowired
    public UserServiceImpl(SlaveUserRepository slaveUserRepository, MasterUserRepository masterUserRepository,
            UserMapper userMapper) {
        this.slaveUserRepository = slaveUserRepository;
        this.masterUserRepository = masterUserRepository;
        this.userMapper = userMapper;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        SlaveUser slaveUser = slaveUserRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
        MasterUser user = userMapper.slaveToMaster(slaveUser);
        SimpleGrantedAuthority authority = new SimpleGrantedAuthority(user.getRole().getName().toString());

        return new org.springframework.security.core.userdetails.User(user.getEmail(), user.getPassword(),
                Collections.singleton(authority));
    }

    @Override
    public SlaveUser findByUserName(String email) {
        SlaveUser slaveUser = slaveUserRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));

        return slaveUser = slaveUserRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
    }

    public boolean existsByUserName(String email) {
        return slaveUserRepository.existsByEmail(email);
    }

    public void saveUser(MasterUser user) {
        masterUserRepository.save(user);
    }

    public void deteleUser(MasterUser masterUser) {
        masterUserRepository.deleteById(masterUser.getId());
    }

    public void deletePendingEmail(String email) {
        MasterUser user = new MasterUser();
        if (user.getAccountState() == State.PENDING)
            masterUserRepository.removeMasterUserByEmail(email);
    }

    public SlaveUser getUserDetails() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();

        return findByUserName(email);
    }

}
