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
