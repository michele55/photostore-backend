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

