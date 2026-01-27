package com.orderapp;

/**
 * Classe Order : représente une commande
 * Cette classe est utilisée pour recevoir les données du frontend
 */
public class Order {
    private String customerName;
    private String email;
    private String itemDescription;
    private int quantity;
    private double price;

    // Constructeurs
    public Order() {
    }

    public Order(String customerName, String email, String itemDescription, int quantity, double price) {
        this.customerName = customerName;
        this.email = email;
        this.itemDescription = itemDescription;
        this.quantity = quantity;
        this.price = price;
    }

    // Getters et Setters
    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getItemDescription() {
        return itemDescription;
    }

    public void setItemDescription(String itemDescription) {
        this.itemDescription = itemDescription;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    @Override
    public String toString() {
        return "Order{" +
                "customerName='" + customerName + '\'' +
                ", email='" + email + '\'' +
                ", itemDescription='" + itemDescription + '\'' +
                ", quantity=" + quantity +
                ", price=" + price +
                '}';
    }
}
