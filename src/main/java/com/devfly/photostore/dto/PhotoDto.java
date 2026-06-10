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

