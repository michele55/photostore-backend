package com.devfly.photostore.entity;

/**
 * Formati di stampa disponibili con moltiplicatore di prezzo.
 */
public enum PrintFormat {

    A4("A4",       "21 × 29.7 cm",  1.0),
    A3("A3",       "29.7 × 42 cm",  1.5),
    A2("A2",       "42 × 59.4 cm",  2.2),
    A1("A1",       "59.4 × 84.1 cm",3.2),
    CM_50X70("50×70", "50 × 70 cm", 2.8),
    CM_70X100("70×100","70 × 100 cm",4.0),
    CM_30X45("30×45", "30 × 45 cm", 1.3),
    SQUARE_30("30×30","30 × 30 cm",  1.2),
    SQUARE_50("50×50","50 × 50 cm",  2.0);

    private final String code;
    private final String displaySize;
    private final double priceMultiplier;

    PrintFormat(String code, String displaySize, double priceMultiplier) {
        this.code = code;
        this.displaySize = displaySize;
        this.priceMultiplier = priceMultiplier;
    }

    public String getCode()            { return code; }
    public String getDisplaySize()     { return displaySize; }
    public double getPriceMultiplier() { return priceMultiplier; }
}

