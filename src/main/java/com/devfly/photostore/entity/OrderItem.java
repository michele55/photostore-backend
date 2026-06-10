package com.devfly.photostore.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "order_items")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class OrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "photo_id", nullable = false)
    private Photo photo;

    // Titolo salvato al momento dell'ordine (storico)
    @Column(name = "photo_title", nullable = false)
    private String photoTitle;

    // Scelte di stampa del cliente
    @Enumerated(EnumType.STRING)
    @Column(name = "print_format", nullable = false)
    private PrintFormat printFormat;

    @Enumerated(EnumType.STRING)
    @Column(name = "paper_type", nullable = false)
    private PaperType paperType;

    @Column(nullable = false)
    @Builder.Default
    private Integer quantity = 1;

    // Prezzo unitario calcolato (base × formato × carta)
    @Column(name = "unit_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal unitPrice;

    @Column(name = "line_total", nullable = false, precision = 10, scale = 2)
    private BigDecimal lineTotal;

    // Snapshot anteprima per email
    @Column(name = "preview_url")
    private String previewUrl;
}

