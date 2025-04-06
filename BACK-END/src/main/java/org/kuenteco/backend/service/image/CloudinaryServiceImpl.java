package org.kuenteco.backend.service.image;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;


@Service
public class CloudinaryServiceImpl implements CloudinaryService{
    private final Cloudinary cloudinary;

    public CloudinaryServiceImpl(){
        Map<String, Object> valuesMap = new HashMap<>();
        valuesMap.put("cloud_name", System.getenv("CLOUDINARY_NAME"));
        valuesMap.put("cloud_api_key", System.getenv("CLOUDINARY_API_KEY"));
        valuesMap.put("cloud_secret", System.getenv("CLOUDINARY_API_SECRET"));
        cloudinary = new Cloudinary(valuesMap);
    }

    @Override
    public Map upload(MultipartFile multipartFile) throws IOException {
        File file = convert(multipartFile);
        Map result = cloudinary.uploader().upload(file, ObjectUtils.emptyMap());
        if(!Files.deleteIfExists(file.toPath())){
            throw new IOException("Failed to delete temporary file: " + file.getAbsolutePath());
        }
        return result;
    }

    @Override
    public Map delete(String id) throws IOException {
        return cloudinary.uploader().destroy(id, ObjectUtils.emptyMap());
    }

    private File convert(MultipartFile multipartFile) throws IOException{
        File file = new File(Objects.requireNonNull(multipartFile.getOriginalFilename()));
        FileOutputStream fo = new FileOutputStream(file);
        fo.write(multipartFile.getBytes());
        fo.close();
        return file;
    }
}
