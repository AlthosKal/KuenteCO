package org.kuenteco.backend.service.image.auth;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.Transactional;
import java.io.IOException;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.entity.extra.Image;
import org.kuenteco.backend.jwt.JwtUtil;
import org.kuenteco.backend.mapper.image.ImageMapper;
import org.kuenteco.backend.repository.master.MasterImageRepository;
import org.kuenteco.backend.repository.master.MasterUserRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.kuenteco.backend.service.image.CloudinaryService;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class UserImageServiceImpl implements UserImageService {
    private final JwtUtil jwtUtil;
    private final MasterUserRepository masterUserRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final CloudinaryService cloudinaryService;
    private final MasterImageRepository masterImageRepository;
    private final ImageMapper imageMapper;

    @Override
    @Transactional
    public ImageDTO saveImage(
            MultipartFile image, HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        User user = resolveUser(request);
        // Verificar si ya tiene una imagen previa
        if (user.getImage() != null) {
            throw new RuntimeException(
                    "El usuario ya tiene una imagen de perfil. Utilice updateImage para actualizarla.");
        }

        // Subir la nueva imagen
        Image newImage = uploadImage(image);
        user.setImage(newImage);
        masterUserRepository.save(user);

        return imageMapper.toDTO(newImage);
    }

    @Override
    @Transactional
    public ImageDTO updateImage(
            MultipartFile image, HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        User user = resolveUser(request);

        if (user.getImage() == null) {
            throw new RuntimeException("El usuario no tiene una imagen de perfil para actualizar.");
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

        return imageMapper.toDTO(newImage);
    }

    @Override
    @Transactional
    public void deleteImage(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        User user = resolveUser(request);

        // Verificar si tiene imagen para eliminar
        if (user.getImage() == null) {
            throw new RuntimeException("El usuario no tiene una imagen de perfil para eliminar.");
        }

        // Eliminar la imagen
        Image imageToDelete = user.getImage();
        user.setImage(null);
        masterUserRepository.save(user);

        removeImage(imageToDelete);

        response.setStatus(HttpServletResponse.SC_OK);
    }

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

    public User resolveUser(HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        String email = jwtUtil.extractEmail(token);
        return slaveUserRepository
                .findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
    }
}
