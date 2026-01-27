package com.orderapp;

/**
 * OrderResponse : Classe pour la réponse du serveur
 */
public class OrderResponse {
    private String status;
    private String message;
    private String customerName;

    public OrderResponse(String status, String message, String customerName) {
        this.status = status;
        this.message = message;
        this.customerName = customerName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }
}
