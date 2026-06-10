package com.devfly.photostore.service;

import com.devfly.photostore.dto.PhotoDto;
import com.devfly.photostore.entity.PaperType;
import com.devfly.photostore.entity.Photo;
import com.devfly.photostore.entity.PrintFormat;
import com.devfly.photostore.exception.ResourceNotFoundException;
import com.devfly.photostore.repository.PhotoRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class PhotoService {

    private final PhotoRepository photoRepository;
    private final CloudinaryService cloudinaryService;
    private final PricingService pricingService;

    // ─────────────────────────────────────────────────────────────────
    // CARICA NUOVA FOTO (Solo Admin)
    // ─────────────────────────────────────────────────────────────────
    @Transactional
    public PhotoDto.Response uploadPhoto(MultipartFile file,
                                         PhotoDto.CreateRequest req) throws IOException {
        // 1. Carica su Cloudinary (alta risoluzione, privata)
        CloudinaryService.UploadResult uploaded =
                cloudinaryService.uploadHighRes(file, req.getCategory().toLowerCase());

        // 2. Genera URL anteprima con watermark (pubblica)
        String previewUrl = cloudinaryService.generatePreviewUrl(uploaded.publicId());

        // 3. Costruisci e salva entità
        Photo photo = Photo.builder()
                .title(req.getTitle())
                .description(req.getDescription())
                .previewUrl(previewUrl)
                .highResUrl(uploaded.url())
                .cloudinaryPublicId(uploaded.publicId())
                .basePrice(req.getBasePrice())
                .category(req.getCategory().toUpperCase())
                .tags(req.getTags() != null ? req.getTags() : List.of())
                .camera(req.getCamera())
                .lens(req.getLens())
                .location(req.getLocation())
                .widthPx(uploaded.width())
                .heightPx(uploaded.height())
                .build();

        Photo saved = photoRepository.save(photo);
        log.info("Foto caricata: {} (id: {})", saved.getTitle(), saved.getId());

        return toResponse(saved);
    }

    // ─────────────────────────────────────────────────────────────────
    // AGGIORNA METADATI FOTO (Solo Admin)
    // ─────────────────────────────────────────────────────────────────
    @Transactional
    public PhotoDto.Response updatePhoto(Long id, PhotoDto.CreateRequest req) {
        Photo photo = photoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Foto non trovata: " + id));

        if (req.getTitle() != null)       photo.setTitle(req.getTitle());
        if (req.getDescription() != null) photo.setDescription(req.getDescription());
        if (req.getBasePrice() != null)   photo.setBasePrice(req.getBasePrice());
        if (req.getCategory() != null)    photo.setCategory(req.getCategory().toUpperCase());
        if (req.getTags() != null)        photo.setTags(req.getTags());
        if (req.getCamera() != null)      photo.setCamera(req.getCamera());
        if (req.getLens() != null)        photo.setLens(req.getLens());
        if (req.getLocation() != null)    photo.setLocation(req.getLocation());

        return toResponse(photoRepository.save(photo));
    }

    // ─────────────────────────────────────────────────────────────────
    // DISATTIVA / RIATTIVA FOTO
    // ─────────────────────────────────────────────────────────────────
    @Transactional
    public void setActive(Long id, boolean active) {
        Photo photo = photoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Foto non trovata: " + id));
        photo.setActive(active);
        photoRepository.save(photo);
    }

    // ─────────────────────────────────────────────────────────────────
    // ELIMINA FOTO (Admin)
    // ─────────────────────────────────────────────────────────────────
    @Transactional
    public void deletePhoto(Long id) {
        Photo photo = photoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Foto non trovata: " + id));
        // Elimina da Cloudinary
        if (photo.getCloudinaryPublicId() != null) {
            cloudinaryService.delete(photo.getCloudinaryPublicId());
        }
        photoRepository.delete(photo);
        log.info("Foto eliminata: id={}", id);
    }

    // ─────────────────────────────────────────────────────────────────
    // MAPPING → DTO
    // ─────────────────────────────────────────────────────────────────
    public PhotoDto.Response toResponse(Photo photo) {
        // Calcola tutte le opzioni di stampa con prezzi
        List<PhotoDto.PrintOptionDto> printOptions = Arrays.stream(PrintFormat.values())
                .flatMap(fmt -> Arrays.stream(PaperType.values()).map(paper -> {
                    BigDecimal price = pricingService.calculatePrintPrice(
                            photo.getBasePrice(), fmt, paper);
                    return PhotoDto.PrintOptionDto.builder()
                            .formatCode(fmt.name())
                            .formatDisplay(fmt.getCode() + " (" + fmt.getDisplaySize() + ")")
                            .paperName(paper.getDisplayName())
                            .paperDescription(paper.getDescription())
                            .finalPrice(price)
                            .build();
                }))
                .toList();

        return PhotoDto.Response.builder()
                .id(photo.getId())
                .title(photo.getTitle())
                .description(photo.getDescription())
                .previewUrl(photo.getPreviewUrl())
                .basePrice(photo.getBasePrice())
                .category(photo.getCategory())
                .tags(photo.getTags())
                .camera(photo.getCamera())
                .location(photo.getLocation())
                .viewCount(photo.getViewCount())
                .printOptions(printOptions)
                .createdAt(photo.getCreatedAt())
                .build();
    }
}

