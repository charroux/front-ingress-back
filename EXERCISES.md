# Exercices Pratiques pour les Étudiants

## Objectif Pédagogique

Ces exercices permettent aux étudiants de comprendre l'articulation entre un frontend, une gateway et un backend dans une architecture microservices.

---

## Exercice 1: Observer le Flux Complet

**Niveau:** Facile  
**Durée:** 15 minutes

### Objectif
Voir comment une requête traverse l'application de bout en bout.

### Étapes

1. **Lancer l'application**
```bash
./deploy.sh
```

2. **Ouvrir 3 terminaux**

Terminal 1 - Logs du backend:
```bash
kubectl logs -f deployment/backend
```

Terminal 2 - Frontend accessible:
```bash
kubectl port-forward service/frontend 8080:80
```

Terminal 3 - Logs du frontend:
```bash
kubectl logs -f deployment/frontend
```

3. **Dans le navigateur**
- Ouvrir http://localhost:8080
- Ouvrir DevTools (F12) → onglet Network
- Remplir le formulaire
- Cliquer "Envoyer la commande"

4. **Observer**
- Terminal 1: Vous voyez la commande loguée dans le backend
- Terminal 3: Logs du frontend
- DevTools: Requête POST /api/orders → Status 200

### Concept Appris
**Flux Frontend → Gateway → Backend** en action réelle

---

## Exercice 2: Ajouter un Nouveau Champ

**Niveau:** Facile  
**Durée:** 20 minutes

### Objectif
Apprendre comment modifier le flux de données.

### Nouvelle Fonctionnalité
Ajouter un champ "Notes spéciales" au formulaire.

### Étapes

1. **Modifier le backend** - Ajouter le champ à la classe Order

Fichier: [backend/src/main/java/com/orderapp/Order.java](../backend/src/main/java/com/orderapp/Order.java)

```java
public class Order {
    private String customerName;
    private String email;
    private String itemDescription;
    private int quantity;
    private double price;
    private String specialNotes;  // ← NOUVEAU CHAMP

    // Ajouter getter et setter
    public String getSpecialNotes() {
        return specialNotes;
    }

    public void setSpecialNotes(String specialNotes) {
        this.specialNotes = specialNotes;
    }
}
```

2. **Mettre à jour le formulaire frontend**

Fichier: [frontend/src/app/app.component.ts](../frontend/src/app/app.component.ts)

```typescript
createForm(): FormGroup {
    return this.fb.group({
        customerName: ['', [Validators.required, Validators.minLength(2)]],
        email: ['', [Validators.required, Validators.email]],
        itemDescription: ['', [Validators.required, Validators.minLength(5)]],
        quantity: ['', [Validators.required, Validators.min(1)]],
        price: ['', [Validators.required, Validators.min(0)]],
        specialNotes: ['']  // ← NOUVEAU CHAMP (optionnel)
    });
}
```

3. **Ajouter le champ au template HTML**

Fichier: [frontend/src/app/app.component.html](../frontend/src/app/app.component.html)

Ajouter après le champ "Prix unitaire":
```html
<div class="form-group">
  <label for="specialNotes">Notes spéciales (optionnel)</label>
  <input 
    type="text" 
    id="specialNotes" 
    formControlName="specialNotes"
    placeholder="Demandes spéciales..."
  />
</div>
```

4. **Reconstruire les images Docker**

```bash
# Backend
cd backend
docker build -t order-app-backend:latest .
kind load docker-image order-app-backend:latest --name order-app
cd ..

# Frontend
cd frontend
docker build -t order-app-frontend:latest .
kind load docker-image order-app-frontend:latest --name order-app
cd ..
```

5. **Redéployer**

```bash
kubectl rollout restart deployment/backend
kubectl rollout restart deployment/frontend
```

6. **Tester**

- Ouvrir http://localhost:8080
- Le nouveau champ est visible
- Remplir et soumettre
- Voir dans les logs du backend que le champ est reçu

### Concept Appris
**Modification du flux de données** à travers l'architecture

---

## Exercice 3: Ajouter une Nouvelle Route

**Niveau:** Moyen  
**Durée:** 30 minutes

### Objectif
Ajouter un endpoint pour récupérer toutes les commandes (GET).

### Nouvelle Fonctionnalité
Afficher la liste des commandes précédentes.

### Étapes

1. **Backend - Ajouter une liste en mémoire**

