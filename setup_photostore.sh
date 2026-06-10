#!/bin/bash
set -e
echo "Creazione struttura cartelle..."
mkdir -p src/main/java/com/devfly/photostore/{config,controller,dto,entity,exception,repository,service}
mkdir -p src/main/resources/templates/email
echo "Creazione file sorgenti..."

cat > src/main/java/com/devfly/photostore/dto/PhotoDto.java << 'XEOF'
package com.devfly.photostore.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class PhotoDto {

    @Getter @Setter @Builder
    public static class Response {
        private Long id;
        private String title;
        private String description;
        private String previewUrl;
        private BigDecimal basePrice;
        private String category;
        private List<String> tags;
        private String camera;
        private String location;
        private Integer viewCount;
        private List<PrintOptionDto> printOptions;
        private LocalDateTime createdAt;
    }

    @Getter @Setter
    public static class CreateRequest {
        @NotBlank private String title;
        private String description;
        @NotNull private BigDecimal basePrice;
        @NotBlank private String category;
        private List<String> tags;
        private String camera;
        private String lens;
        private String location;
    }

    @Getter @Setter @Builder
    public static class PrintOptionDto {
        private String formatCode;
        private String formatDisplay;
        private String paperName;
        private String paperDescription;
        private BigDecimal finalPrice;
    }
}

XEOF
echo "OK PhotoDto.java"

cat > src/main/java/com/devfly/photostore/entity/PrintFormat.java << 'XEOF'
package com.devfly.photostore.entity;

/**
 * Formati di stampa disponibili con moltiplicatore di prezzo.
 */
public enum PrintFormat {

    A4("A4",       "21 × 29.7 cm",  1.0),
    A3("A3",       "29.7 × 42 cm",  1.5),
    A2("A2",       "42 × 59.4 cm",  2.2),
    A1("A1",       "59.4 × 84.1 cm",3.2),
    CM_50X70("50×70", "50 × 70 cm", 2.8),
    CM_70X100("70×100","70 × 100 cm",4.0),
    CM_30X45("30×45", "30 × 45 cm", 1.3),
    SQUARE_30("30×30","30 × 30 cm",  1.2),
    SQUARE_50("50×50","50 × 50 cm",  2.0);

    private final String code;
    private final String displaySize;
    private final double priceMultiplier;

    PrintFormat(String code, String displaySize, double priceMultiplier) {
        this.code = code;
        this.displaySize = displaySize;
        this.priceMultiplier = priceMultiplier;
    }

    public String getCode()            { return code; }
    public String getDisplaySize()     { return displaySize; }
    public double getPriceMultiplier() { return priceMultiplier; }
}

XEOF
echo "OK PrintFormat.java"

cat > src/main/java/com/devfly/photostore/entity/PaperType.java << 'XEOF'
package com.devfly.photostore.entity;

/**
 * Tipi di carta per la stampa con moltiplicatore di prezzo.
 */
public enum PaperType {

    LUCIDA("Lucida",
           "Carta fotografica lucida ad alta saturazione, ideale per colori vivaci.",
           1.0),

    OPACA("Opaca",
          "Finitura opaca anti-riflesso, perfetta per ambienti con luce diretta.",
          1.0),

    CANVAS("Canvas",
           "Stampa su tela artistica con texture tessuta, effetto quadro da galleria.",
           1.8),

    FINE_ART("Fine Art",
             "Carta cotone 300g archiviale, durata oltre 100 anni, colori profondi.",
             2.2),

    METALLICA("Metallica",
              "Superficie metallizzata che dona brillantezza unica alle foto di paesaggi.",
              2.5),

    PLEXIGLASS("Plexiglass",
               "Stampa dietro vetro acrilico, resa luminosa e moderna, pronta da appendere.",
               3.5);

    private final String displayName;
    private final String description;
    private final double priceMultiplier;

    PaperType(String displayName, String description, double priceMultiplier) {
        this.displayName = displayName;
        this.description = description;
        this.priceMultiplier = priceMultiplier;
    }

    public String getDisplayName()     { return displayName; }
    public String getDescription()     { return description; }
    public double getPriceMultiplier() { return priceMultiplier; }
}

XEOF
echo "OK PaperType.java"

cat > src/main/java/com/devfly/photostore/entity/OrderStatus.java << 'XEOF'
package com.devfly.photostore.entity;

public enum OrderStatus {
    PENDING_PAYMENT,   // In attesa di pagamento
    PAID,              // Pagato — da processare
    PROCESSING,        // In lavorazione (stampa in corso)
    SHIPPED,           // Spedito
    DELIVERED,         // Consegnato
    CANCELLED,         // Annullato
    REFUNDED           // Rimborsato
}

XEOF
echo "OK OrderStatus.java"

cat > src/main/java/com/devfly/photostore/entity/User.java << 'XEOF'
package com.devfly.photostore.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

@Entity
@Table(name = "users")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    private String phone;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private Role role = Role.CUSTOMER;

    @Column(name = "email_verified")
    @Builder.Default
    private boolean emailVerified = false;

    @Column(name = "active")
    @Builder.Default
    private boolean active = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public enum Role {
        CUSTOMER, ADMIN
    }
}

XEOF
echo "OK User.java"

cat > src/main/java/com/devfly/photostore/entity/Order.java << 'XEOF'
package com.devfly.photostore.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "orders")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Codice ordine leggibile (es: DF-2024-00042)
    @Column(name = "order_number", unique = true, nullable = false)
    private String orderNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    // Dati cliente (anche per guest checkout)
    @Column(name = "customer_email", nullable = false)
    private String customerEmail;

    @Column(name = "customer_name", nullable = false)
    private String customerName;

    @Column(name = "customer_phone")
    private String customerPhone;

    // Indirizzo di spedizione
    @Column(name = "shipping_address", nullable = false)
    private String shippingAddress;

    @Column(name = "shipping_city", nullable = false)
    private String shippingCity;

    @Column(name = "shipping_zip", nullable = false)
    private String shippingZip;

    @Column(name = "shipping_country", nullable = false)
    @Builder.Default
    private String shippingCountry = "IT";

    // Righe dell'ordine
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<OrderItem> items = new ArrayList<>();

    // Totali
    @Column(name = "subtotal", nullable = false, precision = 10, scale = 2)
    private BigDecimal subtotal;

    @Column(name = "shipping_cost", nullable = false, precision = 10, scale = 2)
    private BigDecimal shippingCost;

    @Column(name = "total_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalAmount;

    // Stato ordine
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private OrderStatus status = OrderStatus.PENDING_PAYMENT;

    // Stripe
    @Column(name = "stripe_payment_intent_id", unique = true)
    private String stripePaymentIntentId;

    @Column(name = "stripe_session_id", unique = true)
    private String stripeSessionId;

    // Note
    @Column(length = 500)
    private String notes;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "paid_at")
    private LocalDateTime paidAt;

    // Genera numero ordine univoco
    @PrePersist
    public void generateOrderNumber() {
        if (this.orderNumber == null) {
            String year = String.valueOf(LocalDateTime.now().getYear());
            String unique = UUID.randomUUID().toString().substring(0, 6).toUpperCase();
            this.orderNumber = "DF-" + year + "-" + unique;
        }
    }
}

