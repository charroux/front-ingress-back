# 🎯 COMMENCEZ ICI!

## Bienvenue dans le Projet "Application de Prise de Commande"

Cette application est conçue pour **enseigner l'architecture microservices** aux étudiants en informatique.

---

## ⚡ 5 Minutes pour Démarrer

### 1. Vérifier les Prérequis
```bash
./quickstart.sh
```

Cela vous indiquera si Docker, Kind, kubectl, Java et Node.js sont installés.

### 2. Déployer l'Application
```bash
chmod +x deploy.sh cleanup.sh
./deploy.sh
```

### 3. Accéder à l'Application
```bash
kubectl port-forward service/frontend 8080:80 &
```

Ouvrez: **http://localhost:8080**

### 4. Observer le Flux en Temps Réel
```bash
kubectl logs -f deployment/backend
```

Remplissez le formulaire et cliquez "Envoyer". Vous verrez la commande loguée dans le backend!

---

## 📚 Documentation (À lire dans cet ordre)

1. **[README.md](README.md)** - Vue d'ensemble et démarrage rapide
2. **[ARCHITECTURE.md](ARCHITECTURE.md)** - Comprendre le flux Frontend → Gateway → Backend
3. **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Guide détaillé de déploiement
4. **[EXERCISES.md](EXERCISES.md)** - 6 exercices pratiques
5. **[KUBECTL_CHEATSHEET.md](KUBECTL_CHEATSHEET.md)** - Commandes Kubernetes

---

## 🏗️ Architecture

```
Frontend (Angular)
    ↓ HTTP POST /api/orders
NGINX Ingress (Gateway)
    ↓ Routage /api → backend
Backend (Spring Boot)
    ↓ Logue la commande
```

---

## 🎓 Exercices Pratiques

- Exercice 1: Observer le flux complet (Facile)
- Exercice 2: Ajouter un nouveau champ (Facile)
- Exercice 3: Ajouter une nouvelle route (Moyen)
- Exercice 4: Horizontal scaling (Avancé)
- Exercice 5: Modifier la configuration NGINX (Avancé)
- Exercice 6: CORS et sécurité (Moyen)

→ Voir [EXERCISES.md](EXERCISES.md)

---

## 🔍 Fichiers Clés

- **Frontend**: [frontend/src/app/order.service.ts](frontend/src/app/order.service.ts)
- **Gateway**: [k8s/ingress.yaml](k8s/ingress.yaml)
- **Backend**: [backend/src/main/java/com/orderapp/OrderController.java](backend/src/main/java/com/orderapp/OrderController.java)

---

## 🐛 Déboguer

```bash
kubectl logs -f deployment/backend       # Voir les logs du backend
kubectl get pods                         # Voir les pods
kubectl describe pod <pod-name>          # Détails d'un pod
```

Plus de commandes: [KUBECTL_CHEATSHEET.md](KUBECTL_CHEATSHEET.md)

---

## ✨ Caractéristiques

✅ Architecture microservices complète  
✅ Frontend, gateway, backend dans Kubernetes  
✅ Logging détaillé en temps réel  
✅ Déploiement automatisé  
✅ Facile à modifier et étendre  
✅ Sans modification de `/etc/hosts`  
✅ Exercices progressifs  
✅ Documentation complète en français  

---

**Bon apprentissage! 🚀**
