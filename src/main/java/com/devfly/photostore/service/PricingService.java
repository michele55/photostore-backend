package com.devfly.photostore.service;

import com.devfly.photostore.entity.PaperType;
import com.devfly.photostore.entity.PrintFormat;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;

@Service
public class PricingService {

    // Costo di spedizione fisso per stampe
    private static final BigDecimal SHIPPING_BASE = new BigDecimal("5.90");
    private static final BigDecimal SHIPPING_PER_ITEM = new BigDecimal("1.50");
    private static final BigDecimal FREE_SHIPPING_THRESHOLD = new BigDecimal("80.00");

    /**
     * Calcola il prezzo finale di una stampa.
     * Prezzo = basePrice × moltiplicatore_formato × moltiplicatore_carta
     */
    public BigDecimal calculatePrintPrice(BigDecimal basePrice,
                                          PrintFormat format,
                                          PaperType paperType) {
        double multiplier = format.getPriceMultiplier() * paperType.getPriceMultiplier();
        return basePrice
                .multiply(BigDecimal.valueOf(multiplier))
                .setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Calcola le spese di spedizione sull'intero ordine.
     * Gratis sopra la soglia FREE_SHIPPING_THRESHOLD.
     */
    public BigDecimal calculateShipping(BigDecimal subtotal, int itemCount) {
        if (subtotal.compareTo(FREE_SHIPPING_THRESHOLD) >= 0) {
            return BigDecimal.ZERO;
        }
        return SHIPPING_BASE
                .add(SHIPPING_PER_ITEM.multiply(BigDecimal.valueOf(itemCount - 1)))
                .setScale(2, RoundingMode.HALF_UP);
    }
}

