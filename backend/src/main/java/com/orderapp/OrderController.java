package com.orderapp;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * OrderController : Contrôleur REST pour les commandes
 * 
 * POINT CLÉS POUR LES ÉTUDIANTS :
 * - Ce contrôleur reçoit les requêtes du frontend via la gateway NGINX Ingress
 * - L'URL /api/orders est exposée par le NGINX Ingress qui redirige vers ce service
 * - Chaque commande reçue est sauvegardée dans MySQL via JPA
 */
@RestController
@RequestMapping("/orders")
@CrossOrigin(origins = "*")
public class OrderController {

    @Autowired
    private OrderRepository orderRepository;

    /**
     * Endpoint pour créer une nouvelle commande
     * POST /api/orders
     * 
     * Flux:
     * 1. Frontend (Angular) -> POST /api/orders
     * 2. NGINX Ingress route /api -> Service backend:8080
     * 3. OrderController reçoit la requête sur /orders
     * 4. Commande sauvegardée dans MySQL
     * 5. Réponse renvoyée au frontend
     */
    @PostMapping
    public ResponseEntity<OrderResponse> createOrder(@RequestBody Order order) {
        // LOG IMPORTANT : Ceci affiche la commande reçue dans les logs du pod
        System.out.println("═══════════════════════════════════════════════════");
        System.out.println("📦 COMMANDE REÇUE DU FRONTEND");
        System.out.println("═══════════════════════════════════════════════════");
        System.out.println(order.toString());
        System.out.println("═══════════════════════════════════════════════════");

        // Sauvegarde dans MySQL via JPA
        Order savedOrder = orderRepository.save(order);
        System.out.println("✅ Commande sauvegardée dans MySQL avec l'ID: " + savedOrder.getId());
        
        OrderResponse response = new OrderResponse(
            "success",
            "Commande enregistrée avec succès dans la base de données",
            order.getCustomerName()
        );

        return ResponseEntity.ok(response);
    }

    /**
     * Endpoint pour récupérer toutes les commandes
     * GET /api/orders
     */
    @GetMapping
    public ResponseEntity<List<Order>> getAllOrders() {
        List<Order> orders = orderRepository.findAll();
        System.out.println("📋 Récupération de " + orders.size() + " commandes depuis MySQL");
        return ResponseEntity.ok(orders);
    }

    /**
     * Endpoint de santé pour vérifier que le service fonctionne
     */
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        System.out.println("✓ Health check reçu");
        return ResponseEntity.ok("OK");
    }

}
