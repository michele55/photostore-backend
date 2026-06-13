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
