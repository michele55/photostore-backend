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
