# Aide-Mémoire: Commandes Kubernetes Essentielles

## 🎯 Commandes pour les Étudiants

### Afficher des Informations

```bash
# Voir tous les déploiements
kubectl get deployments

# Voir tous les pods
kubectl get pods

# Voir tous les services
kubectl get services

# Voir la configuration d'Ingress
kubectl get ingress

# Voir les événements (erreurs, avertissements)
kubectl get events

# Voir les informations détaillées d'une ressource
kubectl describe <resource-type> <resource-name>
# Exemple:
kubectl describe pod backend-xxxxx
kubectl describe deployment backend
```

### Voir les Logs

```bash
# Logs d'un déploiement en temps réel (-f = follow)
kubectl logs -f deployment/backend

# Logs du frontend
kubectl logs -f deployment/frontend

# Logs de NGINX Ingress
kubectl logs -f deployment/nginx-ingress-controller -n ingress-nginx

# Logs d'un pod spécifique
kubectl logs <pod-name>

# Logs d'une version précédente (si le pod a crashé)
kubectl logs <pod-name> --previous

# Voir les 50 dernières lignes
kubectl logs <pod-name> --tail=50

# Voir les logs avec les timestamps
kubectl logs <pod-name> --timestamps=true
```

### Accéder à un Pod

```bash
# Exécuter une commande dans un pod
kubectl exec -it <pod-name> -- /bin/bash

# Tester la connectivité
kubectl exec -it <pod-name> -- curl http://backend:8080/orders/health

# Voir les fichiers du pod
kubectl exec -it <pod-name> -- ls -la

# Vérifier quels ports écoutent
kubectl exec -it <pod-name> -- netstat -tulpn
```

### Port Forwarding (Accéder localement)

```bash
# Accéder au frontend
kubectl port-forward service/frontend 8080:80

# Accéder au backend
kubectl port-forward service/backend 8080:8080

# Accéder à NGINX Ingress
kubectl port-forward -n ingress-nginx service/nginx-ingress 80:80

# Lancer en arrière-plan
kubectl port-forward service/frontend 8080:80 &

# Tuer le processus
pkill -f "port-forward"
```

### Redémarrer les Services

```bash
# Redémarrer un déploiement
kubectl rollout restart deployment/backend

# Redémarrer le frontend
kubectl rollout restart deployment/frontend

# Voir l'historique des redémarrages
kubectl rollout history deployment/backend

# Revenir à une version précédente
kubectl rollout undo deployment/backend
```

### Scaler l'Application

```bash
# Augmenter le nombre de répliques
kubectl scale deployment/backend --replicas=3

# Diminuer le nombre de répliques
kubectl scale deployment/backend --replicas=1

# Voir le status du scaling
kubectl get deployment backend --watch
```

### Supprimer des Ressources

```bash
# Supprimer une Ingress
kubectl delete ingress app-ingress

# Supprimer un déploiement
kubectl delete deployment backend

# Supprimer un service
kubectl delete service backend

# Supprimer tout dans le cluster (attention!)
kubectl delete all --all
```

---

## 🔍 Débugage Avancé

### Voir les Status Détaillés

```bash
# Status complet d'une ressource
kubectl describe pod <pod-name>

# Voir ce qui se passe dans le pod
kubectl get pod <pod-name> -o yaml

# Voir les events associés
kubectl describe pod <pod-name> | grep Events -A 10
```

### Tester la Connectivité

```bash
# Depuis le frontend vers le backend
kubectl exec -it <frontend-pod-name> -- curl -v http://backend:8080/orders/health

# Depuis un pod test vers le backend
kubectl run debug-pod --image=alpine --rm -it --restart=Never -- \
    wget -O- http://backend:8080/orders/health

# Voir le DNS
kubectl exec -it <pod-name> -- nslookup backend
```

### Voir les Ressources Utilisées

```bash
# CPU et mémoire utilisés
kubectl top nodes
kubectl top pods

# Voir les limites de ressources
kubectl describe node <node-name>
```

### Logs Formatés

```bash
# Logs avec timestamps et pod name
kubectl logs -f deployment/backend --timestamps=true

# Tous les logs des pods d'un déploiement
kubectl logs -f deployment/backend --all-containers=true

# Logs depuis une date/heure
kubectl logs deployment/backend --since=1h

# Logs depuis un nombre de secondes
kubectl logs deployment/backend --since=30s
```

---

## 🛠️ Commandes Kind