XEOF
echo "OK Order.java"

cat > src/main/java/com/devfly/photostore/entity/OrderItem.java << 'XEOF'
package com.devfly.photostore.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "order_items")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class OrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "photo_id", nullable = false)
    private Photo photo;

    // Titolo salvato al momento dell'ordine (storico)
    @Column(name = "photo_title", nullable = false)
    private String photoTitle;

    // Scelte di stampa del cliente
    @Enumerated(EnumType.STRING)
    @Column(name = "print_format", nullable = false)
    private PrintFormat printFormat;

    @Enumerated(EnumType.STRING)
    @Column(name = "paper_type", nullable = false)
    private PaperType paperType;

    @Column(nullable = false)
    @Builder.Default
    private Integer quantity = 1;

    // Prezzo unitario calcolato (base × formato × carta)
    @Column(name = "unit_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal unitPrice;

    @Column(name = "line_total", nullable = false, precision = 10, scale = 2)
    private BigDecimal lineTotal;

    // Snapshot anteprima per email
    @Column(name = "preview_url")
    private String previewUrl;
}

XEOF
echo "OK OrderItem.java"

cat > src/main/java/com/devfly/photostore/repository/UserRepository.java << 'XEOF'
package com.devfly.photostore.repository;

import com.devfly.photostore.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
}

XEOF
echo "OK UserRepository.java"

cat > src/main/java/com/devfly/photostore/repository/PhotoRepository.java << 'XEOF'
package com.devfly.photostore.repository;

import com.devfly.photostore.entity.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PhotoRepository extends JpaRepository<Photo, Long> {

    Page<Photo> findByActiveTrue(Pageable pageable);

    Page<Photo> findByCategoryAndActiveTrue(String category, Pageable pageable);

    @Query("SELECT p FROM Photo p WHERE p.active = true AND " +
           "(LOWER(p.title) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
           " LOWER(p.description) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
           " LOWER(p.location) LIKE LOWER(CONCAT('%', :q, '%')))")
    Page<Photo> search(@Param("q") String query, Pageable pageable);

    @Modifying
    @Query("UPDATE Photo p SET p.viewCount = p.viewCount + 1 WHERE p.id = :id")
    void incrementViews(@Param("id") Long id);

    List<Photo> findTop8ByActiveTrueOrderByOrderCountDesc();
}

XEOF
echo "OK PhotoRepository.java"

cat > src/main/java/com/devfly/photostore/repository/OrderRepository.java << 'XEOF'
package com.devfly.photostore.repository;

import com.devfly.photostore.entity.Order;
import com.devfly.photostore.entity.OrderStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {

    Optional<Order> findByOrderNumber(String orderNumber);

    Optional<Order> findByStripeSessionId(String sessionId);

    Optional<Order> findByStripePaymentIntentId(String paymentIntentId);

    Page<Order> findByCustomerEmailOrderByCreatedAtDesc(String email, Pageable pageable);

    Page<Order> findByStatusOrderByCreatedAtDesc(OrderStatus status, Pageable pageable);

    List<Order> findByStatusOrderByCreatedAtAsc(OrderStatus status);
}

XEOF
echo "OK OrderRepository.java"

cat > src/main/java/com/devfly/photostore/dto/AuthDto.java << 'XEOF'
package com.devfly.photostore.dto;

import com.devfly.photostore.entity.*;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

// ─────────────────────────────────────────────
// AUTH
// ─────────────────────────────────────────────

public class AuthDto {

    @Getter @Setter
    public static class RegisterRequest {
        @NotBlank @Email
        private String email;
        @NotBlank @Size(min = 8)
        private String password;
        @NotBlank
        private String fullName;
        private String phone;
    }

    @Getter @Setter
    public static class LoginRequest {
        @NotBlank @Email
        private String email;
        @NotBlank
        private String password;
    }

    @Getter @Setter @Builder
    public static class AuthResponse {
        private String token;
        private String email;
        private String fullName;
        private String role;
    }
}

// ─────────────────────────────────────────────
// PHOTO
// ─────────────────────────────────────────────

public class PhotoDto {  // <- compilatore separerà in file reali

    @Getter @Setter @Builder
    public static class Response {
        private Long id;
        private String title;
        private String description;
        private String previewUrl;
        private BigDecimal basePrice;
        private String category;
        private List<String> tags;
        private String camera;
        private String location;
        private Integer viewCount;
        private List<PrintOptionDto> printOptions; // prezzi per ogni combinazione
        private LocalDateTime createdAt;
    }

    @Getter @Setter
    public static class CreateRequest {
        @NotBlank private String title;
        private String description;
        @NotNull private BigDecimal basePrice;
        @NotBlank private String category;
        private List<String> tags;
        private String camera;
        private String lens;
        private String location;
    }

    @Getter @Setter @Builder
    public static class PrintOptionDto {
        private String formatCode;
        private String formatDisplay;
        private String paperName;
        private String paperDescription;
        private BigDecimal finalPrice;
    }
}

XEOF
echo "OK AuthDto.java"

cat > src/main/java/com/devfly/photostore/dto/OrderDto.java << 'XEOF'
package com.devfly.photostore.dto;

import com.devfly.photostore.entity.OrderStatus;
import com.devfly.photostore.entity.PaperType;
import com.devfly.photostore.entity.PrintFormat;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class OrderDto {

    // ── Richiesta creazione ordine ──────────────────────────────────
    @Getter @Setter
    public static class CreateRequest {

        @NotBlank @Email
        private String customerEmail;

        @NotBlank
        private String customerName;

        private String customerPhone;

        @NotBlank
        private String shippingAddress;

        @NotBlank
        private String shippingCity;

        @NotBlank @Size(min = 5, max = 5)
        private String shippingZip;

        private String shippingCountry = "IT";

        private String notes;

        @NotEmpty @Valid
        private List<ItemRequest> items;
    }

    // ── Singola riga dell'ordine ────────────────────────────────────
    @Getter @Setter
    public static class ItemRequest {

        @NotNull
        private Long photoId;

        @NotNull
        private PrintFormat printFormat;

        @NotNull
        private PaperType paperType;

        @Min(1) @Max(10)
        private Integer quantity = 1;
    }

    // ── Response ordine completo ────────────────────────────────────
    @Getter @Setter @Builder
    public static class Response {
        private Long id;
        private String orderNumber;
        private String customerEmail;
        private String customerName;
        private String shippingAddress;
        private String shippingCity;
        private String shippingZip;
        private String shippingCountry;
        private List<ItemResponse> items;
        private BigDecimal subtotal;
        private BigDecimal shippingCost;
        private BigDecimal totalAmount;
        private OrderStatus status;
        private String checkoutUrl;      // URL Stripe Checkout
        private LocalDateTime createdAt;
        private LocalDateTime paidAt;
    }

    // ── Singola riga in response ────────────────────────────────────
    @Getter @Setter @Builder
    public static class ItemResponse {
        private Long photoId;
        private String photoTitle;
        private String previewUrl;
        private String printFormat;
        private String formatSize;
        private String paperType;
        private Integer quantity;
        private BigDecimal unitPrice;
        private BigDecimal lineTotal;
    }

    // ── Risposta creazione sessione Stripe ──────────────────────────
    @Getter @Setter @Builder
    public static class CheckoutResponse {
        private String orderNumber;
        private String checkoutUrl;
        private BigDecimal totalAmount;
    }
}

