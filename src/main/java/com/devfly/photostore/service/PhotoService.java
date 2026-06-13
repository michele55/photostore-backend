package com.devfly.photostore.service;

import com.devfly.photostore.dto.PhotoDto;
import com.devfly.photostore.entity.PaperType;
import com.devfly.photostore.entity.Photo;
import com.devfly.photostore.entity.PrintFormat;
import com.devfly.photostore.exception.ResourceNotFoundException;
import com.devfly.photostore.repository.PhotoRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Service
public class PhotoService {
    private static final Logger log = LoggerFactory.getLogger(PhotoService.class);
    private final PhotoRepository photoRepository;
    private final CloudinaryService cloudinaryService;
    private final PricingService pricingService;

    public PhotoService(PhotoRepository photoRepository, CloudinaryService cloudinaryService, PricingService pricingService) {
        this.photoRepository = photoRepository;
        this.cloudinaryService = cloudinaryService;
        this.pricingService = pricingService;
    }

    @Transactional
    public PhotoDto.Response uploadPhoto(MultipartFile file, PhotoDto.CreateRequest req) throws IOException {
        CloudinaryService.UploadResult uploaded = cloudinaryService.uploadHighRes(file, req.getCategory().toLowerCase());
        String previewUrl = cloudinaryService.generatePreviewUrl(uploaded.publicId());
        Photo photo = new Photo();
        photo.setTitle(req.getTitle());
        photo.setDescription(req.getDescription());
        photo.setPreviewUrl(previewUrl);
        photo.setHighResUrl(uploaded.url());
        photo.setCloudinaryPublicId(uploaded.publicId());
        photo.setBasePrice(req.getBasePrice());
        photo.setCategory(req.getCategory().toUpperCase());
        photo.setTags(req.getTags() != null ? req.getTags() : List.of());
        photo.setCamera(req.getCamera());
        photo.setLens(req.getLens());
        photo.setLocation(req.getLocation());
        photo.setWidthPx(uploaded.width());
        photo.setHeightPx(uploaded.height());
        log.info("Foto caricata: {}", photo.getTitle());
        return toResponse(photoRepository.save(photo));
    }

    @Transactional
    public PhotoDto.Response updatePhoto(Long id, PhotoDto.CreateRequest req) {
        Photo photo = photoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Foto non trovata: " + id));
        if (req.getTitle() != null) photo.setTitle(req.getTitle());
        if (req.getDescription() != null) photo.setDescription(req.getDescription());
        if (req.getBasePrice() != null) photo.setBasePrice(req.getBasePrice());
        if (req.getCategory() != null) photo.setCategory(req.getCategory().toUpperCase());
        if (req.getTags() != null) photo.setTags(req.getTags());
        if (req.getCamera() != null) photo.setCamera(req.getCamera());
        if (req.getLocation() != null) photo.setLocation(req.getLocation());
        return toResponse(photoRepository.save(photo));
    }

    @Transactional
    public void setActive(Long id, boolean active) {
        Photo photo = photoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Foto non trovata: " + id));
        photo.setActive(active);
        photoRepository.save(photo);
    }

    @Transactional
    public void deletePhoto(Long id) {
        Photo photo = photoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Foto non trovata: " + id));
        if (photo.getCloudinaryPublicId() != null) cloudinaryService.delete(photo.getCloudinaryPublicId());
        photoRepository.delete(photo);
        log.info("Foto eliminata: id={}", id);
    }

    public PhotoDto.Response toResponse(Photo photo) {
        List<PhotoDto.PrintOptionDto> printOptions = new ArrayList<>();
        for (PrintFormat fmt : PrintFormat.values()) {
            for (PaperType paper : PaperType.values()) {
                BigDecimal price = pricingService.calculatePrintPrice(photo.getBasePrice(), fmt, paper);
                printOptions.add(new PhotoDto.PrintOptionDto(
                        fmt.name(),
                        fmt.getCode() + " (" + fmt.getDisplaySize() + ")",
                        paper.getDisplayName(),
                        paper.getDescription(),
                        price));
            }
        }
        PhotoDto.Response r = new PhotoDto.Response();
        r.setId(photo.getId());
        r.setTitle(photo.getTitle());
        r.setDescription(photo.getDescription());
        r.setPreviewUrl(photo.getPreviewUrl());
        r.setBasePrice(photo.getBasePrice());
        r.setCategory(photo.getCategory());
        r.setTags(photo.getTags());
        r.setCamera(photo.getCamera());
        r.setLocation(photo.getLocation());
        r.setViewCount(photo.getViewCount());
        r.setPrintOptions(printOptions);
        r.setCreatedAt(photo.getCreatedAt());
        return r;
    }
}
