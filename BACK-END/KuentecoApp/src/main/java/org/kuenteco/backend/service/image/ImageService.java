package org.kuenteco.backend.service.image;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.entity.extra.Image;
import org.springframework.web.multipart.MultipartFile;

public interface ImageService {
    ImageDTO saveImage(MultipartFile image) throws IOException;

    ImageDTO updateImage(MultipartFile image) throws IOException;

    void deleteImage(HttpServletResponse response) throws IOException;

    void removeImage(Image image) throws IOException;
}
