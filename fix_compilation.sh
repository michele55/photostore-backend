#!/bin/bash
set -e
echo "Fix compilazione - riscrittura file senza Lombok implicito..."

# 1. Fix AuthDto - rimuovi PhotoDto da dentro
cat > src/main/java/com/devfly/photostore/dto/AuthDto.java << 'XEOF'
package com.devfly.photostore.dto;

import jakarta.validation.constraints.*;

public class AuthDto {

    public static class RegisterRequest {
        @NotBlank @Email
        private String email;
        @NotBlank @Size(min = 8)
        private String password;
        @NotBlank
        private String fullName;
        private String phone;
        public String getEmail() { return email; }
        public String getPassword() { return password; }
        public String getFullName() { return fullName; }
        public String getPhone() { return phone; }
    }

    public static class LoginRequest {
        @NotBlank @Email
        private String email;
        @NotBlank
        private String password;
        public String getEmail() { return email; }
        public String getPassword() { return password; }
    }

    public static class AuthResponse {
        private String token;
        private String email;
        private String fullName;
        private String role;
        public AuthResponse(String token, String email, String fullName, String role) {
            this.token = token; this.email = email;
            this.fullName = fullName; this.role = role;
        }
        public String getToken() { return token; }
        public String getEmail() { return email; }
        public String getFullName() { return fullName; }
        public String getRole() { return role; }
    }
}
XEOF
echo "OK AuthDto.java"

# 2. Fix PhotoDto - file separato corretto
cat > src/main/java/com/devfly/photostore/dto/PhotoDto.java << 'XEOF'
package com.devfly.photostore.dto;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class PhotoDto {

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
        public Response() {}
        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public String getTitle() { return title; }
        public void setTitle(String title) { this.title = title; }
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        public String getPreviewUrl() { return previewUrl; }
        public void setPreviewUrl(String previewUrl) { this.previewUrl = previewUrl; }
        public BigDecimal getBasePrice() { return basePrice; }
        public void setBasePrice(BigDecimal basePrice) { this.basePrice = basePrice; }
        public String getCategory() { return category; }
        public void setCategory(String category) { this.category = category; }
        public List<String> getTags() { return tags; }
        public void setTags(List<String> tags) { this.tags = tags; }
        public String getCamera() { return camera; }
        public void setCamera(String camera) { this.camera = camera; }
        public String getLocation() { return location; }
        public void setLocation(String location) { this.location = location; }
        public Integer getViewCount() { return viewCount; }
        public void setViewCount(Integer viewCount) { this.viewCount = viewCount; }
        public List<PrintOptionDto> getPrintOptions() { return printOptions; }
        public void setPrintOptions(List<PrintOptionDto> printOptions) { this.printOptions = printOptions; }
        public LocalDateTime getCreatedAt() { return createdAt; }
        public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    }

    public static class CreateRequest {
        @NotBlank private String title;
        private String description;
        @NotNull private BigDecimal basePrice;
        @NotBlank private String category;
        private List<String> tags;
        private String camera;
        private String lens;
        private String location;
        public String getTitle() { return title; }
        public String getDescription() { return description; }
        public BigDecimal getBasePrice() { return basePrice; }
        public String getCategory() { return category; }
        public List<String> getTags() { return tags; }
        public String getCamera() { return camera; }
        public String getLens() { return lens; }
        public String getLocation() { return location; }
    }

    public static class PrintOptionDto {
        private String formatCode;
        private String formatDisplay;
        private String paperName;
        private String paperDescription;
        private BigDecimal finalPrice;
        public PrintOptionDto() {}
        public PrintOptionDto(String formatCode, String formatDisplay, String paperName, String paperDescription, BigDecimal finalPrice) {
            this.formatCode = formatCode; this.formatDisplay = formatDisplay;
            this.paperName = paperName; this.paperDescription = paperDescription;
            this.finalPrice = finalPrice;
        }
        public String getFormatCode() { return formatCode; }
        public String getFormatDisplay() { return formatDisplay; }
        public String getPaperName() { return paperName; }
        public String getPaperDescription() { return paperDescription; }
        public BigDecimal getFinalPrice() { return finalPrice; }
    }
}
XEOF
echo "OK PhotoDto.java"

