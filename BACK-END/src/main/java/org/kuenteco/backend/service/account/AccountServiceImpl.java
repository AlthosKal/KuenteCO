package org.kuenteco.backend.service.account;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.dto.account.AccountDetailDTO;
import org.kuenteco.backend.dto.account.NewAccountDTO;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.entity.Account;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.entity.extra.Image;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.exception.exceptions.AccountException;
import org.kuenteco.backend.mapper.AccountDetailMapper;
import org.kuenteco.backend.mapper.ImageMapper;
import org.kuenteco.backend.mapper.NewAccountMapper;
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
    private Subscription masterSubscription;
    private final NewAccountMapper newAccountMapper;
    private final ImageMapper imageMapper;
    private final MasterUserRepository masterUserRepository;
    private final AccountDetailMapper accountDetailMapper;

    public List<AccountDetailDTO> getAccounts() {
        // Obtener el usuario autenticado
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        User user = slaveUserRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

        // Obtener las cuentas del usuario
        List<Account> account = slaveAccountRepository.findByUser(user);

        // Verificar si las cuentas están vacías o nulas
        if (account == null || account.isEmpty()) {
            throw new IllegalStateException("No tienes cuentas registradas");
        }

        // Devolver las cuentas del usuario
        return accountDetailMapper.toDto(account);
    }

    public void registerAccount(NewAccountDTO newAccountDTO, String username) {
        User user = masterUserRepository.findByEmail(username)
                .orElseThrow(() -> new AccountException("Usuario no encontrado"));

        if (existsByAccountName(newAccountDTO.getName()) && masterSubscription.getState() == State.INACTIVE)
            throw new AccountException("Necesitas tener una cuenta con una subscripción activa");

        if (existsByAccountName(newAccountDTO.getName()))
            throw new AccountException("Cuenta con este nombre ya existente");

        Account account = newAccountMapper.toAccount(newAccountDTO);
        account.setUser(user);

        masterAccountRepository.save(account);
    }

    public boolean existsByAccountName(String name) {
        return slaveAccountRepository.existsByName(name);
    }

    public void deleteAccount(Account account) {
        masterAccountRepository.delete(account);
    }

    @Override
    public ImageDTO saveImage(MultipartFile image, Account masterAccount, HttpServletResponse response) {
        try {
            // Verificar si ya tiene una imagen previa
            if (masterAccount.getUser() != null) {
                throw new RuntimeException(
                        "La cuenta ya tiene una imagen asociada. Utilice updateImage para actualizarla.");
            }

            // Subir la nueva imagen
            Image newImage = imageService.uploadImage(image);
            masterAccount.setImage(newImage);
            masterAccountRepository.save(masterAccount);

            return imageMapper.toDTO(newImage);
        } catch (IOException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            throw new RuntimeException("Error al guardar la imagen de la cuenta: " + e.getMessage());
        }
    }

    @Override
    public ImageDTO updateImage(MultipartFile image, Account account, HttpServletResponse response) {
        try {
            // Verificar si tiene imagen para actualizar
            if (account.getImage() == null) {
                throw new RuntimeException("La cuenta no tiene una imagen para actualizar.");
            }

            // Eliminar la imagen anterior
            imageService.deleteImage(account.getImage());

            // Subir la nueva imagen
            Image newImage = imageService.uploadImage(image);
            account.setImage(newImage);
            masterAccountRepository.save(account);

            return imageMapper.toDTO(newImage);
        } catch (IOException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            throw new RuntimeException("Error al actualizar la imagen de la cuenta: " + e.getMessage());
        }
    }

    @Override
    public void deleteImage(Account account, HttpServletResponse response) {
        try {
            // Verificar si tiene imagen para eliminar
            if (account.getImage() == null) {
                throw new RuntimeException("La cuenta no tiene una imagen para eliminar.");
            }

            // Eliminar la imagen
            Image imageToDelete = account.getImage();
            account.setImage(null);
            masterAccountRepository.save(account);

            imageService.deleteImage(imageToDelete);

            response.setStatus(HttpServletResponse.SC_OK);
        } catch (IOException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            throw new RuntimeException("Error al eliminar la imagen de la cuenta: " + e.getMessage());
        }
    }
}
