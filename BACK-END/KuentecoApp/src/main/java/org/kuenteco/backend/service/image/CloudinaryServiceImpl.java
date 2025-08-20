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
    @SuppressWarnings("unchecked")
    public Map<String, Object> upload(MultipartFile multipartFile) throws IOException {
        File file = convert(multipartFile);
        try {
            Map<String, Object> params = ObjectUtils.asMap("secure", true);
            Map<String, Object> result = (Map<String, Object>) cloudinary.uploader().upload(file, params);

            // Siempre leer secure_url para HTTPS
            String secureUrl = (String) result.get("secure_url");
            result.put("url", secureUrl); // reemplaza por HTTPS

            return result;
        } finally {
            Files.deleteIfExists(file.toPath());
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public Map<String, Object> delete(String id) throws IOException {
        return (Map<String, Object>) cloudinary.uploader().destroy(id, ObjectUtils.emptyMap());
    }

    private File convert(MultipartFile multipartFile) throws IOException {
        String originalFilename = Objects.requireNonNull(multipartFile.getOriginalFilename());

        // Sanitizar: quitar caracteres peligrosos
        String safeName = originalFilename.replaceAll("[^a-zA-Z0-9.-]", "_");

        // Limitar longitud para evitar abusos
        if (safeName.length() > 50) {
            safeName = safeName.substring(safeName.length() - 50);
        }

        // Crear archivo siempre en el directorio temporal del sistema
        File file = File.createTempFile("upload-", "-" + safeName);

        // Validar que está dentro del directorio temporal
        String tmpDir = new File(System.getProperty("java.io.tmpdir")).getCanonicalPath();
        String filePath = file.getCanonicalPath();
        if (!filePath.startsWith(tmpDir)) {
            throw new SecurityException("Ruta de archivo no válida: se detectó un intento de escritura fuera del directorio temporal permitido");
        }

        // Escribir el contenido
        try (FileOutputStream fo = new FileOutputStream(file)) {
            fo.write(multipartFile.getBytes());
        }

        return file;
    }
}
