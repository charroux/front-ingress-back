# Guide de Déploiement - Étapes Détaillées

## Prérequis

Vérifiez que vous avez installé:

```bash
# Vérifier les prérequis
which docker          # Docker doit être installé
which go              # Go doit être installé (pour Kind)
which kubectl         # kubectl doit être installé
```

Si des commandes manquent, voir la section installation.

---

## Installation des Prérequis

### 1. Docker

**macOS:**
```bash
brew install docker
# Ou télécharger Docker Desktop: https://www.docker.com/products/docker-desktop
```

**Linux (Ubuntu):**
```bash
sudo apt-get install docker.io
```

**Windows:**
Télécharger Docker Desktop: https://www.docker.com/products/docker-desktop

### 2. Go

**macOS:**
```bash
brew install go
```

**Linux (Ubuntu):**
```bash
sudo apt-get install golang-go
```

**Windows:**
Télécharger: https://golang.org/dl/

### 3. Kind

```bash
go install sigs.k8s.io/kind@latest
```

### 4. kubectl

```bash
# Avec Homebrew (macOS)
brew install kubectl

# Ou télécharger directement
# https://kubernetes.io/docs/tasks/tools/
```

### 5. Gradle (pour construire le backend)

**macOS:**
```bash
brew install gradle
```

**Linux (Ubuntu):**
```bash
sudo apt-get install gradle
```

Note: Gradle est inclus dans le projet avec le gradle wrapper (`gradlew`), donc vous n'avez pas besoin de l'installer si vous utilisez le script de déploiement automatisé.

---

## Étape 1: Préparer le Projet

```bash
# Se positionner dans le répertoire du projet
cd /Users/benoitcharroux/Desktop/microservices/FrontIngressBack

# Rendre les scripts exécutables
chmod +x deploy.sh
chmod +x cleanup.sh
```

---

## Étape 2: Déployer l'Application (Automatisé)

### Option A: Script Automatisé (Recommandé)

```bash
./deploy.sh
```

Ce script:
1. ✓ Crée un cluster Kind
2. ✓ Construit les images Docker
3. ✓ Les charge dans le cluster
4. ✓ Déploie NGINX Ingress Controller
5. ✓ Déploie l'application

### Option B: Déploiement Manuel

Si vous préférez faire les étapes manuellement:

```bash
# 1. Créer le cluster
kind create cluster --name order-app

# 2. Construire le frontend
cd frontend
docker build -t order-app-frontend:latest .
kind load docker-image order-app-frontend:latest --name order-app
cd ..

# 3. Construire le backend
cd backend
docker build -t order-app-backend:latest .
kind load docker-image order-app-backend:latest --name order-app
cd ..

# 4. Déployer NGINX Ingress Controller
kubectl apply -f k8s/nginx-ingress-controller.yaml
kubectl wait --namespace ingress-nginx --for=condition=ready pod \
    --selector=app=nginx-ingress-controller --timeout=300s

# 5. Déployer l'application
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/ingress.yaml

# 6. Attendre que les pods soient prêts
kubectl wait --for=condition=ready pod --selector=app=frontend --timeout=300s
kubectl wait --for=condition=ready pod --selector=app=backend --timeout=300s
```

---

## Étape 3: Accéder à l'Application

### Option A: Port Forward (Recommandé pour le développement)

```bash
# Terminal 1: Frontend
kubectl port-forward service/frontend 8080:80

# Ou dans un autre terminal
kubectl port-forward service/frontend 8080:80 &

# Accédez à: http://localhost:8080
```

### Option B: Via NGINX Ingress LoadBalancer

```bash
# Terminal 1: Forward le service NGINX
kubectl port-forward -n ingress-nginx service/nginx-ingress 80:80

# Accédez à: http://localhost
```

### Option C: Via NodePort (si supporté)

```bash
# Obtenir le NodePort
kubectl get services

# Accédez via: http://<node-ip>:<nodeport>
```

---

## Étape 4: Déboguer et Observer le Flux

### Voir le Statut des Déploiements

```bash
# Déploiements
kubectl get deployments

# Pods
kubectl get pods

# Services
kubectl get services

# Ingress
kubectl get ingress
```

