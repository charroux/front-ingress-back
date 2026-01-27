# 📦 Application de Prise de Commande - Guide Complet

**Une application éducative simple montrant l'articulation entre un frontend, une gateway et un backend dans une architecture microservices.**

---

## Architecture de l'application


```
┌─────────────────┐     HTTP POST /api/orders    ┌──────────────┐
│    Frontend     │  ─────────────────────────→  │   Gateway    │
│    (Angular)    │     JSON (données)           │ (NGINX Ingress)
│   Formulaire    │  ←─────────────────────────  │   Routeur    │
│                 │  HTTP 200 OK (réponse)       │              │
└─────────────────┘                              └──────────────┘
                                                        │
                                                        │ Redirige vers
                                                        ↓
                                                 ┌──────────────┐
                                                 │   Backend    │
                                                 │(Spring Boot) │
                                                 │   + JPA      │
                                                 └──────┬───────┘
                                                        │
                                                        │ Persiste
                                                        ↓
                                                 ┌──────────────┐
                                                 │    MySQL     │
                                                 │   Database   │
                                                 │ (StatefulSet)│
                                                 └──────────────┘
```

---

## Démarrage Rapide

### Prérequis Minimums
- Docker installé et actif
- Kind installé
- kubectl installé
- Java 21+
- Gradle (ou utiliser le gradle wrapper inclus)
- Node.js

### Lancer l'Application

```bash
# Se positionner dans le répertoire du projet
cd /Users/benoitcharroux/Desktop/microservices/FrontIngressBack

# Rendre les scripts exécutables
chmod +x deploy.sh cleanup.sh

# Déployer (ceci crée le cluster, construit les images, les déploie)
./deploy.sh

# Dans un nouveau terminal, accéder au frontend
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80

# Ouvrir le navigateur
open http://localhost:8080
```

**Voilà!** L'application est déployée et accessible.

---

## 📚 Documentation Complète

Pour comprendre en détail comment fonctionne l'application:

1. **[STRUCTURE.md](STRUCTURE.md)** - Navigation dans le projet
2. **[ARCHITECTURE.md](ARCHITECTURE.md)** - Explication du flux Frontend → Gateway → Backend
3. **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Guide détaillé de déploiement
4. **[EXERCISES.md](EXERCISES.md)** - Exercices pratiques (6 niveaux de difficulté)

---

## 🏗️ Architecture

### Technologies
- **Front-end** : Angular
- **Back-end** : Java 21 + Spring Boot 3.2 + Spring Data JPA + Gradle
- **Base de données** : MySQL 8.0 avec PersistentVolume
- **Gateway** : NGINX Ingress Controller
- **Orchestration** : Kubernetes (Kind - local)
- **Containerisation** : Docker

### Fichiers Clés

**Frontend** : Comment envoyer une requête HTTP
- [frontend/src/app/order.service.ts](frontend/src/app/order.service.ts)
- [frontend/src/app/app.component.ts](frontend/src/app/app.component.ts)

**Gateway** : Comment router les requêtes
- [k8s/ingress.yaml](k8s/ingress.yaml)

**Backend** : Comment recevoir et traiter
- [backend/src/main/java/com/orderapp/OrderRepository.java](backend/src/main/java/com/orderapp/OrderRepository.java)
- [backend/src/main/java/com/orderapp/Order.java](backend/src/main/java/com/orderapp/Order.java)

**Base de données** : Persistance avec MySQL
- [k8s/mysql-deployment.yaml](k8s/mysql-deployment.yaml)
- [backend/src/main/java/com/orderapp/OrderController.java](backend/src/main/java/com/orderapp/OrderController.java)

---

## 📋 Flux Complet d'une Commande

### 1️⃣ Frontend (Angular)
```bash
# L'utilisateur remplit le formulaire et clique "Envoyer"
# Le formulaire envoie:
POST /api/orders
Content-Type: application/json

{
  "customerName": "Jean Dupont",
  "email": "jean@example.com",
  "itemDescription": "Laptop",
  "quantity": 1,
  "price": 999.99
}
```

### 2️⃣ Gateway (NGINX Ingress)
```
Requête: POST /api/orders
         ↓
NGINX Ingress intercepte /api/*
         ↓
Redirige vers: http://backend:8080/orders
```

### 3️⃣ Backend (Spring Boot)
```java
// OrderController reçoit la requête
@PostMapping("/orders")
public ResponseEntity<OrderResponse> createOrder(@RequestBody Order order) {
    // La commande est loguée ici
    System.out.println("📦 COMMANDE REÇUE DU FRONTEND");
    System.out.println(order.toString());
    
    // Réponse
    return ResponseEntity.ok(new OrderResponse(
        "success",
        "Commande enregistrée avec succès",
        order.getCustomerName()
    ));
}
```

