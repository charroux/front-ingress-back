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
│  │   :80            │         │   + JPA :8080    │        │
│  └──────────────────┘         └────────┬─────────┘        │
│                                         │                  │
│                                         │ JDBC             │
│                                         ↓                  │
│                                ┌──────────────────┐        │
│                                │  MySQL StatefulSet│       │
│                                │  :3306            │       │
│                                │  PersistentVolume │       │
│                                └──────────────────┘        │
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

    @Autowired
    private OrderRepository orderRepository;

    @PostMapping
    public ResponseEntity<OrderResponse> createOrder(@RequestBody Order order) {
        // La commande est loguée dans la console
        System.out.println("📦 COMMANDE REÇUE DU FRONTEND");
        System.out.println(order.toString());

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
}
```

**Processus:**
1. Spring Boot reçoit la requête POST sur `/orders`
2. Le contrôleur `OrderController` intercepte la requête avec `@PostMapping`
3. L'objet `Order` est désérialisé depuis le JSON avec `@RequestBody`
4. La commande est sauvegardée dans MySQL via `OrderRepository.save(order)`
5. JPA/Hibernate génère automatiquement la requête SQL INSERT
6. La commande est loguée dans la console du pod avec son ID généré
7. Une réponse JSON est renvoyée au frontend

**Points clés:**
- L'annotation `@PostMapping` mappe les requêtes POST
- L'annotation `@RequestBody` désérialise le JSON
- `OrderRepository` hérite de `JpaRepository` pour les opérations CRUD
- L'annotation `@Entity` sur `Order` indique que c'est une table MySQL
- JPA crée automatiquement la table si elle n'existe pas (`ddl-auto=update`)

### 4. Persistance dans MySQL

**Fichier clé:** [backend/src/main/java/com/orderapp/Order.java](../backend/src/main/java/com/orderapp/Order.java)

```java
@Entity
@Table(name = "orders")
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String customerName;
    
    private String email;
    private String itemDescription;
    private int quantity;
    private double price;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
```

**Processus:**
1. JPA/Hibernate mappe la classe Java à une table MySQL
2. L'annotation `@Entity` indique que c'est une entité persistante
3. `@Id` + `@GeneratedValue` génère automatiquement les IDs
4. Les colonnes sont créées automatiquement depuis les champs
5. MySQL stocke les données sur un PersistentVolume (1Gi)

**Configuration Kubernetes:**
- **PersistentVolume**: 1Gi de stockage local (hostPath pour Kind)
- **PersistentVolumeClaim**: Réserve le volume pour MySQL
- **StatefulSet**: Garantit l'identité stable du pod MySQL
- **Service headless**: Permet la connexion directe au pod MySQL

### 5. Réponse au Frontend

La réponse JSON est renvoyée au frontend via le même chemin inverse:

```
Backend → NGINX Ingress → Frontend (Angular)
```

L'Angular service reçoit la réponse et l'affiche à l'utilisateur.

---

## Concepts Clés

### 2. Découverte de Services

Dans Kubernetes, les services sont découverts automatiquement par DNS:

```
http://backend:8080           http://mysql:3306
     ↑       ↑                      ↑      ↑
     |       └─ Port du service     |      └─ Port MySQL
     └─ Nom du service              └─ Nom du service MySQL
```

Les variables d'environnement dans le backend configurent la connexion:
```
SPRING_DATASOURCE_URL=jdbc:me le chemin de la requête et la redirige:

```
Requête: POST /api/orders
    ↓
NGINX matching /api → redirige vers backend:8080
    ↓
Requête transformée: POST http://backend:8080/orders
```

### 3. Isolation des Pods et Persistance

Chaque pod s'exécute dans un conteneur isolé:

```
Frontend Pod          Backend Pod              MySQL StatefulSet
   nginx              java (Spring Boot)           MySQL 8.0
   :80                + JPA :8080                    :3306
                           |                          |
                           └─────── JDBC ────────────┘
                                                      |
                                            PersistentVolume (1Gi)
                                            /var/lib/mysql
```

Les pods communiquent via les services Kubernetes, et MySQL utilise un volume persistant pour garantir la durabilité des donné
Frontend Pod          Backend Pod
   nginx                 java
   :80               (Spring Boot)
                         :8080
```
 et sauvegardée)
kubectl logs -f deployment/backend

# Logs de MySQL
kubectl logs -f statefulset/mysql

# Logs de NGINX Ingress
kubectl logs -f deployment/ingress-nginx
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

## Exécution Pas à Pas 

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

✅ Commande sauvegardée dans MySQL avec l'ID: 1
```

Dans les logs MySQL, on peut voir les connexions et requêtes SQL.tudiant peut voir dans les logs du backend:
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

**Dans le frontend** ([frontend/src/apAllOrders() {
    List<Order> orders = orderRepository.findAll();
    System.out.println("📋 Récupération de " + orders.size() + " commandes depuis MySQL");
    return ResponseEntity.ok(orders);
}
```

**Dans l'Ingress** ([k8s/ingress.yaml](../k8s/ingress.yaml)): Aucune modification nécessaire, le routage `/api` fonctionne pour tous les chemins

### Accéder directement à MySQL

Pour explorer la base de données:
```bash
# Se connecter au pod MySQL
kubectl exec -it mysql-0 -- mysql -uroot -ppassword orderdb

# Lister les commandes
mysql> SELECT * FROM orders;
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