### Voir les Logs

```bash
# Logs du backend (où les commandes sont loguées)
kubectl logs -f deployment/backend

# Logs du frontend
kubectl logs -f deployment/frontend

# Logs de NGINX Ingress
kubectl logs -f deployment/nginx-ingress-controller -n ingress-nginx

# Logs d'un pod spécifique
kubectl logs <pod-name>
```

### Entrer dans un Pod

```bash
# Lister les pods
kubectl get pods

# Entrer dans le pod backend
kubectl exec -it <backend-pod-name> -- /bin/bash

# Vérifier que le service écoute sur le port 8080
netstat -tulpn | grep 8080
```

### Tester la Connectivité

```bash
# Depuis le frontend, tester la connectivité vers le backend
kubectl exec -it <frontend-pod-name> -- curl http://backend:8080/orders/health

# Depuis un pod test
kubectl run test-pod --image=alpine --rm -it --restart=Never -- \
    wget -O- http://backend:8080/orders/health
```

---

## Étape 5: Voir le Flux Complet

### 1. Ouvrir Trois Terminaux

**Terminal 1: Logs du Backend**
```bash
kubectl logs -f deployment/backend
```

**Terminal 2: Logs du Frontend**
```bash
kubectl logs -f deployment/frontend
```

**Terminal 3: Port Forward**
```bash
kubectl port-forward service/frontend 8080:80
```

### 2. Dans le Navigateur

- Ouvrir http://localhost:8080
- Ouvrir DevTools (F12)
- Aller à l'onglet "Network"

### 3. Remplir et Soumettre le Formulaire

Vous verrez:

**Terminal 1 (Backend):**
```
═══════════════════════════════════════════════════
📦 COMMANDE REÇUE DU FRONTEND
═══════════════════════════════════════════════════
Order{customerName='Jean Dupont', email='jean@example.com', ...}
═══════════════════════════════════════════════════
```

**Terminal 2 (Frontend):**
```
[INFO] Formulaire soumis avec succès
```

**Navigateur (DevTools → Network):**
- Requête: `POST /api/orders`
- Status: `200 OK`
- Response: JSON avec le message de succès

---

## Troubleshooting

### Les pods ne se lancent pas

```bash
# Voir le détail de l'erreur
kubectl describe pod <pod-name>

# Voir les logs
kubectl logs <pod-name>

# Vérifier les événements
kubectl get events
```

### Le frontend ne peut pas atteindre le backend

```bash
# 1. Vérifier que les services existent
kubectl get services

# 2. Vérifier que l'Ingress est correctement configuré
kubectl describe ingress app-ingress

# 3. Tester la connectivité
kubectl exec -it <frontend-pod-name> -- curl http://backend:8080/orders/health
```

### Les images ne se chargent pas dans le cluster

```bash
# Vérifier que l'image est chargée
docker images | grep order-app

# Recharger l'image
kind load docker-image order-app-frontend:latest --name order-app
kind load docker-image order-app-backend:latest --name order-app
```

### Port 8080 ou 80 déjà utilisé

```bash
# Utiliser un port différent
kubectl port-forward service/frontend 9090:80

# Accédez à: http://localhost:9090
```

---

## Nettoyage

### Supprimer l'Application

```bash
./cleanup.sh

# Ou manuellement
kubectl delete ingress app-ingress
kubectl delete deployment frontend
kubectl delete deployment backend
kubectl delete service frontend
kubectl delete service backend
```

### Supprimer le Cluster

```bash
kind delete cluster --name order-app
```

### Supprimer les Images Docker

```bash
docker rmi order-app-frontend:latest
docker rmi order-app-backend:latest
```

---

## Points de Contrôle

Avant de démarrer, vérifiez:

- ✓ Docker est installé et le daemon est actif
- ✓ Kind est installé (`kind --version`)
- ✓ kubectl est installé (`kubectl --version`)
- ✓ Java 21 est installé (`java --version`)
- ✓ Node.js est installé (`node --version`)
- ✓ Gradle installé OU le gradle wrapper du projet fonctionnera

---

## Prochaines Étapes

Voir [ARCHITECTURE.md](ARCHITECTURE.md) pour comprendre le flux complet de l'application.