### 4️⃣ Réponse au Frontend
```
Backend → NGINX Ingress → Frontend (Angular)
         JSON
         ↓
Message de succès affiché à l'utilisateur
```

---

## 🐛 Observer le Flux en Temps Réel

### Terminal 1: Logs du Backend (où la commande est loguée)
```bash
kubectl logs -f deployment/backend
```

### Terminal 2: Accéder à l'application
```bash
kubectl port-forward service/frontend 8080:80
# Puis ouvrir http://localhost:8080
```

### Terminal 3: Logs du Frontend (optionnel)
```bash
kubectl logs -f deployment/frontend
```

### Dans le Navigateur (F12 → Network tab)
- Voir la requête `POST /api/orders`
- Status: `200 OK`
- Response: JSON avec le message de succès

**Résultat:** Vous voyez exactement comment les trois composants communiquent!

---

## 📊 Commandes Utiles

### Vérifier le Status
```bash
kubectl get deployments          # État des déploiements
kubectl get pods                 # État des pods
kubectl get services             # Services disponibles
kubectl get ingress              # Configuration de routage
```

### Voir les Logs
```bash
kubectl logs -f deployment/backend       # Backend en temps réel
kubectl logs -f deployment/frontend      # Frontend en temps réel
kubectl logs -f deployment/nginx-ingress-controller -n ingress-nginx  # Gateway
```

### Entrer dans un Pod (pour déboguer)
```bash
kubectl exec -it <pod-name> -- /bin/bash
```

### Redémarrer les Services
```bash
kubectl rollout restart deployment/backend
kubectl rollout restart deployment/frontend
```

---

## 🔧 Modifications et Déploiement

### Modifier le Code

**Backend:**
```bash
cd backend
# Modifier les fichiers Java
docker build -t order-app-backend:latest .
kind load docker-image order-app-backend:latest --name order-app
kubectl rollout restart deployment/backend
```

**Frontend:**
```bash
cd frontend
# Modifier les fichiers TypeScript/HTML
docker build -t order-app-frontend:latest .
kind load docker-image order-app-frontend:latest --name order-app
kubectl rollout restart deployment/frontend
```

---

## ❌ Troubleshooting

### Le frontend ne peut pas atteindre le backend
```bash
# Vérifier que l'Ingress est correctement configuré
kubectl describe ingress app-ingress

# Vérifier que les services existent
kubectl get svc

# Tester la connectivité directement
kubectl exec -it <frontend-pod-name> -- curl http://backend:8080/orders/health
```

### Les pods ne se lancent pas
```bash
# Voir le détail de l'erreur
kubectl describe pod <pod-name>

# Voir les logs complets
kubectl logs <pod-name>
```

### Port 8080 déjà utilisé
```bash
# Utiliser un port différent
kubectl port-forward service/frontend 9090:80
open http://localhost:9090
```

---

## 🧹 Nettoyage

```bash
# Supprimer l'application
./cleanup.sh

# Supprimer le cluster
kind delete cluster --name order-app
```

---

## 📖 Ressources Externes

- **Kubernetes**: https://kubernetes.io/
- **Kind**: https://kind.sigs.k8s.io/
- **NGINX Ingress**: https://kubernetes.github.io/ingress-nginx/
- **Angular**: https://angular.io/
- **Spring Boot**: https://spring.io/projects/spring-boot
- **Docker**: https://www.docker.com/

---

## 🎓 Points de Contrôle

### Avant de Démarrer
- [ ] Docker actif (`docker ps` fonctionne)
- [ ] Kind installé (`kind --version`)
- [ ] kubectl installé (`kubectl --version`)
- [ ] Java 21+ installé (`java --version`)
- [ ] Gradle installé OU gradle wrapper du projet (`./gradlew --version`)
- [ ] Node.js installé (`node --version`)

### Après Déploiement
- [ ] Frontend accessible à http://localhost:8080
- [ ] Formulaire s'affiche correctement
- [ ] Soumettre une commande fonctionne
- [ ] Logs du backend affichent la commande reçue
- [ ] Message de succès au frontend

---

## 📞 Support

Pour des questions sur:
- **Architecture** → Lire [ARCHITECTURE.md](ARCHITECTURE.md)
- **Déploiement** → Lire [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **Navigation** → Lire [STRUCTURE.md](STRUCTURE.md)

---

