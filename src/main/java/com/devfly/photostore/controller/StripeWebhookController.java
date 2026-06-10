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