Fichier: [backend/src/main/java/com/orderapp/OrderController.java](../backend/src/main/java/com/orderapp/OrderController.java)

```java
package com.orderapp;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/orders")
@CrossOrigin(origins = "*")
public class OrderController {

    // Liste en mémoire pour stocker les commandes
    private static List<Order> orders = new ArrayList<>();

    @PostMapping
    public ResponseEntity<OrderResponse> createOrder(@RequestBody Order order) {
        System.out.println("📦 COMMANDE REÇUE");
        System.out.println(order.toString());
        
        // Ajouter à la liste
        orders.add(order);
        
        OrderResponse response = new OrderResponse(
            "success",
            "Commande enregistrée",
            order.getCustomerName()
        );

        return ResponseEntity.ok(response);
    }

    // ← NOUVEAU ENDPOINT
    @GetMapping
    public ResponseEntity<List<Order>> getOrders() {
        System.out.println("📖 Récupération de " + orders.size() + " commandes");
        return ResponseEntity.ok(orders);
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("OK");
    }
}
```

2. **Frontend - Ajouter un service pour récupérer les commandes**

Fichier: [frontend/src/app/order.service.ts](../frontend/src/app/order.service.ts)

```typescript
export class OrderService {
    private apiUrl = '/api/orders';

    // ...existing createOrder method...

    // ← NOUVEAU ENDPOINT
    getOrders(): Observable<any[]> {
        console.log('📖 Récupération des commandes');
        return this.http.get<any[]>(this.apiUrl);
    }
}
```

3. **Frontend - Ajouter l'affichage dans le composant**

Fichier: [frontend/src/app/app.component.ts](../frontend/src/app/app.component.ts)

```typescript
export class AppComponent {
    orderForm: FormGroup;
    submitted = false;
    successMessage: string | null = null;
    errorMessage: string | null = null;
    isLoading = false;
    orders: any[] = [];  // ← NOUVEAU

    constructor(...) {
        this.orderForm = this.createForm();
        this.loadOrders();  // ← NOUVEAU
    }

    // ← NOUVELLE MÉTHODE
    loadOrders(): void {
        this.orderService.getOrders().subscribe({
            next: (data) => {
                this.orders = data;
                console.log('✅ Commandes chargées:', data);
            },
            error: (error) => {
                console.error('❌ Erreur:', error);
            }
        });
    }

    onSubmit(): void {
        if (this.orderForm.valid) {
            this.orderService.createOrder(this.orderForm.value).subscribe({
                next: (response) => {
                    this.successMessage = `Commande créée!`;
                    this.orderForm.reset();
                    this.loadOrders();  // ← RECHARGER LA LISTE
                },
                error: (error) => {
                    this.errorMessage = 'Erreur';
                }
            });
        }
    }
}
```

4. **Frontend - Afficher la liste dans le template HTML**

Fichier: [frontend/src/app/app.component.html](../frontend/src/app/app.component.html)

Ajouter avant la fermeture du formulaire:
```html
<!-- Liste des commandes -->
<section class="orders-section" *ngIf="orders.length > 0">
  <h2>📋 Commandes Précédentes</h2>
  <table>
    <thead>
      <tr>
        <th>Client</th>
        <th>Article</th>
        <th>Quantité</th>
        <th>Prix Unitaire</th>
      </tr>
    </thead>
    <tbody>
      <tr *ngFor="let order of orders">
        <td>{{ order.customerName }}</td>
        <td>{{ order.itemDescription }}</td>
        <td>{{ order.quantity }}</td>
        <td>{{ order.price }}€</td>
      </tr>
    </tbody>
  </table>
</section>
```

5. **Ajouter du CSS**

Fichier: [frontend/src/app/app.component.css](../frontend/src/app/app.component.css)

```css
.orders-section {
  margin-top: 40px;
  padding: 20px;
  background: #f5f5f5;
  border-radius: 5px;
}

.orders-section h2 {
  color: #333;
  margin-bottom: 20px;
}

table {
  width: 100%;
  border-collapse: collapse;
  background: white;
}

table thead {
  background: #667eea;
  color: white;
}

table th, table td {
  padding: 12px;
  text-align: left;
  border: 1px solid #ddd;
}

table tbody tr:hover {
  background: #f9f9f9;
}
```

6. **Reconstruire et redéployer**