# 3. Fix OrderDto
cat > src/main/java/com/devfly/photostore/dto/OrderDto.java << 'XEOF'
package com.devfly.photostore.dto;

import com.devfly.photostore.entity.OrderStatus;
import com.devfly.photostore.entity.PaperType;
import com.devfly.photostore.entity.PrintFormat;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class OrderDto {

    public static class CreateRequest {
        @NotBlank @Email private String customerEmail;
        @NotBlank private String customerName;
        private String customerPhone;
        @NotBlank private String shippingAddress;
        @NotBlank private String shippingCity;
        @NotBlank @Size(min=5,max=5) private String shippingZip;
        private String shippingCountry = "IT";
        private String notes;
        @NotEmpty @Valid private List<ItemRequest> items;
        public String getCustomerEmail() { return customerEmail; }
        public String getCustomerName() { return customerName; }
        public String getCustomerPhone() { return customerPhone; }
        public String getShippingAddress() { return shippingAddress; }
        public String getShippingCity() { return shippingCity; }
        public String getShippingZip() { return shippingZip; }
        public String getShippingCountry() { return shippingCountry; }
        public String getNotes() { return notes; }
        public List<ItemRequest> getItems() { return items; }
    }

    public static class ItemRequest {
        @NotNull private Long photoId;
        @NotNull private PrintFormat printFormat;
        @NotNull private PaperType paperType;
        @Min(1) @Max(10) private Integer quantity = 1;
        public Long getPhotoId() { return photoId; }
        public PrintFormat getPrintFormat() { return printFormat; }
        public PaperType getPaperType() { return paperType; }
        public Integer getQuantity() { return quantity; }
    }

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
        private String checkoutUrl;
        private LocalDateTime createdAt;
        private LocalDateTime paidAt;
        public Response() {}
        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public String getOrderNumber() { return orderNumber; }
        public void setOrderNumber(String orderNumber) { this.orderNumber = orderNumber; }
        public String getCustomerEmail() { return customerEmail; }
        public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }
        public String getCustomerName() { return customerName; }
        public void setCustomerName(String customerName) { this.customerName = customerName; }
        public String getShippingAddress() { return shippingAddress; }
        public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }
        public String getShippingCity() { return shippingCity; }
        public void setShippingCity(String shippingCity) { this.shippingCity = shippingCity; }
        public String getShippingZip() { return shippingZip; }
        public void setShippingZip(String shippingZip) { this.shippingZip = shippingZip; }
        public String getShippingCountry() { return shippingCountry; }
        public void setShippingCountry(String shippingCountry) { this.shippingCountry = shippingCountry; }
        public List<ItemResponse> getItems() { return items; }
        public void setItems(List<ItemResponse> items) { this.items = items; }
        public BigDecimal getSubtotal() { return subtotal; }
        public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
        public BigDecimal getShippingCost() { return shippingCost; }
        public void setShippingCost(BigDecimal shippingCost) { this.shippingCost = shippingCost; }
        public BigDecimal getTotalAmount() { return totalAmount; }
        public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
        public OrderStatus getStatus() { return status; }
        public void setStatus(OrderStatus status) { this.status = status; }
        public String getCheckoutUrl() { return checkoutUrl; }
        public void setCheckoutUrl(String checkoutUrl) { this.checkoutUrl = checkoutUrl; }
        public LocalDateTime getCreatedAt() { return createdAt; }
        public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
        public LocalDateTime getPaidAt() { return paidAt; }
        public void setPaidAt(LocalDateTime paidAt) { this.paidAt = paidAt; }
    }

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
        public ItemResponse() {}
        public Long getPhotoId() { return photoId; }
        public void setPhotoId(Long photoId) { this.photoId = photoId; }
        public String getPhotoTitle() { return photoTitle; }
        public void setPhotoTitle(String photoTitle) { this.photoTitle = photoTitle; }
        public String getPreviewUrl() { return previewUrl; }
        public void setPreviewUrl(String previewUrl) { this.previewUrl = previewUrl; }
        public String getPrintFormat() { return printFormat; }
        public void setPrintFormat(String printFormat) { this.printFormat = printFormat; }
        public String getFormatSize() { return formatSize; }
        public void setFormatSize(String formatSize) { this.formatSize = formatSize; }
        public String getPaperType() { return paperType; }
        public void setPaperType(String paperType) { this.paperType = paperType; }
        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }
        public BigDecimal getUnitPrice() { return unitPrice; }
        public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
        public BigDecimal getLineTotal() { return lineTotal; }
        public void setLineTotal(BigDecimal lineTotal) { this.lineTotal = lineTotal; }
    }

    public static class CheckoutResponse {
        private String orderNumber;
        private String checkoutUrl;
        private BigDecimal totalAmount;
        public CheckoutResponse(String orderNumber, String checkoutUrl, BigDecimal totalAmount) {
            this.orderNumber = orderNumber; this.checkoutUrl = checkoutUrl; this.totalAmount = totalAmount;
        }
        public String getOrderNumber() { return orderNumber; }
        public String getCheckoutUrl() { return checkoutUrl; }
        public BigDecimal getTotalAmount() { return totalAmount; }
    }
}
XEOF
echo "OK OrderDto.java"

