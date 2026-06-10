package com.devfly.photostore.entity;

public enum OrderStatus {
    PENDING_PAYMENT,   // In attesa di pagamento
    PAID,              // Pagato — da processare
    PROCESSING,        // In lavorazione (stampa in corso)
    SHIPPED,           // Spedito
    DELIVERED,         // Consegnato
    CANCELLED,         // Annullato
    REFUNDED           // Rimborsato
}

