package org.kuenteco.backend.service.image;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Map;
import java.util.Objects;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class CloudinaryServiceImpl implements CloudinaryService {
    private final Cloudinary cloudinary;

    public CloudinaryServiceImpl(Cloudinary cloudinary) {
        this.cloudinary = cloudinary;
    }

    @Override
    public Map upload(MultipartFile multipartFile) throws IOException {
        File file = convert(multipartFile);
        try {
            Map params = ObjectUtils.asMap("secure", true);
            Map result = cloudinary.uploader().upload(file, params);

            // Siempre leer secure_url para HTTPS
            String secureUrl = (String) result.get("secure_url");
            result.put("url", secureUrl); // reemplaza por HTTPS

            return result;
        } finally {
            Files.deleteIfExists(file.toPath());
        }
    }

    @Override
    public Map delete(String id) throws IOException {
        return cloudinary.uploader().destroy(id, ObjectUtils.emptyMap());
    }

    private File convert(MultipartFile multipartFile) throws IOException {
        File file =
                File.createTempFile(
                        "upload-",
                        "-" + Objects.requireNonNull(multipartFile.getOriginalFilename()));
        try (FileOutputStream fo = new FileOutputStream(file)) {
            fo.write(multipartFile.getBytes());
        }
        return file;
    }
}
