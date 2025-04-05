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
    public UserDetails loadUserByUsername(String nameOrEmail) throws UsernameNotFoundException {
        SlaveUser slaveUser;
        boolean isEmail = nameOrEmail.contains("@");

        if (isEmail) {
            slaveUser = slaveUserRepository.findByEmail(nameOrEmail)
                    .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
        } else {
            slaveUser = slaveUserRepository.findByName(nameOrEmail)
                    .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
        }

        MasterUser user = userMapper.slaveToMaster(slaveUser);
        SimpleGrantedAuthority authority = new SimpleGrantedAuthority(user.getRole().getName().toString());

        return new org.springframework.security.core.userdetails.User(user.getEmail(), user.getPassword(),
                Collections.singleton(authority));
    }

    @Override
    public SlaveUser findByNameOrEmail(String nameOrEmail) {
        boolean isEmail = nameOrEmail.contains("@");

        if (isEmail) {
            return slaveUserRepository.findByEmail(nameOrEmail)
                    .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
        } else {
            return slaveUserRepository.findByName(nameOrEmail)
                    .orElseThrow(() -> new UsernameNotFoundException("Datos Invalidos"));
        }
    }

    @Override
    public boolean existsByUserName(String name) {
        return slaveUserRepository.existsByName(name);
    }

    @Override
    public boolean existsByUserEmail(String email){
        return slaveUserRepository.existsByEmail(email);
    }

    @Override
    public void saveUser(MasterUser user) {
        masterUserRepository.save(user);
    }

    @Override
    public void deletePendingEmail(String email) {
        MasterUser user = new MasterUser();
        if (user.getAccountState() == State.PENDING)
            masterUserRepository.removeMasterUserByEmail(email);
    }

    @Override
    public SlaveUser getUserDetails() {
        String nameOrEmail = SecurityContextHolder.getContext().getAuthentication().getName();

        return findByNameOrEmail(nameOrEmail);
    }

    public void deteleUser(MasterUser masterUser) {
        masterUserRepository.deleteById(masterUser.getId());
    }
}
