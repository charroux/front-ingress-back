#!/bin/bash

# Script de nettoyage
# Supprime tous les déploiements et le cluster Kind

set -e

CLUSTER_NAME="order-app"

echo "🗑️  Suppression de l'application..."

# Supprimer les déploiements
kubectl delete ingress app-ingress --ignore-not-found
kubectl delete deployment frontend --ignore-not-found
kubectl delete deployment backend --ignore-not-found
kubectl delete service frontend --ignore-not-found
kubectl delete service backend --ignore-not-found
kubectl delete namespace ingress-nginx --ignore-not-found

echo "✓ Application supprimée"

echo ""
echo "Voulez-vous aussi supprimer le cluster Kind '$CLUSTER_NAME'? (y/n)"
read -r response
if [[ "$response" == "y" ]]; then
    kind delete cluster --name "$CLUSTER_NAME"
    echo "✓ Cluster supprimé"
else
    echo "Cluster conservé"
fi

echo ""
echo "✅ Nettoyage terminé!"
