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

