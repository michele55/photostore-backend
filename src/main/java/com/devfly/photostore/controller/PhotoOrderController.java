package com.devfly.photostore.controller;

import com.devfly.photostore.dto.OrderDto;
import com.devfly.photostore.entity.OrderStatus;
import com.devfly.photostore.entity.PaperType;
import com.devfly.photostore.entity.Photo;
import com.devfly.photostore.entity.PrintFormat;
import com.devfly.photostore.exception.ResourceNotFoundException;
import com.devfly.photostore.repository.PhotoRepository;
import com.devfly.photostore.service.OrderService;
import com.devfly.photostore.service.PricingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

// ═══════════════════════════════════════════════════════════
// PHOTO CONTROLLER
// ═══════════════════════════════════════════════════════════
@RestController
@RequestMapping("/photos")
@RequiredArgsConstructor
@CrossOrigin(origins = "${app.frontend-url}")
class PhotoController {

    private final PhotoRepository photoRepository;
    private final PricingService pricingService;

    /** Catalogo pubblico con paginazione e filtro categoria */
    @GetMapping
    public Page<PhotoSummary> getPhotos(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String q,
            @PageableDefault(size = 12, sort = "createdAt") Pageable pageable) {

        Page<Photo> page;
        if (q != null && !q.isBlank()) {
            page = photoRepository.search(q, pageable);
        } else if (category != null && !category.isBlank()) {
            page = photoRepository.findByCategoryAndActiveTrue(category, pageable);
        } else {
            page = photoRepository.findByActiveTrue(pageable);
        }
        return page.map(this::toSummary);
    }

    /** Dettaglio foto + opzioni di stampa con prezzi calcolati */
    @GetMapping("/{id}")
    @Transactional
    public ResponseEntity<PhotoDetail> getPhoto(@PathVariable Long id) {
        Photo photo = photoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Foto non trovata: " + id));
        photoRepository.incrementViews(id);

        List<PrintOption> options = Arrays.stream(PrintFormat.values())
                .flatMap(fmt -> Arrays.stream(PaperType.values()).map(paper -> {
                    BigDecimal price = pricingService.calculatePrintPrice(
                            photo.getBasePrice(), fmt, paper);
                    return new PrintOption(
                            fmt.name(), fmt.getCode(), fmt.getDisplaySize(),
                            paper.name(), paper.getDisplayName(), paper.getDescription(),
                            price
                    );
                }))
                .toList();

        return ResponseEntity.ok(new PhotoDetail(photo, options));
    }

    /** Foto più vendute */
    @GetMapping("/featured")
    public List<PhotoSummary> getFeatured() {
        return photoRepository.findTop8ByActiveTrueOrderByOrderCountDesc()
                .stream().map(this::toSummary).toList();
    }

    // Inner record classes per response
    record PrintOption(String formatKey, String formatCode, String formatSize,
                       String paperKey, String paperName, String paperDescription,
                       BigDecimal price) {}

    record PhotoSummary(Long id, String title, String previewUrl, String category,
                        BigDecimal basePrice, String location, Integer viewCount) {}

    record PhotoDetail(Long id, String title, String description, String previewUrl,
                       String category, List<String> tags, String camera, String lens,
                       String location, BigDecimal basePrice, List<PrintOption> printOptions) {
        PhotoDetail(Photo p, List<PrintOption> opts) {
            this(p.getId(), p.getTitle(), p.getDescription(), p.getPreviewUrl(),
                    p.getCategory(), p.getTags(), p.getCamera(), p.getLens(),
                    p.getLocation(), p.getBasePrice(), opts);
        }
    }

    private PhotoSummary toSummary(Photo p) {
        return new PhotoSummary(p.getId(), p.getTitle(), p.getPreviewUrl(),
                p.getCategory(), p.getBasePrice(), p.getLocation(), p.getViewCount());
    }
}

// ═══════════════════════════════════════════════════════════
// ORDER CONTROLLER
// ═══════════════════════════════════════════════════════════
@RestController
@RequestMapping("/orders")
@RequiredArgsConstructor
@CrossOrigin(origins = "${app.frontend-url}")
class OrderController {

    private final OrderService orderService;

    /**
     * Crea ordine e restituisce l'URL di Stripe Checkout.
     * Accessibile a tutti (anche guest).
     */
    @PostMapping("/checkout")
    public ResponseEntity<OrderDto.CheckoutResponse> checkout(
            @Valid @RequestBody OrderDto.CreateRequest req) {
        return ResponseEntity.ok(orderService.createOrderAndCheckout(req));
    }

    /** Stato ordine per il cliente (tramite numero ordine) */
    @GetMapping("/{orderNumber}")
    public ResponseEntity<OrderDto.Response> getOrder(@PathVariable String orderNumber) {
        return ResponseEntity.ok(orderService.getByOrderNumber(orderNumber));
    }

    /** Storico ordini per email */
    @GetMapping("/my/{email}")
    public Page<OrderDto.Response> getMyOrders(
            @PathVariable String email,
            @PageableDefault(size = 10) Pageable pageable) {
        return orderService.getOrdersByEmail(email, pageable);
    }

    // ── Admin endpoints ───────────────────────────────────────────
    @GetMapping("/admin/all")
    @PreAuthorize("hasRole('ADMIN')")
    public Page<OrderDto.Response> getAllOrders(@PageableDefault(size = 20) Pageable pageable) {
        return orderService.getAllOrders(pageable);
    }

    @PatchMapping("/admin/{orderNumber}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<OrderDto.Response> updateStatus(
            @PathVariable String orderNumber,
            @RequestBody Map<String, String> body) {
        OrderStatus newStatus = OrderStatus.valueOf(body.get("status"));
        return ResponseEntity.ok(orderService.updateStatus(orderNumber, newStatus));
    }
}

