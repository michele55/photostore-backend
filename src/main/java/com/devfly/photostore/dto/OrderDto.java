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

