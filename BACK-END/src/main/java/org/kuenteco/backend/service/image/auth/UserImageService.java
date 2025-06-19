package org.kuenteco.backend.service.image.auth;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.entity.extra.Image;
import org.springframework.web.multipart.MultipartFile;

public interface UserImageService {
    ImageDTO saveImage(
            MultipartFile image, HttpServletRequest request, HttpServletResponse response)
            throws IOException;

    ImageDTO updateImage(
            MultipartFile image, HttpServletRequest request, HttpServletResponse response)
            throws IOException;

    void deleteImage(HttpServletRequest request, HttpServletResponse response) throws IOException;

    void removeImage(Image image) throws IOException;
}