# 4. Fix User entity - getter/setter espliciti
cat > src/main/java/com/devfly/photostore/entity/User.java << 'XEOF'
package com.devfly.photostore.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
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
    private Role role = Role.CUSTOMER;
    @Column(name = "active")
    private boolean active = true;
    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public User() {}

    public enum Role { CUSTOMER, ADMIN }

    public Long getId() { return id; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
XEOF
echo "OK User.java"

# 5. Fix Order entity
cat > src/main/java/com/devfly/photostore/entity/Order.java << 'XEOF'
package com.devfly.photostore.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "orders")
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(name = "order_number", unique = true, nullable = false)
    private String orderNumber;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;
    @Column(name = "customer_email", nullable = false)
    private String customerEmail;
    @Column(name = "customer_name", nullable = false)
    private String customerName;
    @Column(name = "customer_phone")
    private String customerPhone;
    @Column(name = "shipping_address", nullable = false)
    private String shippingAddress;
    @Column(name = "shipping_city", nullable = false)
    private String shippingCity;
    @Column(name = "shipping_zip", nullable = false)
    private String shippingZip;
    @Column(name = "shipping_country", nullable = false)
    private String shippingCountry = "IT";
    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> items = new ArrayList<>();
    @Column(name = "subtotal", nullable = false, precision = 10, scale = 2)
    private BigDecimal subtotal;
    @Column(name = "shipping_cost", nullable = false, precision = 10, scale = 2)
    private BigDecimal shippingCost;
    @Column(name = "total_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalAmount;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OrderStatus status = OrderStatus.PENDING_PAYMENT;
    @Column(name = "stripe_payment_intent_id", unique = true)
    private String stripePaymentIntentId;
    @Column(name = "stripe_session_id", unique = true)
    private String stripeSessionId;
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

    public Order() {}

    @PrePersist
    public void generateOrderNumber() {
        if (this.orderNumber == null) {
            String year = String.valueOf(LocalDateTime.now().getYear());
            String unique = UUID.randomUUID().toString().substring(0, 6).toUpperCase();
            this.orderNumber = "DF-" + year + "-" + unique;
        }
    }

    public Long getId() { return id; }
    public String getOrderNumber() { return orderNumber; }
    public void setOrderNumber(String orderNumber) { this.orderNumber = orderNumber; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getCustomerPhone() { return customerPhone; }
    public void setCustomerPhone(String customerPhone) { this.customerPhone = customerPhone; }
    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }
    public String getShippingCity() { return shippingCity; }
    public void setShippingCity(String shippingCity) { this.shippingCity = shippingCity; }
    public String getShippingZip() { return shippingZip; }
    public void setShippingZip(String shippingZip) { this.shippingZip = shippingZip; }
    public String getShippingCountry() { return shippingCountry; }
    public void setShippingCountry(String shippingCountry) { this.shippingCountry = shippingCountry; }
    public List<OrderItem> getItems() { return items; }
    public void setItems(List<OrderItem> items) { this.items = items; }
    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
    public BigDecimal getShippingCost() { return shippingCost; }
    public void setShippingCost(BigDecimal shippingCost) { this.shippingCost = shippingCost; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public OrderStatus getStatus() { return status; }
    public void setStatus(OrderStatus status) { this.status = status; }
    public String getStripePaymentIntentId() { return stripePaymentIntentId; }
    public void setStripePaymentIntentId(String id) { this.stripePaymentIntentId = id; }
    public String getStripeSessionId() { return stripeSessionId; }
    public void setStripeSessionId(String id) { this.stripeSessionId = id; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public LocalDateTime getPaidAt() { return paidAt; }
    public void setPaidAt(LocalDateTime paidAt) { this.paidAt = paidAt; }
}
XEOF
echo "OK Order.java"

# 6. Fix OrderItem entity
cat > src/main/java/com/devfly/photostore/entity/OrderItem.java << 'XEOF'
package com.devfly.photostore.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "order_items")
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
    @Column(name = "photo_title", nullable = false)
    private String photoTitle;
    @Enumerated(EnumType.STRING)
    @Column(name = "print_format", nullable = false)
    private PrintFormat printFormat;
    @Enumerated(EnumType.STRING)
    @Column(name = "paper_type", nullable = false)
    private PaperType paperType;
    @Column(nullable = false)
    private Integer quantity = 1;
    @Column(name = "unit_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal unitPrice;
    @Column(name = "line_total", nullable = false, precision = 10, scale = 2)
    private BigDecimal lineTotal;
    @Column(name = "preview_url")
    private String previewUrl;

    public OrderItem() {}

    public Long getId() { return id; }
    public Order getOrder() { return order; }
    public void setOrder(Order order) { this.order = order; }
    public Photo getPhoto() { return photo; }
    public void setPhoto(Photo photo) { this.photo = photo; }
    public String getPhotoTitle() { return photoTitle; }
    public void setPhotoTitle(String photoTitle) { this.photoTitle = photoTitle; }
    public PrintFormat getPrintFormat() { return printFormat; }
    public void setPrintFormat(PrintFormat printFormat) { this.printFormat = printFormat; }
    public PaperType getPaperType() { return paperType; }
    public void setPaperType(PaperType paperType) { this.paperType = paperType; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    public BigDecimal getLineTotal() { return lineTotal; }
    public void setLineTotal(BigDecimal lineTotal) { this.lineTotal = lineTotal; }
    public String getPreviewUrl() { return previewUrl; }
    public void setPreviewUrl(String previewUrl) { this.previewUrl = previewUrl; }
}
XEOF
echo "OK OrderItem.java"

# 7. Fix Photo entity
cat > src/main/java/com/devfly/photostore/entity/Photo.java << 'XEOF'
package com.devfly.photostore.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "photos")
public class Photo {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false)
    private String title;
    @Column(length = 1000)
    private String description;
    @Column(name = "preview_url", nullable = false)
    private String previewUrl;
    @Column(name = "high_res_url", nullable = false)
    private String highResUrl;
    @Column(name = "cloudinary_public_id")
    private String cloudinaryPublicId;
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal basePrice;
    @Column(nullable = false)
    private String category;
    @ElementCollection
    @CollectionTable(name = "photo_tags", joinColumns = @JoinColumn(name = "photo_id"))
    @Column(name = "tag")
    private List<String> tags = new ArrayList<>();
    @Column(nullable = false)
    private boolean active = true;
    private Integer widthPx;
    private Integer heightPx;
    private String camera;
    private String lens;
    private String location;
    @Column(name = "shot_date")
    private LocalDateTime shotDate;
    @Column(name = "view_count")
    private Integer viewCount = 0;
    @Column(name = "order_count")
    private Integer orderCount = 0;
    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public Photo() {}

    public Long getId() { return id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getPreviewUrl() { return previewUrl; }
    public void setPreviewUrl(String previewUrl) { this.previewUrl = previewUrl; }
    public String getHighResUrl() { return highResUrl; }
    public void setHighResUrl(String highResUrl) { this.highResUrl = highResUrl; }
    public String getCloudinaryPublicId() { return cloudinaryPublicId; }
    public void setCloudinaryPublicId(String cloudinaryPublicId) { this.cloudinaryPublicId = cloudinaryPublicId; }
    public BigDecimal getBasePrice() { return basePrice; }
    public void setBasePrice(BigDecimal basePrice) { this.basePrice = basePrice; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public List<String> getTags() { return tags; }
    public void setTags(List<String> tags) { this.tags = tags; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public Integer getWidthPx() { return widthPx; }
    public void setWidthPx(Integer widthPx) { this.widthPx = widthPx; }
    public Integer getHeightPx() { return heightPx; }
    public void setHeightPx(Integer heightPx) { this.heightPx = heightPx; }
    public String getCamera() { return camera; }
    public void setCamera(String camera) { this.camera = camera; }
    public String getLens() { return lens; }
    public void setLens(String lens) { this.lens = lens; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public Integer getViewCount() { return viewCount; }
    public void setViewCount(Integer viewCount) { this.viewCount = viewCount; }
    public Integer getOrderCount() { return orderCount; }
    public void setOrderCount(Integer orderCount) { this.orderCount = orderCount; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
XEOF
echo "OK Photo.java"

# 8. Fix AuthService - senza Lombok
cat > src/main/java/com/devfly/photostore/service/AuthService.java << 'XEOF'
package com.devfly.photostore.service;

import com.devfly.photostore.config.JwtService;
import com.devfly.photostore.dto.AuthDto;
import com.devfly.photostore.entity.User;
import com.devfly.photostore.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {
    private static final Logger log = LoggerFactory.getLogger(AuthService.class);
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtService jwtService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Transactional
    public AuthDto.AuthResponse register(AuthDto.RegisterRequest req) {
        if (userRepository.existsByEmail(req.getEmail())) {
            throw new IllegalArgumentException("Email gia registrata: " + req.getEmail());
        }
        User user = new User();
        user.setEmail(req.getEmail().toLowerCase().trim());
        user.setPassword(passwordEncoder.encode(req.getPassword()));
        user.setFullName(req.getFullName());
        user.setPhone(req.getPhone());
        user.setRole(User.Role.CUSTOMER);
        userRepository.save(user);
        log.info("Nuovo utente registrato: {}", user.getEmail());
        String token = jwtService.generateToken(user.getEmail(), user.getRole().name());
        return new AuthDto.AuthResponse(token, user.getEmail(), user.getFullName(), user.getRole().name());
    }

    public AuthDto.AuthResponse login(AuthDto.LoginRequest req) {
        User user = userRepository.findByEmail(req.getEmail().toLowerCase().trim())
                .orElseThrow(() -> new IllegalArgumentException("Credenziali non valide"));
        if (!user.isActive()) throw new IllegalArgumentException("Account disabilitato.");
        if (!passwordEncoder.matches(req.getPassword(), user.getPassword()))
            throw new IllegalArgumentException("Credenziali non valide");
        String token = jwtService.generateToken(user.getEmail(), user.getRole().name());
        return new AuthDto.AuthResponse(token, user.getEmail(), user.getFullName(), user.getRole().name());
    }
}
XEOF
echo "OK AuthService.java"

# 9. Fix EmailService - senza Lombok
cat > src/main/java/com/devfly/photostore/service/EmailService.java << 'XEOF'
package com.devfly.photostore.service;

import com.devfly.photostore.entity.Order;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

@Service
public class EmailService {
    private static final Logger log = LoggerFactory.getLogger(EmailService.class);
    private final JavaMailSender mailSender;
    private final TemplateEngine templateEngine;
    @Value("${app.mail.from}") private String fromEmail;
    @Value("${app.mail.from-name}") private String fromName;

    public EmailService(JavaMailSender mailSender, TemplateEngine templateEngine) {
        this.mailSender = mailSender;
        this.templateEngine = templateEngine;
    }

    @Async
    public void sendOrderConfirmation(Order order) {
        try {
            Context ctx = new Context();
            ctx.setVariable("order", order);
            ctx.setVariable("customerName", order.getCustomerName().split(" ")[0]);
            String html = templateEngine.process("email/order-confirmation", ctx);
            sendEmail(order.getCustomerEmail(), "Ordine confermato - " + order.getOrderNumber(), html);
        } catch (Exception e) {
            log.error("Errore email conferma {}: {}", order.getOrderNumber(), e.getMessage());
        }
    }

    @Async
    public void sendShippingNotification(Order order) {
        try {
            Context ctx = new Context();
            ctx.setVariable("order", order);
            ctx.setVariable("customerName", order.getCustomerName().split(" ")[0]);
            String html = templateEngine.process("email/shipping-notification", ctx);
            sendEmail(order.getCustomerEmail(), "Ordine spedito - " + order.getOrderNumber(), html);
        } catch (Exception e) {
            log.error("Errore email spedizione {}: {}", order.getOrderNumber(), e.getMessage());
        }
    }

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

# 10. Fix CloudinaryService - senza Lombok e fix watermark API
cat > src/main/java/com/devfly/photostore/service/CloudinaryService.java << 'XEOF'
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
XEOF
echo "OK CloudinaryService.java"

# 11. Fix PhotoService - senza Lombok
cat > src/main/java/com/devfly/photostore/service/PhotoService.java << 'XEOF'
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
XEOF
echo "OK PhotoService.java"

# 12. Fix GlobalExceptionHandler - senza Lombok
cat > src/main/java/com/devfly/photostore/exception/GlobalExceptionHandler.java << 'XEOF'
package com.devfly.photostore.exception;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
public class GlobalExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse(HttpStatus.NOT_FOUND.value(), ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String field = ((FieldError) error).getField();
            errors.put(field, error.getDefaultMessage());
        });
        ErrorResponse response = new ErrorResponse(HttpStatus.BAD_REQUEST.value(), "Errore di validazione");
        response.setFieldErrors(errors);
        return ResponseEntity.badRequest().body(response);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArg(IllegalArgumentException ex) {
        return ResponseEntity.badRequest()
                .body(new ErrorResponse(HttpStatus.BAD_REQUEST.value(), ex.getMessage()));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ErrorResponse> handleForbidden(AccessDeniedException ex) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(new ErrorResponse(HttpStatus.FORBIDDEN.value(), "Accesso negato"));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneric(Exception ex) {
        log.error("Errore non gestito: {}", ex.getMessage(), ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse(HttpStatus.INTERNAL_SERVER_ERROR.value(), "Errore interno del server."));
    }

    public static class ErrorResponse {
        private final int status;
        private final String message;
        private final LocalDateTime timestamp = LocalDateTime.now();
        private Map<String, String> fieldErrors;
        public ErrorResponse(int status, String message) { this.status = status; this.message = message; }
        public int getStatus() { return status; }
        public String getMessage() { return message; }
        public LocalDateTime getTimestamp() { return timestamp; }
        public Map<String, String> getFieldErrors() { return fieldErrors; }
        public void setFieldErrors(Map<String, String> fe) { this.fieldErrors = fe; }
    }
}
XEOF
echo "OK GlobalExceptionHandler.java"

# 13. Fix OrderService - senza Lombok
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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class OrderService {
    private static final Logger log = LoggerFactory.getLogger(OrderService.class);
    private final OrderRepository orderRepository;
    private final PhotoRepository photoRepository;
    private final PricingService pricingService;
    private final EmailService emailService;
    @Value("${stripe.api.key}") private String stripeApiKey;
    @Value("${app.frontend-url}") private String frontendUrl;

    public OrderService(OrderRepository orderRepository, PhotoRepository photoRepository,
                        PricingService pricingService, EmailService emailService) {
        this.orderRepository = orderRepository;
        this.photoRepository = photoRepository;
        this.pricingService = pricingService;
        this.emailService = emailService;
    }

    @PostConstruct
    public void initStripe() { Stripe.apiKey = stripeApiKey; }

    @Transactional
    public OrderDto.CheckoutResponse createOrderAndCheckout(OrderDto.CreateRequest req) {
        Order order = new Order();
        order.setCustomerEmail(req.getCustomerEmail());
        order.setCustomerName(req.getCustomerName());
        order.setCustomerPhone(req.getCustomerPhone());
        order.setShippingAddress(req.getShippingAddress());
        order.setShippingCity(req.getShippingCity());
        order.setShippingZip(req.getShippingZip());
        order.setShippingCountry(req.getShippingCountry() != null ? req.getShippingCountry() : "IT");
        order.setNotes(req.getNotes());
        order.setStatus(OrderStatus.PENDING_PAYMENT);

        List<OrderItem> items = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        int totalItems = 0;

        for (OrderDto.ItemRequest itemReq : req.getItems()) {
            Photo photo = photoRepository.findById(itemReq.getPhotoId())
                    .orElseThrow(() -> new ResourceNotFoundException("Foto non trovata: " + itemReq.getPhotoId()));
            BigDecimal unitPrice = pricingService.calculatePrintPrice(photo.getBasePrice(), itemReq.getPrintFormat(), itemReq.getPaperType());
            BigDecimal lineTotal = unitPrice.multiply(BigDecimal.valueOf(itemReq.getQuantity()));
            OrderItem item = new OrderItem();
            item.setOrder(order);
            item.setPhoto(photo);
            item.setPhotoTitle(photo.getTitle());
            item.setPrintFormat(itemReq.getPrintFormat());
            item.setPaperType(itemReq.getPaperType());
            item.setQuantity(itemReq.getQuantity());
            item.setUnitPrice(unitPrice);
            item.setLineTotal(lineTotal);
            item.setPreviewUrl(photo.getPreviewUrl());
            items.add(item);
            subtotal = subtotal.add(lineTotal);
            totalItems += itemReq.getQuantity();
        }

        order.setItems(items);
        order.setSubtotal(subtotal);
        BigDecimal shippingCost = pricingService.calculateShipping(subtotal, totalItems);
        order.setShippingCost(shippingCost);
        order.setTotalAmount(subtotal.add(shippingCost));
        Order savedOrder = orderRepository.save(order);

        try {
            Session session = createStripeSession(savedOrder);
            savedOrder.setStripeSessionId(session.getId());
            orderRepository.save(savedOrder);
            return new OrderDto.CheckoutResponse(savedOrder.getOrderNumber(), session.getUrl(), savedOrder.getTotalAmount());
        } catch (StripeException e) {
            log.error("Errore Stripe: {}", e.getMessage());
            throw new RuntimeException("Impossibile avviare il pagamento.");
        }
    }

    private Session createStripeSession(Order order) throws StripeException {
        List<SessionCreateParams.LineItem> lineItems = new ArrayList<>();
        for (OrderItem item : order.getItems()) {
            String description = "Stampa " + item.getPrintFormat().getDisplaySize() + " - " + item.getPaperType().getDisplayName();
            lineItems.add(SessionCreateParams.LineItem.builder()
                    .setQuantity((long) item.getQuantity())
                    .setPriceData(SessionCreateParams.LineItem.PriceData.builder().setCurrency("eur")
                            .setUnitAmount(item.getUnitPrice().multiply(BigDecimal.valueOf(100)).setScale(0, RoundingMode.HALF_UP).longValue())
                            .setProductData(SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                    .setName(item.getPhotoTitle()).setDescription(description)
                                    .addImage(item.getPreviewUrl()).build()).build()).build());
        }
        if (order.getShippingCost().compareTo(BigDecimal.ZERO) > 0) {
            lineItems.add(SessionCreateParams.LineItem.builder().setQuantity(1L)
                    .setPriceData(SessionCreateParams.LineItem.PriceData.builder().setCurrency("eur")
                            .setUnitAmount(order.getShippingCost().multiply(BigDecimal.valueOf(100)).setScale(0, RoundingMode.HALF_UP).longValue())
                            .setProductData(SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                    .setName("Spedizione").build()).build()).build());
        }
        return Session.create(SessionCreateParams.builder()
                .setMode(SessionCreateParams.Mode.PAYMENT)
                .addAllLineItem(lineItems)
                .setCustomerEmail(order.getCustomerEmail())
                .putMetadata("order_number", order.getOrderNumber())
                .setSuccessUrl(frontendUrl + "/checkout/success?order=" + order.getOrderNumber())
                .setCancelUrl(frontendUrl + "/checkout/cancel?order=" + order.getOrderNumber()).build());
    }

    @Transactional
    public void handlePaymentSuccess(String sessionId) {
        Order order = orderRepository.findByStripeSessionId(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("Ordine non trovato: " + sessionId));
        if (order.getStatus() == OrderStatus.PENDING_PAYMENT) {
            order.setStatus(OrderStatus.PAID);
            order.setPaidAt(LocalDateTime.now());
            orderRepository.save(order);
            order.getItems().forEach(item -> photoRepository.findById(item.getPhoto().getId()).ifPresent(p -> {
                p.setOrderCount(p.getOrderCount() + item.getQuantity());
                photoRepository.save(p);
            }));
            emailService.sendOrderConfirmation(order);
            log.info("Ordine {} pagato.", order.getOrderNumber());
        }
    }

    @Transactional
    public OrderDto.Response updateStatus(String orderNumber, OrderStatus newStatus) {
        Order order = orderRepository.findByOrderNumber(orderNumber)
                .orElseThrow(() -> new ResourceNotFoundException("Ordine non trovato: " + orderNumber));
        order.setStatus(newStatus);
        if (newStatus == OrderStatus.SHIPPED) emailService.sendShippingNotification(order);
        return toResponse(orderRepository.save(order));
    }

    public OrderDto.Response getByOrderNumber(String orderNumber) {
        return toResponse(orderRepository.findByOrderNumber(orderNumber)
                .orElseThrow(() -> new ResourceNotFoundException("Ordine non trovato: " + orderNumber)));
    }

    public Page<OrderDto.Response> getOrdersByEmail(String email, Pageable pageable) {
        return orderRepository.findByCustomerEmailOrderByCreatedAtDesc(email, pageable).map(this::toResponse);
    }

    public Page<OrderDto.Response> getAllOrders(Pageable pageable) {
        return orderRepository.findAll(pageable).map(this::toResponse);
    }

    private OrderDto.Response toResponse(Order o) {
        List<OrderDto.ItemResponse> itemResponses = new ArrayList<>();
        for (OrderItem i : o.getItems()) {
            OrderDto.ItemResponse ir = new OrderDto.ItemResponse();
            ir.setPhotoId(i.getPhoto().getId());
            ir.setPhotoTitle(i.getPhotoTitle());
            ir.setPreviewUrl(i.getPreviewUrl());
            ir.setPrintFormat(i.getPrintFormat().getCode());
            ir.setFormatSize(i.getPrintFormat().getDisplaySize());
            ir.setPaperType(i.getPaperType().getDisplayName());
            ir.setQuantity(i.getQuantity());
            ir.setUnitPrice(i.getUnitPrice());
            ir.setLineTotal(i.getLineTotal());
            itemResponses.add(ir);
        }
        OrderDto.Response r = new OrderDto.Response();
        r.setId(o.getId());
        r.setOrderNumber(o.getOrderNumber());
        r.setCustomerEmail(o.getCustomerEmail());
        r.setCustomerName(o.getCustomerName());
        r.setShippingAddress(o.getShippingAddress());
        r.setShippingCity(o.getShippingCity());
        r.setShippingZip(o.getShippingZip());
        r.setShippingCountry(o.getShippingCountry());
        r.setItems(itemResponses);
        r.setSubtotal(o.getSubtotal());
        r.setShippingCost(o.getShippingCost());
        r.setTotalAmount(o.getTotalAmount());
        r.setStatus(o.getStatus());
        r.setCreatedAt(o.getCreatedAt());
        r.setPaidAt(o.getPaidAt());
        return r;
    }
}
XEOF
echo "OK OrderService.java"

git add .
git commit -m "fix: rimosso Lombok, getter/setter espliciti"
git push
echo "FATTO! Railway ripartira automaticamente."