```bash
# Reconstruire le backend
cd backend && docker build -t order-app-backend:latest . && kind load docker-image order-app-backend:latest --name order-app && cd ..

# Reconstruire le frontend
cd frontend && docker build -t order-app-frontend:latest . && kind load docker-image order-app-frontend:latest --name order-app && cd ..

# Redéployer
kubectl rollout restart deployment/backend
kubectl rollout restart deployment/frontend

# Attendre
kubectl wait --for=condition=ready pod --selector=app=backend --timeout=300s
kubectl wait --for=condition=ready pod --selector=app=frontend --timeout=300s
```

7. **Tester**

- Ouvrir http://localhost:8080
- Créer plusieurs commandes
- La liste s'affiche automatiquement

### Concept Appris
**Requêtes GET et POST**, **Stockage d'état**, **Restitution de données**

---

## Exercice 4: Horizontale Scaling

**Niveau:** Avancé  
**Durée:** 20 minutes

### Objectif
Comprendre comment Kubernetes peut scaler automatiquement les applications.

### Étapes

1. **Augmenter le nombre de répliques du backend**

```bash
# Modifier le deployment
kubectl scale deployment/backend --replicas=3
```

2. **Vérifier les pods**

```bash
kubectl get pods
# Vous devriez voir 3 pods backend

kubectl logs -f deployment/backend --all-containers=true
# Vous voyez les logs de tous les pods
```

3. **Soumettre des commandes**

```bash
# Chaque commande est distribuée à l'un des 3 pods
# Les logs montrent qu'elles sont reçues par différents pods
```

4. **Réduire les répliques**

```bash
kubectl scale deployment/backend --replicas=1
```

### Concept Appris
**Load Balancing** et **Scalabilité horizontale**

---

## Exercice 5: Modifier la Configuration NGINX

**Niveau:** Avancé  
**Durée:** 30 minutes

### Objectif
Comprendre comment l'Ingress Controller route les requêtes.

### Modification
Ajouter une nouvelle route pour un service de paiement fictif.

### Étapes

1. **Créer un nouveau service**

```bash
# Créer un deployment simple
kubectl create deployment payment-service --image=nginx:latest
kubectl expose deployment payment-service --port=8080 --target-port=80
```

2. **Modifier l'Ingress**

Fichier: [k8s/ingress.yaml](../k8s/ingress.yaml)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend
            port:
              number: 8080
      - path: /payment  # ← NOUVEAU
        pathType: Prefix
        backend:
          service:
            name: payment-service
            port:
              number: 8080
```

3. **Appliquer la modification**

```bash
kubectl apply -f k8s/ingress.yaml
```

4. **Tester**

```bash
kubectl port-forward -n ingress-nginx service/nginx-ingress 80:80 &

# Tester les routes
curl http://localhost/          # Frontend
curl http://localhost/api/orders/health   # Backend
curl http://localhost/payment   # Payment
```

### Concept Appris
**Routage multi-services** avec l'Ingress Controller

---

## Exercice 6: CORS et Sécurité

**Niveau:** Moyen  
**Durée:** 25 minutes

### Objectif
Comprendre les problèmes CORS dans une architecture microservices.

### Étapes

1. **Ajouter une vérification d'origine**

Fichier: [backend/src/main/java/com/orderapp/OrderController.java](../backend/src/main/java/com/orderapp/OrderController.java)

Modifier l'annotation `@CrossOrigin`:

```java
@RestController
@RequestMapping("/orders")
@CrossOrigin(origins = {"http://localhost:80", "http://localhost:8080"})
public class OrderController {
    // ...
}
```

2. **Tester avec une origine interdite**

```bash
# Depuis un autre domaine
curl -H "Origin: http://attacker.com" \
     -H "Access-Control-Request-Method: POST" \
     http://localhost:8080/orders
```

3. **Observer les erreurs CORS dans le navigateur**

- DevTools → Network
- Chercher les erreurs CORS

### Concept Appris
**CORS**, **Sécurité des microservices**

---

## Solutions et Réponses

Les solutions des exercices sont disponibles dans des branches:

```bash
git branch -a
git checkout exercice-1-solution
# etc.
```

## Points de Contrôle

Exercices complétés:
- [ ] Exercice 1: Observer le flux complet
- [ ] Exercice 2: Ajouter un nouveau champ
- [ ] Exercice 3: Ajouter une nouvelle route
- [ ] Exercice 4: Horizontal scaling
- [ ] Exercice 5: Modifier la configuration NGINX
- [ ] Exercice 6: CORS et sécurité

