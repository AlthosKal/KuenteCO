package org.kuenteco.backend.service.image;

import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.entity.extra.Image;
import org.kuenteco.backend.repository.master.MasterImageRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ImageServiceImpl implements ImageService{
    private final CloudinaryService cloudinaryService;
    private final MasterImageRepository masterImageRepository;

    @Override
    public Image uploadImage(MultipartFile file) throws IOException {
        Map uploadResult = cloudinaryService.upload(file);
        String imageUrl = (String) uploadResult.get("url");
        String imageId = (String) uploadResult.get("public_id");
        Image masterImage = new Image(file.getOriginalFilename(), imageUrl, imageId);
        return masterImageRepository.save(masterImage);
    }

    @Override
    public void deleteImage(Image masterImage) throws IOException {
        cloudinaryService.delete(masterImage.getId_image());
        masterImageRepository.deleteById(masterImage.getId());
    }
}