XEOF
echo "OK OrderDto.java"

cat > src/main/java/com/devfly/photostore/exception/ResourceNotFoundException.java << 'XEOF'
package com.devfly.photostore.exception;

public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}

XEOF
echo "OK ResourceNotFoundException.java"

cat > src/main/java/com/devfly/photostore/exception/GlobalExceptionHandler.java << 'XEOF'
package com.devfly.photostore.exception;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    // ── 404 Not Found ────────────────────────────────────────────────
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse(HttpStatus.NOT_FOUND.value(), ex.getMessage()));
    }

    // ── 400 Validation errors ────────────────────────────────────────
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String field = ((FieldError) error).getField();
            errors.put(field, error.getDefaultMessage());
        });
        ErrorResponse response = new ErrorResponse(HttpStatus.BAD_REQUEST.value(),
                "Errore di validazione");
        response.setFieldErrors(errors);
        return ResponseEntity.badRequest().body(response);
    }

    // ── 400 Business logic errors ────────────────────────────────────
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArg(IllegalArgumentException ex) {
        return ResponseEntity.badRequest()
                .body(new ErrorResponse(HttpStatus.BAD_REQUEST.value(), ex.getMessage()));
    }

    // ── 403 Forbidden ────────────────────────────────────────────────
    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ErrorResponse> handleForbidden(AccessDeniedException ex) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(new ErrorResponse(HttpStatus.FORBIDDEN.value(), "Accesso negato"));
    }

    // ── 500 Generic ──────────────────────────────────────────────────
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneric(Exception ex) {
        log.error("Errore non gestito: {}", ex.getMessage(), ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                        "Errore interno del server. Riprova tra poco."));
    }

    // ── Error response DTO ───────────────────────────────────────────
    public static class ErrorResponse {
        private final int status;
        private final String message;
        private final LocalDateTime timestamp = LocalDateTime.now();
        private Map<String, String> fieldErrors;

        public ErrorResponse(int status, String message) {
            this.status = status;
            this.message = message;
        }

        public int getStatus()                      { return status; }
        public String getMessage()                  { return message; }
        public LocalDateTime getTimestamp()         { return timestamp; }
        public Map<String, String> getFieldErrors() { return fieldErrors; }
        public void setFieldErrors(Map<String, String> fe) { this.fieldErrors = fe; }
    }
}

XEOF
echo "OK GlobalExceptionHandler.java"

cat > src/main/java/com/devfly/photostore/config/JwtService.java << 'XEOF'
package com.devfly.photostore.config;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;

/**
 * Servizio per generazione e validazione token JWT.
 * Esposto come @Component pubblico per essere iniettato in AuthService.
 */
@Component
public class JwtService {

    @Value("${app.jwt.secret}")
    private String secret;

    @Value("${app.jwt.expiration}")
    private long expiration;

    private Key getKey() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    public String generateToken(String email, String role) {
        return Jwts.builder()
                .setSubject(email)
                .claim("role", role)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public Claims validateToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    public String extractEmail(String token) {
        return validateToken(token).getSubject();
    }
}

XEOF
echo "OK JwtService.java"

cat > src/main/java/com/devfly/photostore/config/JwtAuthFilter.java << 'XEOF'
package com.devfly.photostore.config;

import com.devfly.photostore.repository.UserRepository;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UserRepository userRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest req,
                                    HttpServletResponse res,
                                    FilterChain chain)
            throws IOException, ServletException {

        String header = req.getHeader("Authorization");
        if (header == null || !header.startsWith("Bearer ")) {
            chain.doFilter(req, res);
            return;
        }

        try {
            String token = header.substring(7);
            Claims claims = jwtService.validateToken(token);
            String email = claims.getSubject();
            String role  = claims.get("role", String.class);

            UsernamePasswordAuthenticationToken auth =
                    new UsernamePasswordAuthenticationToken(
                            email, null,
                            List.of(new SimpleGrantedAuthority("ROLE_" + role))
                    );
            SecurityContextHolder.getContext().setAuthentication(auth);

        } catch (JwtException e) {
            log.warn("JWT non valido: {}", e.getMessage());
        }

        chain.doFilter(req, res);
    }
}

XEOF
echo "OK JwtAuthFilter.java"

cat > src/main/java/com/devfly/photostore/config/SecurityConfig.java << 'XEOF'
package com.devfly.photostore.config;

import com.devfly.photostore.repository.UserRepository;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.stereotype.Component;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.OncePerRequestFilter;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;
import java.util.List;

// ─────────────────────────────────────────────────────────────
// SECURITY CONFIG
// ─────────────────────────────────────────────────────────────
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // Webhook Stripe — nessuna auth
                        .requestMatchers("/webhooks/**").permitAll()
                        // Endpoints pubblici
                        .requestMatchers(HttpMethod.GET, "/photos/**").permitAll()
                        .requestMatchers("/auth/**").permitAll()
                        // Checkout pubblico (anche guest)
                        .requestMatchers(HttpMethod.POST, "/orders/checkout").permitAll()
                        .requestMatchers(HttpMethod.GET, "/orders/{orderNumber}").permitAll()
                        // Admin
                        .requestMatchers("/orders/admin/**").hasRole("ADMIN")
                        .requestMatchers("/photos/admin/**").hasRole("ADMIN")
                        // Tutto il resto richiede auth
                        .anyRequest().authenticated()
                )
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
                .build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOriginPatterns(List.of("*"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}

// ─────────────────────────────────────────────────────────────
// JWT SERVICE
// ─────────────────────────────────────────────────────────────
@Component
class JwtService {

    @Value("${app.jwt.secret}")
    private String secret;

    @Value("${app.jwt.expiration}")
    private long expiration;

    private Key getKey() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    public String generateToken(String email, String role) {
        return Jwts.builder()
                .setSubject(email)
                .claim("role", role)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public Claims validateToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
}

// ─────────────────────────────────────────────────────────────
// JWT FILTER
// ─────────────────────────────────────────────────────────────
@Component
@RequiredArgsConstructor
@Slf4j
class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UserRepository userRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest req,
                                    HttpServletResponse res,
                                    FilterChain chain)
            throws java.io.IOException, jakarta.servlet.ServletException {

        String header = req.getHeader("Authorization");
        if (header == null || !header.startsWith("Bearer ")) {
            chain.doFilter(req, res);
            return;
        }

        try {
            String token = header.substring(7);
            Claims claims = jwtService.validateToken(token);
            String email = claims.getSubject();
            String role = claims.get("role", String.class);

            UsernamePasswordAuthenticationToken auth =
                    new UsernamePasswordAuthenticationToken(
                            email, null,
                            List.of(new SimpleGrantedAuthority("ROLE_" + role))
                    );
            SecurityContextHolder.getContext().setAuthentication(auth);
        } catch (JwtException e) {
            log.warn("JWT non valido: {}", e.getMessage());
        }

        chain.doFilter(req, res);
    }
}

