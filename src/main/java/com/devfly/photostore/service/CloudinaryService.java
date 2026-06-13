package com.devfly.photostore.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.util.Map;

@Service
public class CloudinaryService {
    private static final Logger log = LoggerFactory.getLogger(CloudinaryService.class);
    @Value("${cloudinary.cloud-name}") private String cloudName;
    @Value("${cloudinary.api-key}") private String apiKey;
    @Value("${cloudinary.api-secret}") private String apiSecret;
    private Cloudinary cloudinary;

    @PostConstruct
    public void init() {
        cloudinary = new Cloudinary(ObjectUtils.asMap(
                "cloud_name", cloudName, "api_key", apiKey,
                "api_secret", apiSecret, "secure", true));
    }

    @SuppressWarnings("unchecked")
    public UploadResult uploadHighRes(MultipartFile file, String folder) throws IOException {
        Map<String, Object> options = ObjectUtils.asMap(
                "folder", "photostore/" + folder + "/highres",
                "type", "authenticated",
                "resource_type", "image",
                "quality", "auto:best",
                "format", "jpg");
        Map<?, ?> result = cloudinary.uploader().upload(file.getBytes(), options);
        return new UploadResult(
                (String) result.get("public_id"),
                (String) result.get("secure_url"),
                ((Number) result.get("width")).intValue(),
                ((Number) result.get("height")).intValue());
    }

    public String generatePreviewUrl(String publicId) {
        return cloudinary.url()
                .transformation(new com.cloudinary.Transformation()
                        .width(900).crop("limit").quality("auto:good"))
                .generate(publicId);
    }

    public void delete(String publicId) {
        try {
            cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
            log.info("Immagine eliminata: {}", publicId);
        } catch (IOException e) {
            log.error("Errore eliminazione Cloudinary: {}", e.getMessage());
        }
    }

    public static class UploadResult {
        private final String publicId;
        private final String url;
        private final int width;
        private final int height;
        public UploadResult(String publicId, String url, int width, int height) {
            this.publicId = publicId; this.url = url;
            this.width = width; this.height = height;
        }
        public String publicId() { return publicId; }
        public String url() { return url; }
        public int width() { return width; }
        public int height() { return height; }
    }
}
