package com.devfly.photostore.entity;

/**
 * Tipi di carta per la stampa con moltiplicatore di prezzo.
 */
public enum PaperType {

    LUCIDA("Lucida",
           "Carta fotografica lucida ad alta saturazione, ideale per colori vivaci.",
           1.0),

    OPACA("Opaca",
          "Finitura opaca anti-riflesso, perfetta per ambienti con luce diretta.",
          1.0),

    CANVAS("Canvas",
           "Stampa su tela artistica con texture tessuta, effetto quadro da galleria.",
           1.8),

    FINE_ART("Fine Art",
             "Carta cotone 300g archiviale, durata oltre 100 anni, colori profondi.",
             2.2),

    METALLICA("Metallica",
              "Superficie metallizzata che dona brillantezza unica alle foto di paesaggi.",
              2.5),

    PLEXIGLASS("Plexiglass",
               "Stampa dietro vetro acrilico, resa luminosa e moderna, pronta da appendere.",
               3.5);

    private final String displayName;
    private final String description;
    private final double priceMultiplier;

    PaperType(String displayName, String description, double priceMultiplier) {
        this.displayName = displayName;
        this.description = description;
        this.priceMultiplier = priceMultiplier;
    }

    public String getDisplayName()     { return displayName; }
    public String getDescription()     { return description; }
    public double getPriceMultiplier() { return priceMultiplier; }
}