XEOF
echo "OK SecurityConfig.java"

cat > src/main/java/com/devfly/photostore/service/AuthService.java << 'XEOF'
package com.devfly.photostore.service;

import com.devfly.photostore.config.JwtService;
import com.devfly.photostore.dto.AuthDto;
import com.devfly.photostore.entity.User;
import com.devfly.photostore.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    // ─────────────────────────────────────────────────────────────────
    // REGISTRAZIONE
    // ─────────────────────────────────────────────────────────────────
    @Transactional
    public AuthDto.AuthResponse register(AuthDto.RegisterRequest req) {
        if (userRepository.existsByEmail(req.getEmail())) {
            throw new IllegalArgumentException("Email già registrata: " + req.getEmail());
        }

        User user = User.builder()
                .email(req.getEmail().toLowerCase().trim())
                .password(passwordEncoder.encode(req.getPassword()))
                .fullName(req.getFullName())
                .phone(req.getPhone())
                .role(User.Role.CUSTOMER)
                .build();

        userRepository.save(user);
        log.info("Nuovo utente registrato: {}", user.getEmail());

        String token = jwtService.generateToken(user.getEmail(), user.getRole().name());

        return AuthDto.AuthResponse.builder()
                .token(token)
                .email(user.getEmail())
                .fullName(user.getFullName())
                .role(user.getRole().name())
                .build();
    }

    // ─────────────────────────────────────────────────────────────────
    // LOGIN
    // ─────────────────────────────────────────────────────────────────
    public AuthDto.AuthResponse login(AuthDto.LoginRequest req) {
        User user = userRepository.findByEmail(req.getEmail().toLowerCase().trim())
                .orElseThrow(() -> new IllegalArgumentException("Credenziali non valide"));

        if (!user.isActive()) {
            throw new IllegalArgumentException("Account disabilitato. Contatta il supporto.");
        }

        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new IllegalArgumentException("Credenziali non valide");
        }

        String token = jwtService.generateToken(user.getEmail(), user.getRole().name());

        return AuthDto.AuthResponse.builder()
                .token(token)
                .email(user.getEmail())
                .fullName(user.getFullName())
                .role(user.getRole().name())
                .build();
    }
}

XEOF
echo "OK AuthService.java"

cat > src/main/java/com/devfly/photostore/service/PricingService.java << 'XEOF'
package com.devfly.photostore.service;

import com.devfly.photostore.entity.PaperType;
import com.devfly.photostore.entity.PrintFormat;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;

@Service
public class PricingService {

    // Costo di spedizione fisso per stampe
    private static final BigDecimal SHIPPING_BASE = new BigDecimal("5.90");
    private static final BigDecimal SHIPPING_PER_ITEM = new BigDecimal("1.50");
    private static final BigDecimal FREE_SHIPPING_THRESHOLD = new BigDecimal("80.00");

    /**
     * Calcola il prezzo finale di una stampa.
     * Prezzo = basePrice × moltiplicatore_formato × moltiplicatore_carta
     */
    public BigDecimal calculatePrintPrice(BigDecimal basePrice,
                                          PrintFormat format,
                                          PaperType paperType) {
        double multiplier = format.getPriceMultiplier() * paperType.getPriceMultiplier();
        return basePrice
                .multiply(BigDecimal.valueOf(multiplier))
                .setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Calcola le spese di spedizione sull'intero ordine.
     * Gratis sopra la soglia FREE_SHIPPING_THRESHOLD.
     */
    public BigDecimal calculateShipping(BigDecimal subtotal, int itemCount) {
        if (subtotal.compareTo(FREE_SHIPPING_THRESHOLD) >= 0) {
            return BigDecimal.ZERO;
        }
        return SHIPPING_BASE
                .add(SHIPPING_PER_ITEM.multiply(BigDecimal.valueOf(itemCount - 1)))
                .setScale(2, RoundingMode.HALF_UP);
    }
}

XEOF
echo "OK PricingService.java"

cat > src/main/java/com/devfly/photostore/service/CloudinaryService.java << 'XEOF'
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

XEOF
echo "OK CloudinaryService.java"

cat > src/main/java/com/devfly/photostore/service/EmailService.java << 'XEOF'
package com.devfly.photostore.service;

import com.devfly.photostore.entity.Order;
import com.devfly.photostore.entity.OrderItem;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;
    private final TemplateEngine templateEngine;

    @Value("${app.mail.from}")
    private String fromEmail;

    @Value("${app.mail.from-name}")
    private String fromName;

