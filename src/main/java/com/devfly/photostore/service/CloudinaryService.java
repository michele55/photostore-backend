package com.devfly.photostore.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@Service
@Slf4j
public class CloudinaryService {

    @Value("${cloudinary.cloud-name}")
    private String cloudName;

    @Value("${cloudinary.api-key}")
    private String apiKey;

    @Value("${cloudinary.api-secret}")
    private String apiSecret;

    private Cloudinary cloudinary;

    @PostConstruct
    public void init() {
        cloudinary = new Cloudinary(ObjectUtils.asMap(
                "cloud_name", cloudName,
                "api_key",    apiKey,
                "api_secret", apiSecret,
                "secure",     true
        ));
    }

    /**
     * Carica l'immagine originale ad alta risoluzione (accesso privato).
     * Usata solo per la stampa — non esposta pubblicamente.
     */
    @SuppressWarnings("unchecked")
    public UploadResult uploadHighRes(MultipartFile file, String folder) throws IOException {
        Map<String, Object> options = ObjectUtils.asMap(
                "folder",      "photostore/" + folder + "/highres",
                "type",        "authenticated",          // accesso privato
                "resource_type", "image",
                "quality",     "auto:best",
                "format",      "jpg"
        );
        Map<?, ?> result = cloudinary.uploader().upload(file.getBytes(), options);
        return new UploadResult(
                (String) result.get("public_id"),
                (String) result.get("secure_url"),
                ((Number) result.get("width")).intValue(),
                ((Number) result.get("height")).intValue()
        );
    }

    /**
     * Genera URL anteprima con watermark automatico e dimensioni ridotte.
     * Questa URL è pubblica e visibile nel catalogo.
     */
    public String generatePreviewUrl(String publicId) {
        // Trasformazione Cloudinary: ridimensiona, applica watermark testo, qualità auto
        return cloudinary.url()
                .transformation(new com.cloudinary.Transformation()
                        .width(900).crop("limit")
                        .quality("auto:good")
                        .overlay(new com.cloudinary.Transformation()
                                .text("DEV&FLY © photostore")
                                .fontSize(18)
                                .fontFamily("Arial")
                                .color("white")
                                .opacity(60))
                        .gravity("south_east")
                        .x(15).y(15))
                .generate(publicId);
    }

    /**
     * Elimina un'immagine da Cloudinary (usato quando si cancella una foto).
     */
    public void delete(String publicId) {
        try {
            cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
            log.info("Immagine eliminata da Cloudinary: {}", publicId);
        } catch (IOException e) {
            log.error("Errore eliminazione Cloudinary {}: {}", publicId, e.getMessage());
        }
    }

    public record UploadResult(String publicId, String url, int width, int height) {}
}

