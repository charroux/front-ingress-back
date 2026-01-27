package com.orderapp;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * OrderRepository : Interface JPA pour les opérations CRUD sur Order
 * 
 * POINT CLÉ POUR LES ÉTUDIANTS :
 * - JpaRepository fournit automatiquement les méthodes CRUD (save, findAll, findById, delete, etc.)
 * - Aucune implémentation n'est nécessaire, Spring Data JPA génère le code automatiquement
 * - Ceci simplifie grandement l'accès aux données
 */
@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    // Méthodes CRUD héritées de JpaRepository :
    // - save(Order order) : sauvegarde ou met à jour une commande
    // - findAll() : retourne toutes les commandes
    // - findById(Long id) : trouve une commande par son ID
    // - deleteById(Long id) : supprime une commande par son ID
    // - count() : compte le nombre de commandes
    
    // Vous pouvez ajouter des méthodes personnalisées si nécessaire
    // Ex: List<Order> findByCustomerName(String customerName);
}
