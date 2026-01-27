## Structure du Projet

```
FrontIngressBack/
│
├── README.md                    # Point de départ - Instructions principales
├── ARCHITECTURE.md              # Explication du flux Frontend → Gateway → Backend
├── DEPLOYMENT_GUIDE.md          # Guide détaillé de déploiement
├── EXERCISES.md                 # Exercices pratiques pour les étudiants
├── project.json                 # Configuration du projet
│
├── deploy.sh                    # Script de déploiement automatisé
├── cleanup.sh                   # Script de nettoyage
│
├── frontend/                    # Application Angular
│   ├── package.json
│   ├── angular.json
│   ├── tsconfig.json
│   ├── tsconfig.app.json
│   ├── Dockerfile               # Conteneurisation du frontend
│   ├── nginx.conf               # Configuration nginx (servir l'app)
│   └── src/
│       ├── main.ts
│       ├── bootstrap.ts
│       ├── index.html
│       ├── styles.css
│       └── app/
│           ├── app.component.ts          # Composant principal
│           ├── app.component.html        # Template du formulaire
│           ├── app.component.css         # Styles
│           └── order.service.ts          # Service HTTP
│
├── backend/                     # Service Spring Boot
│   ├── build.gradle             # Configuration Gradle
│   ├── settings.gradle          # Paramètres Gradle
│   ├── gradlew                  # Gradle wrapper
│   ├── Dockerfile               # Conteneurisation du backend
│   └── src/main/java/com/orderapp/
│       ├── OrderServiceApplication.java  # Point d'entrée
│       ├── OrderController.java          # REST Controller
│       ├── OrderRepository.java          # Interface JPA Repository
│       ├── Order.java                    # Entité JPA (table MySQL)
│       └── OrderResponse.java            # Modèle de réponse
│   └── src/main/resources/
│       └── application.properties        # Configuration Spring + MySQL
│
└── k8s/                         # Fichiers de déploiement Kubernetes
    ├── nginx-ingress-controller.yaml     # NGINX Ingress Controller
    ├── frontend-deployment.yaml          # Déploiement du frontend
    ├── backend-deployment.yaml           # Déploiement du backend + env MySQL
    ├── mysql-deployment.yaml             # MySQL StatefulSet + PV/PVC
    └── ingress.yaml                      # Configuration du routage
```

---

## Fichiers Clés Expliqués

### Pour Comprendre le Frontend

**Voir:** [frontend/src/app/order.service.ts](frontend/src/app/order.service.ts)
- Comment le frontend envoie les requêtes HTTP au backend
- L'URL `/api/orders` est interceptée par NGINX Ingress

**Voir:** [frontend/src/app/app.component.ts](frontend/src/app/app.component.ts)
- Le formulaire et sa soumission
- Observation du cycle de vie des données

**Voir:** [frontend/src/app/app.component.html](frontend/src/app/app.component.html)
- L'interface utilisateur
- Explication visuelle du flux

### Pour Comprendre la Gateway

**Voir:** [k8s/ingress.yaml](k8s/ingress.yaml)
- Le routage des requêtes
- Mapping `/` vers frontend et `/api` vers backend

**Voir:** [k8s/nginx-ingress-controller.yaml](k8s/nginx-ingress-controller.yaml)
- Déploiement du contrôleur NGINX
- Configuration des services et permissions

### Pour Comprendre le Backend

**Voir:** [backend/src/main/java/com/orderapp/OrderController.java](backend/src/main/java/com/orderapp/OrderController.java)
- Comment les requêtes sont reçues
- Où les commandes sont loguées
- Les annotations Spring

**Voir:** [backend/src/main/java/com/orderapp/Order.java](backend/src/main/java/com/orderapp/Order.java)
- Structure des données de commande
- Désérialisation JSON

### Pour Déployer

**Voir:** [deploy.sh](deploy.sh)
- Étapes automatisées de déploiement
- Commandes que vous pouvez aussi exécuter manuellement

**Voir:** [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- Instructions pas à pas détaillées
- Troubleshooting

---

## Flux de Navigation

### Pour un Débutant

1. Lire [README.md](README.md)
2. Exécuter [deploy.sh](deploy.sh)
3. Consulter [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) à l'étape 3
4. Accéder à l'application
5. Faire l'exercice 1 dans [EXERCISES.md](EXERCISES.md)

### Pour Comprendre l'Architecture

1. Lire [ARCHITECTURE.md](ARCHITECTURE.md) complètement
2. Observer les fichiers clés mentionnés ci-dessus
3. Exécuter les commandes de debugging
4. Tracer le flux d'une commande

### Pour Modifier l'Application

1. Consulter [EXERCISES.md](EXERCISES.md) pour des idées
2. Modifier le code (frontend ou backend)
3. Reconstruire les images Docker
4. Redéployer avec `kubectl rollout restart`

---

## Checkliste de Déploiement

### Avant de Démarrer
- [ ] Docker est actif (`docker ps` fonctionne)
- [ ] Kind est installé (`kind --version`)
- [ ] kubectl est installé (`kubectl --version`)
- [ ] Maven est installé (`mvn --version`)
- [ ] Java 21+ est installé (`java --version`)
- [ ] Node.js est installé (`node --version`)

### Déploiement
- [ ] Exécuter `chmod +x deploy.sh cleanup.sh`
- [ ] Exécuter `./deploy.sh`
- [ ] Attendre la fin du script
- [ ] Ouvrir http://localhost:8080 (après port-forward)

### Vérification
- [ ] Frontend affichage du formulaire
- [ ] Formulaire s'envoie sans erreur
- [ ] Logs du backend affichent la commande
- [ ] Message de succès au frontend

---

## Ressources Externes

### Kubernetes
- [kubernetes.io](https://kubernetes.io/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [kubectl Cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### NGINX Ingress
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Ingress API Documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/)

### Angular
- [Angular Documentation](https://angular.io/docs)
- [Angular HttpClient](https://angular.io/guide/http)

### Spring Boot
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Spring REST Controller](https://spring.io/guides/gs/rest-service/)

### Docker
- [Docker Documentation](https://docs.docker.com/)
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)

---

## Support Pédagogique

### Questions Fréquentes

**Q: Comment vérifier que l'application fonctionne?**
```bash
# Frontend accessible
curl http://localhost:8080

# Backend accessible
curl http://localhost:8080/api/orders/health
```

**Q: Comment voir les logs en temps réel?**
```bash
kubectl logs -f deployment/backend
```

**Q: Comment redémarrer les services?**
```bash
kubectl rollout restart deployment/backend
kubectl rollout restart deployment/frontend
```

**Q: Comment supprimer et recommencer?**
```bash
./cleanup.sh
kind delete cluster --name order-app
```

### Contact et Aide

Consultez les logs du système pour comprendre les erreurs:

```bash
# Événements du cluster
kubectl get events

# Description détaillée d'un pod
kubectl describe pod <pod-name>

# Logs détaillés
kubectl logs <pod-name> --previous  # Si le pod a crashé
```

---

**Bon apprentissage! 🚀**

