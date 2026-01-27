package com.orderapp;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * OrderController : Contrôleur REST pour les commandes
 * 
 * POINT CLÉS POUR LES ÉTUDIANTS :
 * - Ce contrôleur reçoit les requêtes du frontend via la gateway NGINX Ingress
 * - L'URL /api/orders est exposée par le NGINX Ingress qui redirige vers ce service
 * - Chaque commande reçue est loguée dans la console
 */
@RestController
@RequestMapping("/orders")
@CrossOrigin(origins = "*")
public class OrderController {

    /**
     * Endpoint pour créer une nouvelle commande
     * POST /api/orders
     * 
     * Flux:
     * 1. Frontend (Angular) -> POST /api/orders
     * 2. NGINX Ingress route /api -> Service backend:8080
     * 3. OrderController reçoit la requête
     * 4. Commande loguée dans la console
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

        // Traitement de la commande (ici, juste du logging)
        // En production, vous sauvegarderiez en base de données
        
        OrderResponse response = new OrderResponse(
            "success",
            "Commande enregistrée avec succès",
            order.getCustomerName()
        );

        return ResponseEntity.ok(response);
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
