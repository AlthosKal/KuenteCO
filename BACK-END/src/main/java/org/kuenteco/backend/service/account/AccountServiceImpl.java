package org.kuenteco.backend.service.account;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.dto.account.AccountDetailDTO;
import org.kuenteco.backend.dto.account.NewAccountDTO;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.entity.master.MasterAccount;
import org.kuenteco.backend.entity.master.MasterSubscription;
import org.kuenteco.backend.entity.master.MasterUser;
import org.kuenteco.backend.entity.master.extra.MasterImage;
import org.kuenteco.backend.entity.slave.SlaveAccount;
import org.kuenteco.backend.entity.slave.SlaveUser;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.exception.exceptions.AccountException;
import org.kuenteco.backend.mapper.dto.AccountDetailMapper;
import org.kuenteco.backend.mapper.dto.ImageMapper;
import org.kuenteco.backend.mapper.dto.NewAccountMapper;
import org.kuenteco.backend.repository.master.MasterAccountRepository;
import org.kuenteco.backend.repository.master.MasterUserRepository;
import org.kuenteco.backend.repository.slave.SlaveAccountRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.kuenteco.backend.service.image.ImageService;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AccountServiceImpl implements AccountService {
    private final MasterAccountRepository masterAccountRepository;
    private final SlaveAccountRepository slaveAccountRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final ImageService imageService;
    private MasterSubscription masterSubscription;
    private final NewAccountMapper newAccountMapper;
    private final ImageMapper imageMapper;
    private final MasterUserRepository masterUserRepository;
    private final AccountDetailMapper accountDetailMapper;

    public List<AccountDetailDTO> getAccounts() {
        // Obtener el usuario autenticado
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        SlaveUser user = slaveUserRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

        // Obtener las cuentas del usuario
        List<SlaveAccount> slaveAccount = slaveAccountRepository.findBySlaveUser(user);

        // Verificar si las cuentas están vacías o nulas
        if (slaveAccount == null || slaveAccount.isEmpty()) {
            throw new IllegalStateException("No tienes cuentas registradas");
        }

        // Devolver las cuentas del usuario
        return accountDetailMapper.toDto(slaveAccount);
    }

    public void registerAccount(NewAccountDTO newAccountDTO, String username) {
        MasterUser user = masterUserRepository.findByEmail(username)
                .orElseThrow(() -> new AccountException("Usuario no encontrado"));

        if (existsByAccountName(newAccountDTO.getName()) && masterSubscription.getState() == State.INACTIVE)
            throw new AccountException("Necesitas tener una cuenta con una subscripción activa");

        if (existsByAccountName(newAccountDTO.getName()))
            throw new AccountException("Cuenta con este nombre ya existente");

        MasterAccount account = newAccountMapper.toMasterAccount(newAccountDTO);
        account.setMasterUser(user);

        masterAccountRepository.save(account);
    }

    public boolean existsByAccountName(String name) {
        return slaveAccountRepository.existsByName(name);
    }

    public void deleteAccount(MasterAccount account) {
        masterAccountRepository.delete(account);
    }

    @Override
    public ImageDTO saveImage(MultipartFile image, MasterAccount masterAccount, HttpServletResponse response) {
        try {
            // Verificar si ya tiene una imagen previa
            if (masterAccount.getMasterImage() != null) {
                throw new RuntimeException("La cuenta ya tiene una imagen asociada. Utilice updateImage para actualizarla.");
            }

            // Subir la nueva imagen
            MasterImage masterImage = imageService.uploadImage(image);
            masterAccount.setMasterImage(masterImage);
            masterAccountRepository.save(masterAccount);

            return imageMapper.toDTO(masterImage);
        } catch (IOException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            throw new RuntimeException("Error al guardar la imagen de la cuenta: " + e.getMessage());
        }
    }

    @Override
    public ImageDTO updateImage(MultipartFile image, MasterAccount masterAccount, HttpServletResponse response) {
        try {
            // Verificar si tiene imagen para actualizar
            if (masterAccount.getMasterImage() == null) {
                throw new RuntimeException("La cuenta no tiene una imagen para actualizar.");
            }

            // Eliminar la imagen anterior
            imageService.deleteImage(masterAccount.getMasterImage());

            // Subir la nueva imagen
            MasterImage masterImage = imageService.uploadImage(image);
            masterAccount.setMasterImage(masterImage);
            masterAccountRepository.save(masterAccount);

            return imageMapper.toDTO(masterImage);
        } catch (IOException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            throw new RuntimeException("Error al actualizar la imagen de la cuenta: " + e.getMessage());
        }
    }

    @Override
    public void deleteImage(MasterAccount masterAccount, HttpServletResponse response) {
        try {
            // Verificar si tiene imagen para eliminar
            if (masterAccount.getMasterImage() == null) {
                throw new RuntimeException("La cuenta no tiene una imagen para eliminar.");
            }

            // Eliminar la imagen
            MasterImage imageToDelete = masterAccount.getMasterImage();
            masterAccount.setMasterImage(null);
            masterAccountRepository.save(masterAccount);

            imageService.deleteImage(imageToDelete);

            response.setStatus(HttpServletResponse.SC_OK);
        } catch (IOException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            throw new RuntimeException("Error al eliminar la imagen de la cuenta: " + e.getMessage());
        }
    }
}