### Gérer le Cluster

```bash
# Créer un cluster
kind create cluster --name order-app

# Lister les clusters
kind get clusters

# Supprimer un cluster
kind delete cluster --name order-app

# Charger une image Docker dans le cluster
kind load docker-image order-app-backend:latest --name order-app

# Obtenir le kubeconfig
kind export kubeconfig --name order-app
```

---

## 📊 Commandes Utiles Combinées

### Monitoring Complet

```bash
# Voir tout en temps réel
kubectl get all --watch

# Voir les pods et leurs states
kubectl get pods --watch

# Voir les déploiements avec leur status
kubectl get deployments -o wide
```

### Déploiement et Tests

```bash
# Déployer et attendre
kubectl apply -f k8s/backend-deployment.yaml
kubectl wait --for=condition=ready pod --selector=app=backend --timeout=300s

# Tester immédiatement
kubectl exec -it <pod-name> -- curl http://backend:8080/orders/health
```

### Nettoyage Complet

```bash
# Supprimer tous les pods
kubectl delete pods --all

# Supprimer tous les services
kubectl delete svc --all

# Supprimer tous les déploiements
kubectl delete deployment --all

# Supprimer les namespaces personnalisés
kubectl delete namespace ingress-nginx
```

---

## 🚨 Troubleshooting Rapide

### Pod ne démarre pas

```bash
# 1. Voir l'erreur
kubectl describe pod <pod-name>

# 2. Voir les logs
kubectl logs <pod-name>

# 3. Voir les événements
kubectl get events --sort-by='.lastTimestamp'
```

### Image introuvable

```bash
# 1. Vérifier que l'image existe localement
docker images | grep order-app

# 2. Charger l'image dans le cluster
kind load docker-image order-app-backend:latest --name order-app

# 3. Redéployer
kubectl rollout restart deployment/backend
```

### Connectivité échouée

```bash
# 1. Vérifier les services
kubectl get svc

# 2. Tester DNS
kubectl exec -it <pod-name> -- nslookup backend

# 3. Tester la connectivité
kubectl exec -it <pod-name> -- curl http://backend:8080

# 4. Vérifier l'Ingress
kubectl describe ingress app-ingress
```

---

## 📝 Exemples Pratiques

### Voir une Commande Entrante en Direct

```bash
# Terminal 1: Logs du backend
kubectl logs -f deployment/backend

# Terminal 2: Port forward
kubectl port-forward service/frontend 8080:80 &

# Terminal 3: Soumettre une requête (test)
curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -d '{"customerName":"Test","email":"test@test.com","itemDescription":"Item","quantity":1,"price":100}'
```

### Observer le Scaling

```bash
# Terminal 1: Watch les pods
kubectl get pods --watch

# Terminal 2: Scaler
kubectl scale deployment/backend --replicas=3

# Vous verrez 3 pods démarrer
```

### Voir le Flux Complet des Requêtes

```bash
# Terminal 1: Logs du backend
kubectl logs -f deployment/backend

# Terminal 2: Logs de l'Ingress
kubectl logs -f deployment/nginx-ingress-controller -n ingress-nginx

# Terminal 3: Port forward
kubectl port-forward service/frontend 8080:80 &

# Terminal 4: DevTools du navigateur
# F12 → Network tab
# Soumettre le formulaire

# Résultat: Vous voyez la requête traverser tous les composants
```

---

## 🎓 Récapitulatif Pédagogique

### Pour Comprendre le Flux

1. **Voir les pods**: `kubectl get pods`
2. **Voir les services**: `kubectl get services`
3. **Voir l'Ingress**: `kubectl get ingress`
4. **Voir la configuration**: `kubectl describe ingress app-ingress`
5. **Voir les logs**: `kubectl logs -f deployment/backend`
6. **Tester**: Soumettre le formulaire
7. **Vérifier**: Les logs affichent la commande

### Pour Déboguer

1. **Erreur pod**: `kubectl describe pod <nom>`
2. **Erreur logs**: `kubectl logs <nom>`
3. **Erreur réseau**: `kubectl exec -it <nom> -- curl ...`
4. **Erreur déploiement**: `kubectl get events`

### Pour Modifier et Redéployer

1. Modifier le code (frontend ou backend)
2. Reconstruire l'image: `docker build ...`
3. Charger dans Kind: `kind load docker-image ...`
4. Redémarrer: `kubectl rollout restart deployment/...`

