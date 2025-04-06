package org.kuenteco.backend.service.image;

import org.kuenteco.backend.entity.master.extra.MasterImage;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

public interface ImageService {
    MasterImage uploadImage(MultipartFile file) throws IOException;
    void deleteImage(MasterImage image) throws IOException;
}
