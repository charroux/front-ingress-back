#!/bin/bash

# Script de déploiement automatisé
# Ce script déploie l'application complète dans Kind

set -e

CLUSTER_NAME="order-app"
FRONTEND_IMAGE="order-app-frontend:latest"
BACKEND_IMAGE="order-app-backend:latest"

echo "════════════════════════════════════════════════════"
echo "📦 Déploiement de l'Application de Prise de Commande"
echo "════════════════════════════════════════════════════"

# Étape 1: Créer le cluster Kind
echo ""
echo "1️⃣  Création du cluster Kind..."
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo "✓ Cluster '$CLUSTER_NAME' existe déjà"
else
    kind create cluster --name "$CLUSTER_NAME"
    echo "✓ Cluster '$CLUSTER_NAME' créé"
fi

# Étape 2: Construire les images Docker
echo ""
echo "2️⃣  Construction des images Docker..."

echo "  • Frontend..."
cd frontend
docker build -t "$FRONTEND_IMAGE" .
kind load docker-image "$FRONTEND_IMAGE" --name "$CLUSTER_NAME"
echo "  ✓ Image frontend chargée"
cd ..

echo "  • Backend..."
cd backend
docker build -t "$BACKEND_IMAGE" .
kind load docker-image "$BACKEND_IMAGE" --name "$CLUSTER_NAME"
echo "  ✓ Image backend chargée"
cd ..

# Étape 3: Déployer NGINX Ingress Controller
echo ""
echo "3️⃣  Déploiement de NGINX Ingress Controller..."
kubectl apply -f k8s/nginx-ingress-controller.yaml
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app=nginx-ingress-controller --timeout=300s || true
echo "✓ NGINX Ingress Controller déployé"

# Étape 4: Déployer l'application
echo ""
echo "4️⃣  Déploiement de l'application..."
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/ingress.yaml
echo "✓ Application déployée"

# Étape 5: Attendre que les pods soient prêts
echo ""
echo "5️⃣  Attente du démarrage des pods..."
kubectl wait --for=condition=ready pod --selector=app=frontend --timeout=300s || true
kubectl wait --for=condition=ready pod --selector=app=backend --timeout=300s || true
echo "✓ Tous les pods sont prêts"

# Étape 6: Afficher les informations
echo ""
echo "════════════════════════════════════════════════════"
echo "✅ Déploiement terminé!"
echo "════════════════════════════════════════════════════"
echo ""
echo "📊 Status des déploiements:"
kubectl get deployments
echo ""
echo "🔗 Services:"
kubectl get services
echo ""
echo "🌐 Ingress:"
kubectl get ingress
echo ""
echo "════════════════════════════════════════════════════"
echo "🚀 Pour accéder à l'application:"
echo "════════════════════════════════════════════════════"
echo ""
echo "Option 1 - Port Forward (Recommandé pour le développement):"
echo "  kubectl port-forward service/frontend 8080:80 &"
echo "  Puis accédez à: http://localhost:8080"
echo ""
echo "Option 2 - Direct (via NGINX Ingress):"
echo "  kubectl port-forward -n ingress-nginx service/nginx-ingress 80:80 &"
echo "  Puis accédez à: http://localhost"
echo ""
echo "════════════════════════════════════════════════════"
echo "🐛 Pour déboguer:"
echo "════════════════════════════════════════════════════"
echo ""
echo "Logs du backend:"
echo "  kubectl logs -f deployment/backend"
echo ""
echo "Logs du frontend:"
echo "  kubectl logs -f deployment/frontend"
echo ""
echo "Logs de NGINX Ingress:"
echo "  kubectl logs -f deployment/nginx-ingress-controller -n ingress-nginx"
echo ""
