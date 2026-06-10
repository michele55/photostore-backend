package com.devfly.photostore.controller;

import com.devfly.photostore.dto.PhotoDto;
import com.devfly.photostore.service.PhotoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

/**
 * Endpoints riservati all'admin per gestire il catalogo foto.
 * Tutti i metodi richiedono ruolo ADMIN (Spring Security).
 *
 * Base URL: /api/photos/admin
 */
@RestController
@RequestMapping("/photos/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
@CrossOrigin(origins = "${app.frontend-url}")
public class AdminPhotoController {

    private final PhotoService photoService;

    /**
     * POST /api/photos/admin/upload
     *
     * Carica una nuova foto nel catalogo.
     * Usa multipart/form-data:
     *   - file    : file immagine (jpg/png, max 50MB)
     *   - title   : titolo
     *   - basePrice : prezzo base in €
     *   - category  : NATURA | URBANO | DRONE | ARCHITETTURA | PAESAGGIO | ALTRO
     *   - description, tags, camera, lens, location : facoltativi
     */
    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<PhotoDto.Response> upload(
            @RequestPart("file") MultipartFile file,
            @RequestPart("data") @Valid PhotoDto.CreateRequest req) throws IOException {

        if (file.isEmpty()) {
            throw new IllegalArgumentException("Il file immagine è obbligatorio");
        }
        String contentType = file.getContentType();
        if (contentType == null ||
            (!contentType.equals("image/jpeg") && !contentType.equals("image/png") &&
             !contentType.equals("image/webp"))) {
            throw new IllegalArgumentException("Formato file non supportato. Usa JPG, PNG o WEBP.");
        }

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(photoService.uploadPhoto(file, req));
    }

    /**
     * PUT /api/photos/admin/{id}
     * Aggiorna metadati (titolo, prezzo, categoria, ecc.)
     * Non sostituisce il file immagine.
     */
    @PutMapping("/{id}")
    public ResponseEntity<PhotoDto.Response> update(
            @PathVariable Long id,
            @Valid @RequestBody PhotoDto.CreateRequest req) {
        return ResponseEntity.ok(photoService.updatePhoto(id, req));
    }

    /**
     * PATCH /api/photos/admin/{id}/visibility
     * Body: { "active": true/false }
     * Nascondi o mostra una foto nel catalogo senza eliminarla.
     */
    @PatchMapping("/{id}/visibility")
    public ResponseEntity<Void> setVisibility(
            @PathVariable Long id,
            @RequestBody java.util.Map<String, Boolean> body) {
        boolean active = Boolean.TRUE.equals(body.get("active"));
        photoService.setActive(id, active);
        return ResponseEntity.noContent().build();
    }

    /**
     * DELETE /api/photos/admin/{id}
     * Elimina foto da DB e da Cloudinary.
     * ATTENZIONE: operazione irreversibile.
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        photoService.deletePhoto(id);
        return ResponseEntity.noContent().build();
    }
}

