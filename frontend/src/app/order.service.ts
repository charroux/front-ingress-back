/**
 * OrderService : Service pour communiquer avec le backend
 * 
 * POINT CLÉ POUR LES ÉTUDIANTS:
 * - Ce service envoie les requêtes HTTP au backend
 * - L'URL /api/orders est interceptée par NGINX Ingress
 * - NGINX redirige vers le service backend (http://backend:8080)
 * - Le backend traite la requête et renvoie une réponse
 */

import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class OrderService {

  // URL du backend - NOTE: /api est routé par NGINX Ingress
  private apiUrl = '/api/orders';

  constructor(private http: HttpClient) { }

  /**
   * Envoie une commande au backend
   * 
   * Flux:
   * 1. Frontend envoie POST /api/orders
   * 2. NGINX Ingress intercepte /api/*
   * 3. NGINX redirige vers backend:8080/orders
   * 4. OrderController traite la requête
   * 5. Réponse renvoyée au frontend
   */
  createOrder(orderData: any): Observable<any> {
    const headers = new HttpHeaders({ 'Content-Type': 'application/json' });
    
    console.log('📤 Envoi de la commande au backend via /api/orders');
    console.log('Données:', orderData);
    
    return this.http.post<any>(this.apiUrl, orderData, { headers });
  }

}
