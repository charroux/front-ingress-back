# Architecture de l'Application

## Vue d'ensemble

Cette application démontre une architecture microservices simple avec trois composants principaux:

```
┌─────────────────────────────────────────────────────────────┐
│                   KUBERNETES (Kind)                         │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  NGINX Ingress Controller (Gateway)                 │  │
│  │  ┌──────────────────────────────────────────────┐   │  │
│  │  │ Routage:                                     │   │  │
│  │  │ - / → Frontend (port 80)                     │   │  │
│  │  │ - /api → Backend (port 8080)                 │   │  │
│  │  └──────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────┘  │
│         ↓                              ↓                   │
│  ┌──────────────────┐         ┌──────────────────┐        │
│  │   Frontend Pod   │         │   Backend Pod    │        │
│  │   (Angular)      │         │  (Spring Boot)   │        │
│  │   :80            │         │   :8080          │        │
│  └──────────────────┘         └──────────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

## Flux d'une Commande

### 1. Frontend (Angular)

**Fichier clé:** [frontend/src/app/order.service.ts](../frontend/src/app/order.service.ts)

```typescript
// L'utilisateur remplit le formulaire et clique "Envoyer"
// Le service envoie une requête HTTP POST

this.http.post('/api/orders', orderData, { headers })
```

**Points clés:**
- URL: `/api/orders` (chemin relatif)
- Méthode: POST
- Contenu: Objet JSON avec les données de commande
- La requête est interceptée par le navigateur et envoyée au serveur

### 2. NGINX Ingress Controller (Gateway)

**Fichier clé:** [k8s/ingress.yaml](../k8s/ingress.yaml)

```yaml
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
```

**Processus:**
1. La requête `/api/orders` arrive au NGINX Ingress
2. NGINX matching le chemin `/api` et la redirige vers le service `backend`
3. Le service DNS de Kubernetes résout `backend` en `http://backend:8080`
4. La requête est transférée au pod backend

**Points clés:**
- NGINX agit comme un reverse proxy
- Il routage les requêtes basées sur le chemin (`/` vs `/api`)
- Les services Kubernetes fournissent la découverte de services (DNS)

### 3. Backend (Spring Boot)

**Fichier clé:** [backend/src/main/java/com/orderapp/OrderController.java](../backend/src/main/java/com/orderapp/OrderController.java)

```java
@RestController
@RequestMapping("/orders")
public class OrderController {

    @PostMapping
    public ResponseEntity<OrderResponse> createOrder(@RequestBody Order order) {
        // La commande est loguée dans la console
        System.out.println("📦 COMMANDE REÇUE DU FRONTEND");
        System.out.println(order.toString());

        OrderResponse response = new OrderResponse(
            "success",
            "Commande enregistrée avec succès",
            order.getCustomerName()
        );

        return ResponseEntity.ok(response);
    }
}
```

**Processus:**
1. Spring Boot reçoit la requête POST sur `/orders`
2. Le contrôleur `OrderController` intercepte la requête
3. L'objet `Order` est désérialisé depuis le JSON
4. La commande est loguée dans la console du pod
5. Une réponse JSON est renvoyée au frontend

**Points clés:**
- L'annotation `@PostMapping` mappe les requêtes POST
- L'annotation `@RequestBody` désérialise le JSON
- La commande est loguée pour que les étudiants puissent voir ce qui est reçu

### 4. Réponse au Frontend

La réponse JSON est renvoyée au frontend via le même chemin inverse:

```
Backend → NGINX Ingress → Frontend (Angular)
```

L'Angular service reçoit la réponse et l'affiche à l'utilisateur.

---

## Concepts Clés pour les Étudiants

### 1. Découverte de Services

Dans Kubernetes, les services sont découverts automatiquement par DNS:

```
http://backend:8080
     ↑       ↑
     |       └─ Nom du service (défini dans k8s/backend-deployment.yaml)
     └─ Protocole
```

### 2. Routage d'Ingress

L'Ingress Controller inspect le chemin de la requête et la redirige:

```
Requête: GET /api/orders
    ↓
NGINX matching /api → redirige vers backend:8080
    ↓
Requête transformée: GET http://backend:8080/orders
```

### 3. Isolation des Pods

Chaque pod s'exécute dans un conteneur isolé:

```
Frontend Pod          Backend Pod
   nginx                 java
   :80               (Spring Boot)
                         :8080
```

Les pods ne peuvent se communiquer que via les services Kubernetes.

### 4. Logs Distribuées

Les étudiants peuvent voir les logs de chaque composant:

```bash
# Logs du frontend
kubectl logs -f deployment/frontend

# Logs du backend (où apparaît la commande reçue)
kubectl logs -f deployment/backend

# Logs de NGINX Ingress
kubectl logs -f deployment/nginx-ingress-controller -n ingress-nginx
```

---

## Exécution Pas à Pas pour les Étudiants

### 1. Lancer l'application

```bash
./deploy.sh
```

### 2. Accéder au frontend

```bash
kubectl port-forward service/frontend 8080:80 &
# Puis ouvrir http://localhost:8080
```

### 3. Observer les logs du backend

```bash
kubectl logs -f deployment/backend
```

### 4. Remplir le formulaire et soumettre

L'utilisateur voit:
- Le formulaire change d'état (affiche "Envoi...")
- Un message de succès s'affiche
- Dans la console du navigateur: la requête est envoyée à `/api/orders`

L'étudiant peut voir dans les logs du backend:
```
═══════════════════════════════════════════════════
📦 COMMANDE REÇUE DU FRONTEND
═══════════════════════════════════════════════════
Order{customerName='Jean Dupont', email='jean@example.com', ...}
═══════════════════════════════════════════════════
```

### 5. Tracer la requête

L'étudiant peut voir exactement le chemin suivi par la requête:

**Frontend** → **NGINX Ingress** → **Backend**

---

## Modifications pour les Étudiants

### Ajouter une nouvelle route

**Dans le frontend** ([frontend/src/app/order.service.ts](../frontend/src/app/order.service.ts)):
```typescript
getOrders(): Observable<any> {
    return this.http.get('/api/orders');
}
```

**Dans le backend** ([backend/src/main/java/com/orderapp/OrderController.java](../backend/src/main/java/com/orderapp/OrderController.java)):
```java
@GetMapping
public ResponseEntity<List<Order>> getOrders() {
    System.out.println("📖 Récupération de toutes les commandes");
    return ResponseEntity.ok(new ArrayList<>());
}
```

**Dans l'Ingress** ([k8s/ingress.yaml](../k8s/ingress.yaml)): Aucune modification nécessaire, le routage `/api` fonctionne pour tous les chemins

---

## Avantages de cette Architecture

1. **Séparation des Préoccupations**: Frontend, gateway et backend sont indépendants
2. **Scalabilité**: Chaque composant peut être scaling indépendamment
3. **Résilience**: Si un pod tombe, Kubernetes le redémarre automatiquement
4. **Flexibilité**: La gateway peut router vers plusieurs backends
5. **Apprentissage**: Les étudiants voient une architecture réelle simplifiée