    // ─────────────────────────────────────────────────────────────────
    // EMAIL CONFERMA ORDINE → CLIENTE
    // ─────────────────────────────────────────────────────────────────
    @Async
    public void sendOrderConfirmation(Order order) {
        try {
            Context ctx = new Context();
            ctx.setVariable("order", order);
            ctx.setVariable("customerName", order.getCustomerName().split(" ")[0]);

            String html = templateEngine.process("email/order-confirmation", ctx);

            sendEmail(
                order.getCustomerEmail(),
                "✅ Ordine confermato — " + order.getOrderNumber(),
                html
            );
            log.info("Email conferma inviata a {}", order.getCustomerEmail());
        } catch (Exception e) {
            log.error("Errore invio email conferma ordine {}: {}", order.getOrderNumber(), e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // EMAIL SPEDIZIONE → CLIENTE
    // ─────────────────────────────────────────────────────────────────
    @Async
    public void sendShippingNotification(Order order) {
        try {
            Context ctx = new Context();
            ctx.setVariable("order", order);
            ctx.setVariable("customerName", order.getCustomerName().split(" ")[0]);

            String html = templateEngine.process("email/shipping-notification", ctx);

            sendEmail(
                order.getCustomerEmail(),
                "🚚 Il tuo ordine è stato spedito — " + order.getOrderNumber(),
                html
            );
        } catch (Exception e) {
            log.error("Errore invio email spedizione {}: {}", order.getOrderNumber(), e.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // HELPER
    // ─────────────────────────────────────────────────────────────────
    private void sendEmail(String to, String subject, String htmlBody) throws Exception {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
        helper.setFrom(fromEmail, fromName);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(htmlBody, true);
        mailSender.send(message);
    }
}

XEOF
echo "OK EmailService.java"

cat > src/main/java/com/devfly/photostore/service/PhotoService.java << 'XEOF'
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

XEOF
echo "OK PhotoService.java"

cat > src/main/java/com/devfly/photostore/service/OrderService.java << 'XEOF'
package com.devfly.photostore.service;

import com.devfly.photostore.dto.OrderDto;
import com.devfly.photostore.entity.*;
import com.devfly.photostore.exception.ResourceNotFoundException;
import com.devfly.photostore.repository.OrderRepository;
import com.devfly.photostore.repository.PhotoRepository;
import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderService {

    private final OrderRepository orderRepository;
    private final PhotoRepository photoRepository;
    private final PricingService pricingService;
    private final EmailService emailService;

    @Value("${stripe.api.key}")
    private String stripeApiKey;

    @Value("${app.frontend-url}")
    private String frontendUrl;

    @PostConstruct
    public void initStripe() {
        Stripe.apiKey = stripeApiKey;
    }

    // ─────────────────────────────────────────────────────────────────
    // CREA ORDINE + SESSIONE STRIPE CHECKOUT
    // ─────────────────────────────────────────────────────────────────
    @Transactional
    public OrderDto.CheckoutResponse createOrderAndCheckout(OrderDto.CreateRequest req) {

        // 1. Costruisci l'ordine
        Order order = Order.builder()
                .customerEmail(req.getCustomerEmail())
                .customerName(req.getCustomerName())
                .customerPhone(req.getCustomerPhone())
                .shippingAddress(req.getShippingAddress())
                .shippingCity(req.getShippingCity())
                .shippingZip(req.getShippingZip())
                .shippingCountry(req.getShippingCountry())
                .notes(req.getNotes())
                .status(OrderStatus.PENDING_PAYMENT)
                .build();

        // 2. Costruisci le righe e calcola i totali
        List<OrderItem> items = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        int totalItems = 0;

        for (OrderDto.ItemRequest itemReq : req.getItems()) {
            Photo photo = photoRepository.findById(itemReq.getPhotoId())
                    .orElseThrow(() -> new ResourceNotFoundException(
                            "Foto non trovata con id: " + itemReq.getPhotoId()));

            BigDecimal unitPrice = pricingService.calculatePrintPrice(
                    photo.getBasePrice(),
                    itemReq.getPrintFormat(),
                    itemReq.getPaperType()
            );
            BigDecimal lineTotal = unitPrice.multiply(
                    BigDecimal.valueOf(itemReq.getQuantity())
            );

            OrderItem item = OrderItem.builder()
                    .order(order)
                    .photo(photo)
                    .photoTitle(photo.getTitle())
                    .printFormat(itemReq.getPrintFormat())
                    .paperType(itemReq.getPaperType())
                    .quantity(itemReq.getQuantity())
                    .unitPrice(unitPrice)
                    .lineTotal(lineTotal)
                    .previewUrl(photo.getPreviewUrl())
                    .build();

            items.add(item);
            subtotal = subtotal.add(lineTotal);
            totalItems += itemReq.getQuantity();
        }

        order.setItems(items);
        order.setSubtotal(subtotal);

        BigDecimal shippingCost = pricingService.calculateShipping(subtotal, totalItems);
        order.setShippingCost(shippingCost);
        order.setTotalAmount(subtotal.add(shippingCost));

        // 3. Salva ordine (genera orderNumber via @PrePersist)
        Order savedOrder = orderRepository.save(order);

        // 4. Crea sessione Stripe Checkout
        try {
            Session session = createStripeSession(savedOrder);
            savedOrder.setStripeSessionId(session.getId());
            orderRepository.save(savedOrder);

            log.info("Ordine {} creato, sessione Stripe: {}", savedOrder.getOrderNumber(), session.getId());

            return OrderDto.CheckoutResponse.builder()
                    .orderNumber(savedOrder.getOrderNumber())
                    .checkoutUrl(session.getUrl())
                    .totalAmount(savedOrder.getTotalAmount())
                    .build();

        } catch (StripeException e) {
            log.error("Errore Stripe per ordine {}: {}", savedOrder.getOrderNumber(), e.getMessage());
            throw new RuntimeException("Impossibile avviare il pagamento. Riprova tra poco.");
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // COSTRUISCE SESSIONE STRIPE
    // ─────────────────────────────────────────────────────────────────
    private Session createStripeSession(Order order) throws StripeException {

        List<SessionCreateParams.LineItem> lineItems = new ArrayList<>();

        for (OrderItem item : order.getItems()) {
            String description = String.format("Stampa %s — %s | %s",
                    item.getPrintFormat().getDisplaySize(),
                    item.getPaperType().getDisplayName(),
                    item.getPaperType().getDescription()
            );

            lineItems.add(SessionCreateParams.LineItem.builder()
                    .setQuantity((long) item.getQuantity())
                    .setPriceData(SessionCreateParams.LineItem.PriceData.builder()
                            .setCurrency("eur")
                            .setUnitAmount(item.getUnitPrice()
                                    .multiply(BigDecimal.valueOf(100))
                                    .setScale(0, RoundingMode.HALF_UP)
                                    .longValue())
                            .setProductData(SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                    .setName(item.getPhotoTitle())
                                    .setDescription(description)
                                    .addImage(item.getPreviewUrl())
                                    .build())
                            .build())
                    .build());
        }

        // Aggiungi spedizione se > 0
        if (order.getShippingCost().compareTo(BigDecimal.ZERO) > 0) {
            lineItems.add(SessionCreateParams.LineItem.builder()
                    .setQuantity(1L)
                    .setPriceData(SessionCreateParams.LineItem.PriceData.builder()
                            .setCurrency("eur")
                            .setUnitAmount(order.getShippingCost()
                                    .multiply(BigDecimal.valueOf(100))
                                    .setScale(0, RoundingMode.HALF_UP)
                                    .longValue())
                            .setProductData(SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                    .setName("Spedizione")
                                    .setDescription("Consegna in 5-7 giorni lavorativi")
                                    .build())
                            .build())
                    .build());
        }

        return Session.create(SessionCreateParams.builder()
                .setMode(SessionCreateParams.Mode.PAYMENT)
                .addAllLineItem(lineItems)
                .setCustomerEmail(order.getCustomerEmail())
                .putMetadata("order_number", order.getOrderNumber())
                .setSuccessUrl(frontendUrl + "/checkout/success?order=" + order.getOrderNumber())
                .setCancelUrl(frontendUrl + "/checkout/cancel?order=" + order.getOrderNumber())
                .build());
    }

    // ─────────────────────────────────────────────────────────────────
    // WEBHOOK: PAGAMENTO CONFERMATO
    // ─────────────────────────────────────────────────────────────────
    @Transactional
    public void handlePaymentSuccess(String sessionId) {
        Order order = orderRepository.findByStripeSessionId(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Ordine non trovato per sessione: " + sessionId));

        if (order.getStatus() == OrderStatus.PENDING_PAYMENT) {
            order.setStatus(OrderStatus.PAID);
            order.setPaidAt(java.time.LocalDateTime.now());
            orderRepository.save(order);

            // Incrementa contatori nelle foto
            order.getItems().forEach(item ->
                photoRepository.findById(item.getPhoto().getId()).ifPresent(p -> {
                    p.setOrderCount(p.getOrderCount() + item.getQuantity());
                    photoRepository.save(p);
                })
            );

            // Invia email di conferma al cliente (asincrono)
            emailService.sendOrderConfirmation(order);

            log.info("Ordine {} pagato con successo.", order.getOrderNumber());
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // AGGIORNA STATO (Admin)
    // ─────────────────────────────────────────────────────────────────
    @Transactional
    public OrderDto.Response updateStatus(String orderNumber, OrderStatus newStatus) {
        Order order = orderRepository.findByOrderNumber(orderNumber)
                .orElseThrow(() -> new ResourceNotFoundException("Ordine non trovato: " + orderNumber));
        order.setStatus(newStatus);

        // Notifica email per spedizione
        if (newStatus == OrderStatus.SHIPPED) {
            emailService.sendShippingNotification(order);
        }

        return toResponse(orderRepository.save(order));
    }

    // ─────────────────────────────────────────────────────────────────
    // QUERY
    // ─────────────────────────────────────────────────────────────────
    public OrderDto.Response getByOrderNumber(String orderNumber) {
        return toResponse(orderRepository.findByOrderNumber(orderNumber)
                .orElseThrow(() -> new ResourceNotFoundException("Ordine non trovato: " + orderNumber)));
    }

    public Page<OrderDto.Response> getOrdersByEmail(String email, Pageable pageable) {
        return orderRepository.findByCustomerEmailOrderByCreatedAtDesc(email, pageable)
                .map(this::toResponse);
    }

    public Page<OrderDto.Response> getAllOrders(Pageable pageable) {
        return orderRepository.findAll(pageable).map(this::toResponse);
    }

    // ─────────────────────────────────────────────────────────────────
    // MAPPING
    // ─────────────────────────────────────────────────────────────────
    private OrderDto.Response toResponse(Order o) {
        List<OrderDto.ItemResponse> itemResponses = o.getItems().stream()
                .map(i -> OrderDto.ItemResponse.builder()
                        .photoId(i.getPhoto().getId())
                        .photoTitle(i.getPhotoTitle())
                        .previewUrl(i.getPreviewUrl())
                        .printFormat(i.getPrintFormat().getCode())
                        .formatSize(i.getPrintFormat().getDisplaySize())
                        .paperType(i.getPaperType().getDisplayName())
                        .quantity(i.getQuantity())
                        .unitPrice(i.getUnitPrice())
                        .lineTotal(i.getLineTotal())
                        .build())
                .toList();

        return OrderDto.Response.builder()
                .id(o.getId())
                .orderNumber(o.getOrderNumber())
                .customerEmail(o.getCustomerEmail())
                .customerName(o.getCustomerName())
                .shippingAddress(o.getShippingAddress())
                .shippingCity(o.getShippingCity())
                .shippingZip(o.getShippingZip())
                .shippingCountry(o.getShippingCountry())
                .items(itemResponses)
                .subtotal(o.getSubtotal())
                .shippingCost(o.getShippingCost())
                .totalAmount(o.getTotalAmount())
                .status(o.getStatus())
                .createdAt(o.getCreatedAt())
                .paidAt(o.getPaidAt())
                .build();
    }
}

XEOF
echo "OK OrderService.java"

cat > src/main/java/com/devfly/photostore/controller/AuthController.java << 'XEOF'
package com.devfly.photostore.controller;

import com.devfly.photostore.dto.AuthDto;
import com.devfly.photostore.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "${app.frontend-url}")
public class AuthController {

    private final AuthService authService;

    /**
     * POST /api/auth/register
     * Body: { "email": "...", "password": "...", "fullName": "..." }
     */
    @PostMapping("/register")
    public ResponseEntity<AuthDto.AuthResponse> register(
            @Valid @RequestBody AuthDto.RegisterRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(authService.register(req));
    }

    /**
     * POST /api/auth/login
     * Body: { "email": "...", "password": "..." }
     * Returns JWT token
     */
    @PostMapping("/login")
    public ResponseEntity<AuthDto.AuthResponse> login(
            @Valid @RequestBody AuthDto.LoginRequest req) {
        return ResponseEntity.ok(authService.login(req));
    }

    /**
     * GET /api/auth/me
     * Ritorna info utente loggato (dal token)
     */
    @GetMapping("/me")
    public ResponseEntity<String> me(
            org.springframework.security.core.Authentication auth) {
        return ResponseEntity.ok(auth.getName());
    }
}

XEOF
echo "OK AuthController.java"

cat > src/main/java/com/devfly/photostore/controller/PhotoOrderController.java << 'XEOF'
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

XEOF
echo "OK PhotoOrderController.java"

cat > src/main/java/com/devfly/photostore/controller/AdminPhotoController.java << 'XEOF'
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

XEOF
echo "OK AdminPhotoController.java"

cat > src/main/java/com/devfly/photostore/controller/StripeWebhookController.java << 'XEOF'
package com.devfly.photostore.controller;

import com.devfly.photostore.service.OrderService;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.model.Event;
import com.stripe.model.checkout.Session;
import com.stripe.net.Webhook;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/webhooks")
@RequiredArgsConstructor
@Slf4j
public class StripeWebhookController {

    private final OrderService orderService;

    @Value("${stripe.webhook.secret}")
    private String webhookSecret;

    /**
     * Stripe invia eventi qui dopo ogni pagamento.
     * Bisogna registrare questo endpoint nel Dashboard Stripe:
     * https://dashboard.stripe.com/webhooks
     *
     * Evento da abilitare: checkout.session.completed
     */
    @PostMapping("/stripe")
    public ResponseEntity<String> handleStripeWebhook(
            @RequestBody String payload,
            @RequestHeader("Stripe-Signature") String sigHeader) {

        Event event;
        try {
            event = Webhook.constructEvent(payload, sigHeader, webhookSecret);
        } catch (SignatureVerificationException e) {
            log.warn("Firma Stripe non valida: {}", e.getMessage());
            return ResponseEntity.badRequest().body("Firma non valida");
        }

        switch (event.getType()) {

            case "checkout.session.completed" -> {
                Session session = (Session) event.getDataObjectDeserializer()
                        .getObject().orElseThrow();
                log.info("Pagamento completato per sessione: {}", session.getId());
                orderService.handlePaymentSuccess(session.getId());
            }

            case "checkout.session.expired" -> {
                log.info("Sessione Stripe scaduta: {}",
                        event.getDataObjectDeserializer().getObject()
                                .map(o -> ((Session) o).getId()).orElse("?"));
            }

            default -> log.debug("Evento Stripe ignorato: {}", event.getType());
        }

        return ResponseEntity.ok("OK");
    }
}

XEOF
echo "OK StripeWebhookController.java"

cat > src/main/resources/templates/email/order-confirmation.html << 'XEOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="it">
<head>
  <meta charset="UTF-8"/>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Helvetica Neue', Arial, sans-serif; background: #f5f5f7; color: #1d1d1f; }
    .wrapper { max-width: 600px; margin: 0 auto; background: #fff; }
    .header {
      background: #0a0a0f;
      padding: 40px 48px;
      text-align: center;
    }
    .logo { font-size: 28px; font-weight: 900; color: #00e5ff; letter-spacing: 4px; }
    .logo span { color: #ff4d6d; }
    .header-sub { color: #6b6b80; font-size: 12px; letter-spacing: 3px; text-transform: uppercase; margin-top: 8px; }
    .hero { background: #0a0a0f; padding: 0 48px 48px; text-align: center; border-bottom: 2px solid #00e5ff; }
    .checkmark { font-size: 64px; }
    .hero h1 { color: #fff; font-size: 26px; margin: 16px 0 8px; letter-spacing: 1px; }
    .hero p { color: #6b6b80; font-size: 14px; line-height: 1.6; }
    .order-number {
      display: inline-block;
      background: #00e5ff;
      color: #0a0a0f;
      font-weight: 700;
      font-size: 13px;
      letter-spacing: 3px;
      padding: 8px 20px;
      margin-top: 16px;
      border-radius: 2px;
    }
    .section { padding: 36px 48px; }
    .section-title {
      font-size: 11px;
      font-weight: 700;
      letter-spacing: 3px;
      text-transform: uppercase;
      color: #6b6b80;
      margin-bottom: 20px;
      border-bottom: 1px solid #e5e5ea;
      padding-bottom: 12px;
    }
    .item {
      display: flex;
      gap: 16px;
      padding: 16px 0;
      border-bottom: 1px solid #f2f2f2;
      align-items: center;
    }
    .item-thumb {
      width: 80px; height: 60px;
      object-fit: cover;
      border-radius: 4px;
      background: #e5e5ea;
      flex-shrink: 0;
    }
    .item-info { flex: 1; }
    .item-title { font-size: 15px; font-weight: 600; margin-bottom: 4px; }
    .item-specs { font-size: 12px; color: #6b6b80; line-height: 1.7; }
    .item-price { font-size: 16px; font-weight: 700; color: #0a0a0f; white-space: nowrap; }
    .totals { background: #f5f5f7; border-radius: 8px; padding: 20px; margin-top: 8px; }
    .total-row { display: flex; justify-content: space-between; font-size: 14px; padding: 5px 0; }
    .total-row.main { font-size: 18px; font-weight: 700; border-top: 1px solid #d1d1d6; margin-top: 8px; padding-top: 12px; }
    .shipping-info { background: #f0f9ff; border-left: 3px solid #00e5ff; padding: 16px 20px; border-radius: 0 8px 8px 0; }
    .shipping-info p { font-size: 13px; line-height: 1.7; color: #333; }
    .shipping-info strong { color: #0a0a0f; }
    .address-block { background: #f5f5f7; padding: 16px 20px; border-radius: 8px; font-size: 14px; line-height: 2; }
    .cta-block { text-align: center; padding: 36px 48px; background: #0a0a0f; }
    .cta-block p { color: #6b6b80; font-size: 13px; margin-bottom: 20px; }
    .btn {
      display: inline-block;
      background: #a8ff3e;
      color: #0a0a0f;
      font-weight: 700;
      font-size: 13px;
      letter-spacing: 2px;
      text-transform: uppercase;
      padding: 14px 36px;
      text-decoration: none;
      border-radius: 2px;
    }
    .footer { background: #0a0a0f; padding: 24px 48px; text-align: center; border-top: 1px solid #1e1e2e; }
    .footer p { color: #3a3a4a; font-size: 11px; line-height: 1.8; }
    .footer a { color: #00e5ff; text-decoration: none; }
  </style>
</head>
<body>
<div class="wrapper">

  <!-- HEADER -->
  <div class="header">
    <div class="logo">DEV<span>&amp;</span>FLY</div>
    <div class="header-sub">PhotoStore</div>
  </div>

  <!-- HERO -->
  <div class="hero">
    <div class="checkmark">✅</div>
    <h1>Ordine Confermato!</h1>
    <p th:text="|Ciao ${customerName}, il tuo pagamento è andato a buon fine.|"></p>
    <p>Le tue stampe sono ora in elaborazione.</p>
    <div class="order-number" th:text="${order.orderNumber}"></div>
  </div>

  <!-- ARTICOLI -->
  <div class="section">
    <div class="section-title">Articoli ordinati</div>
    <div th:each="item : ${order.items}">
      <div class="item">
        <img class="item-thumb"
             th:src="${item.previewUrl}"
             th:alt="${item.photoTitle}"
             onerror="this.style.display='none'"/>
        <div class="item-info">
          <div class="item-title" th:text="${item.photoTitle}"></div>
          <div class="item-specs">
            <span th:text="|Formato: ${item.printFormat.displaySize}|"></span><br/>
            <span th:text="|Carta: ${item.paperType.displayName} — ${item.paperType.description}|"></span><br/>
            <span th:text="|Quantità: ${item.quantity}|"></span>
          </div>
        </div>
        <div class="item-price" th:text="|€ ${#numbers.formatDecimal(item.lineTotal, 1, 2)}|"></div>
      </div>
    </div>

    <!-- TOTALI -->
    <div class="totals">
      <div class="total-row">
        <span>Subtotale</span>
        <span th:text="|€ ${#numbers.formatDecimal(order.subtotal, 1, 2)}|"></span>
      </div>
      <div class="total-row">
        <span>Spedizione</span>
        <span th:text="${order.shippingCost.compareTo(T(java.math.BigDecimal).ZERO) == 0} ? 'Gratuita 🎉' : |€ ${#numbers.formatDecimal(order.shippingCost, 1, 2)}|"></span>
      </div>
      <div class="total-row main">
        <span>Totale pagato</span>
        <span th:text="|€ ${#numbers.formatDecimal(order.totalAmount, 1, 2)}|"></span>
      </div>
    </div>
  </div>

  <!-- INDIRIZZO SPEDIZIONE -->
  <div class="section" style="padding-top:0;">
    <div class="section-title">Indirizzo di spedizione</div>
    <div class="address-block">
      <strong th:text="${order.customerName}"></strong><br/>
      <span th:text="${order.shippingAddress}"></span><br/>
      <span th:text="|${order.shippingZip} ${order.shippingCity} (${order.shippingCountry})|"></span>
    </div>
  </div>

  <!-- INFO STAMPA -->
  <div class="section" style="padding-top:0;">
    <div class="shipping-info">
      <p>
        <strong>⏱ Tempi di consegna stimati:</strong> 5–7 giorni lavorativi.<br/>
        Le tue stampe vengono realizzate su ordinazione con le massime attenzioni qualitative.<br/>
        Riceverai un'email con il tracking appena il pacco viene affidato al corriere.
      </p>
    </div>
  </div>

  <!-- CTA -->
  <div class="cta-block">
    <p>Vuoi esplorare altre fotografie nel catalogo?</p>
    <a href="http://localhost:3000/shop" class="btn">Esplora il Catalogo →</a>
  </div>

  <!-- FOOTER -->
  <div class="footer">
    <p>
      DEV&amp;FLY PhotoStore — <a href="mailto:hello@devfly.it">hello@devfly.it</a><br/>
      © 2025 DEV&amp;FLY. Tutti i diritti riservati.<br/>
      Hai domande? Rispondi a questa email o contattaci su <a href="#">WhatsApp</a>.
    </p>
  </div>

</div>
</body>
</html>

XEOF
echo "OK order-confirmation.html"

cat > src/main/resources/templates/email/shipping-notification.html << 'XEOF'
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org" lang="it">
<head>
  <meta charset="UTF-8"/>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Helvetica Neue', Arial, sans-serif; background: #f5f5f7; color: #1d1d1f; }
    .wrapper { max-width: 600px; margin: 0 auto; background: #fff; }
    .header { background: #0a0a0f; padding: 40px 48px; text-align: center; }
    .logo { font-size: 28px; font-weight: 900; color: #00e5ff; letter-spacing: 4px; }
    .logo span { color: #ff4d6d; }
    .hero {
      background: linear-gradient(135deg, #0a0a0f, #1a1a28);
      padding: 48px;
      text-align: center;
      border-bottom: 2px solid #a8ff3e;
    }
    .truck { font-size: 72px; }
    .hero h1 { color: #fff; font-size: 26px; margin: 16px 0 8px; letter-spacing: 1px; }
    .hero p { color: #6b6b80; font-size: 14px; line-height: 1.7; }
    .order-chip {
      display: inline-block;
      background: #a8ff3e;
      color: #0a0a0f;
      font-weight: 700;
      font-size: 13px;
      letter-spacing: 3px;
      padding: 8px 20px;
      margin-top: 16px;
      border-radius: 2px;
    }
    .section { padding: 36px 48px; }
    .section-title {
      font-size: 11px; font-weight: 700; letter-spacing: 3px;
      text-transform: uppercase; color: #6b6b80;
      margin-bottom: 20px; border-bottom: 1px solid #e5e5ea; padding-bottom: 12px;
    }
    .timeline { display: flex; flex-direction: column; gap: 0; }
    .step {
      display: flex; gap: 16px; align-items: flex-start;
      padding: 16px 0; position: relative;
    }
    .step-icon {
      width: 36px; height: 36px; border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      font-size: 16px; flex-shrink: 0;
    }
    .step-icon.done { background: #a8ff3e; color: #0a0a0f; }
    .step-icon.active { background: #00e5ff; color: #0a0a0f; }
    .step-icon.pending { background: #e5e5ea; color: #6b6b80; }
    .step-info { flex: 1; }
    .step-label { font-size: 14px; font-weight: 600; margin-bottom: 2px; }
    .step-desc { font-size: 12px; color: #6b6b80; }
    .info-box {
      background: #f0fff4;
      border-left: 3px solid #a8ff3e;
      padding: 16px 20px;
      border-radius: 0 8px 8px 0;
      font-size: 13px; line-height: 1.8;
    }
    .address-block {
      background: #f5f5f7; padding: 16px 20px;
      border-radius: 8px; font-size: 14px; line-height: 2;
    }
    .cta-block { text-align: center; padding: 36px 48px; background: #0a0a0f; }
    .cta-block p { color: #6b6b80; font-size: 13px; margin-bottom: 20px; }
    .btn {
      display: inline-block; background: #00e5ff; color: #0a0a0f;
      font-weight: 700; font-size: 13px; letter-spacing: 2px;
      text-transform: uppercase; padding: 14px 36px;
      text-decoration: none; border-radius: 2px;
    }
    .footer { background: #0a0a0f; padding: 24px 48px; text-align: center; border-top: 1px solid #1e1e2e; }
    .footer p { color: #3a3a4a; font-size: 11px; line-height: 1.8; }
    .footer a { color: #00e5ff; text-decoration: none; }
  </style>
</head>
<body>
<div class="wrapper">

  <div class="header">
    <div class="logo">DEV<span>&amp;</span>FLY</div>
  </div>

  <div class="hero">
    <div class="truck">🚚</div>
    <h1>Il tuo ordine è in viaggio!</h1>
    <p th:text="|Ciao ${customerName}, le tue stampe sono state affidate al corriere.|"></p>
    <div class="order-chip" th:text="${order.orderNumber}"></div>
  </div>

  <!-- TRACKING TIMELINE -->
  <div class="section">
    <div class="section-title">Stato della spedizione</div>
    <div class="timeline">
      <div class="step">
        <div class="step-icon done">✓</div>
        <div class="step-info">
          <div class="step-label">Ordine ricevuto</div>
          <div class="step-desc" th:text="${#temporals.format(order.createdAt, 'dd/MM/yyyy HH:mm')}"></div>
        </div>
      </div>
      <div class="step">
        <div class="step-icon done">✓</div>
        <div class="step-info">
          <div class="step-label">Pagamento confermato</div>
          <div class="step-desc" th:text="${#temporals.format(order.paidAt, 'dd/MM/yyyy HH:mm')}"></div>
        </div>
      </div>
      <div class="step">
        <div class="step-icon done">✓</div>
        <div class="step-info">
          <div class="step-label">Stampa completata</div>
          <div class="step-desc">Le tue foto sono state stampate con cura</div>
        </div>
      </div>
      <div class="step">
        <div class="step-icon active">🚚</div>
        <div class="step-info">
          <div class="step-label">In consegna</div>
          <div class="step-desc">Il pacco è stato affidato al corriere</div>
        </div>
      </div>
      <div class="step">
        <div class="step-icon pending">📦</div>
        <div class="step-info">
          <div class="step-label">Consegnato</div>
          <div class="step-desc">Stima: 2–3 giorni lavorativi</div>
        </div>
      </div>
    </div>
  </div>

  <!-- INDIRIZZO -->
  <div class="section" style="padding-top:0;">
    <div class="section-title">Indirizzo di consegna</div>
    <div class="address-block">
      <strong th:text="${order.customerName}"></strong><br/>
      <span th:text="${order.shippingAddress}"></span><br/>
      <span th:text="|${order.shippingZip} ${order.shippingCity}|"></span>
    </div>
  </div>

  <!-- INFO -->
  <div class="section" style="padding-top:0;">
    <div class="info-box">
      📦 <strong>Attenzione alla consegna:</strong> il corriere tenterà la consegna in orario lavorativo.
      In caso di assenza, troverai un avviso e potrai concordare una nuova consegna.<br/><br/>
      Per qualsiasi problema contattaci su <a href="mailto:hello@devfly.it">hello@devfly.it</a> indicando
      il numero ordine <strong th:text="${order.orderNumber}"></strong>.
    </div>
  </div>

  <div class="cta-block">
    <p>Mentre aspetti, esplora altri scatti!</p>
    <a href="http://localhost:3000/shop" class="btn">Scopri il catalogo →</a>
  </div>

  <div class="footer">
    <p>
      DEV&amp;FLY PhotoStore — <a href="mailto:hello@devfly.it">hello@devfly.it</a><br/>
      © 2025 DEV&amp;FLY. Tutti i diritti riservati.
    </p>
  </div>

</div>
</body>
</html>

XEOF
echo "OK shipping-notification.html"

cat > Dockerfile << 'XEOF'
# ── Build stage ──────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
# Scarica dipendenze in cache layer separato
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn clean package -DskipTests -q

# ── Runtime stage ─────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Utente non-root per sicurezza
RUN addgroup -S spring && adduser -S spring -G spring
USER spring

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-jar", "app.jar"]

XEOF
echo "OK Dockerfile"

echo ""
echo "========================================"
echo "TUTTI I FILE CREATI CON SUCCESSO!"
echo "========================================"
echo ""
echo "Esegui ora:"
echo "  git add ."
echo "  git commit -m prima-versione"
echo "  git push"