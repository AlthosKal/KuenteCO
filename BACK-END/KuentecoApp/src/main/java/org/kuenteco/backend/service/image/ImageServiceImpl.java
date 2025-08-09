package org.kuenteco.backend.service.image;

import static org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.Transactional;
import java.io.IOException;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.entity.Profile;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.entity.extra.Image;
import org.kuenteco.backend.enums.RoleList;
import org.kuenteco.backend.exception.exceptions.ImageException;
import org.kuenteco.backend.mapper.image.ImageMapper;
import org.kuenteco.backend.repository.master.MasterImageRepository;
import org.kuenteco.backend.repository.master.MasterProfileRepository;
import org.kuenteco.backend.repository.master.MasterUserRepository;
import org.kuenteco.backend.repository.slave.SlaveProfileRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class ImageServiceImpl implements ImageService {
    private final MasterProfileRepository masterProfileRepository;
    private final SlaveProfileRepository slaveProfileRepository;
    private final MasterUserRepository masterUserRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final CloudinaryService cloudinaryService;
    private final MasterImageRepository masterImageRepository;
    private final ImageMapper imageMapper;

    @Override
    @Transactional
    public ImageDTO saveImage(MultipartFile image) throws IOException {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        return switch (role) {
            case ROLE_USER -> {
                User user =
                        slaveUserRepository
                                .findByEmail(email)
                                .orElseThrow(() -> new ImageException("Usuario no encontrado"));
                // Verificar si ya tiene una imagen previa
                if (user.getImage() != null) {
                    throw new ImageException("El usuario ya tiene una imagen de perfil");
                }

                // Subir la nueva imagen
                Image newImage = uploadImage(image);
                user.setImage(newImage);
                masterUserRepository.save(user);

                yield imageMapper.toDTO(newImage);
            }
            case ROLE_PROFILE -> {
                Profile profile =
                        slaveProfileRepository
                                .findByEmail(email)
                                .orElseThrow(() -> new ImageException("Perfil no encontrado"));
                // Verificar si ya tiene una imagen previa
                if (profile.getImage() != null) {
                    throw new ImageException(
                            "El perfil ya tiene una imagen de perfil. Utilice updateImage para actualizarla.");
                }

                // Subir la nueva imagen
                Image newImage = uploadImage(image);
                profile.setImage(newImage);
                masterProfileRepository.save(profile);

                yield imageMapper.toDTO(newImage);
            }
        };
    }

    @Override
    @Transactional
    public ImageDTO updateImage(MultipartFile image) throws IOException {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        return switch (role) {
            case ROLE_USER -> {
                User user =
                        slaveUserRepository
                                .findByEmail(email)
                                .orElseThrow(() -> new ImageException("Usuario no encontrado"));
                if (user.getImage() == null) {
                    throw new ImageException(
                            "El usuario no tiene una imagen de perfil para actualizar.");
                }

                Image oldImage = user.getImage();
                Image newImage = null;

                // Subimos la nueva imagen
                newImage = uploadImage(image);

                // Actualizamos la referencia del usuario
                user.setImage(newImage);
                masterUserRepository.save(user);

                // Removemos la imagen antigua
                removeImage(oldImage);

                yield imageMapper.toDTO(newImage);
            }
            case ROLE_PROFILE -> {
                Profile profile =
                        slaveProfileRepository
                                .findByEmail(email)
                                .orElseThrow(() -> new ImageException("Perfil no encontrado"));
                if (profile.getImage() == null) {
                    throw new ImageException(
                            "El perfil no tiene una imagen de perfil para actualizar.");
                }

                Image oldImage = profile.getImage();
                Image newImage = null;

                // Subimos la nueva imagen
                newImage = uploadImage(image);

                // Actualizamos la referencia del usuario
                profile.setImage(newImage);
                masterProfileRepository.save(profile);

                // Removemos la imagen antigua
                removeImage(oldImage);

                yield imageMapper.toDTO(newImage);
            }
        };
    }

    @Override
    @Transactional
    public void deleteImage(HttpServletResponse response) throws IOException {

        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        RoleList role = credentials.role();

        switch (role) {
            case ROLE_USER -> {
                User user =
                        slaveUserRepository
                                .findByEmail(email)
                                .orElseThrow(() -> new ImageException("Usuario no encontrado"));
                // Verificar si tiene imagen para eliminar
                if (user.getImage() == null) {
                    throw new ImageException(
                            "El usuario no tiene una imagen de perfil para eliminar.");
                }

                // Eliminar la imagen
                Image imageToDelete = user.getImage();
                user.setImage(null);
                masterUserRepository.save(user);

                removeImage(imageToDelete);

                response.setStatus(HttpServletResponse.SC_OK);
            }
            case ROLE_PROFILE -> {
                Profile profile =
                        slaveProfileRepository
                                .findByEmail(email)
                                .orElseThrow(() -> new ImageException("Perfil no encontrado"));
                // Verificar si tiene imagen para eliminar
                if (profile.getImage() == null) {
                    throw new ImageException(
                            "El perfil no tiene una imagen de perfil para eliminar.");
                }

                // Eliminar la imagen
                Image imageToDelete = profile.getImage();
                profile.setImage(null);
                masterProfileRepository.save(profile);

                removeImage(imageToDelete);

                response.setStatus(HttpServletResponse.SC_OK);
            }
        }
    }

    @Override
    public Image uploadImage(MultipartFile file) throws IOException {
        Map uploadResult = cloudinaryService.upload(file);
        String imageUrl = (String) uploadResult.get("url");
        String imageId = (String) uploadResult.get("public_id");
        Image image =
                Image.builder()
                        .name(file.getOriginalFilename())
                        .imageUrl(imageUrl)
                        .imageId(imageId)
                        .build();
        return masterImageRepository.save(image);
    }

    @Override
    public void removeImage(Image image) throws IOException {
        cloudinaryService.delete(image.getImageId());
        masterImageRepository.deleteById(image.getId());
    }
}
