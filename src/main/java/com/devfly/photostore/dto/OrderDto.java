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
