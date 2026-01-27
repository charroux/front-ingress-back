#!/bin/bash

# Script pour construire les images localement (sans déployer)
# Utile si vous voulez juste préparer les images Docker

echo "📦 Construction des Images Docker"
echo "═════════════════════════════════════"
echo ""

# Vérifier que Docker est actif
if ! docker ps &> /dev/null; then
    echo "❌ Docker n'est pas actif"
    echo "Démarrez Docker et réessayez"
    exit 1
fi

echo "1️⃣  Construction du Frontend..."
cd frontend
docker build -t order-app-frontend:latest .
if [ $? -eq 0 ]; then
    echo "✅ Frontend construit"
else
    echo "❌ Erreur lors de la construction du frontend"
    exit 1
fi
cd ..

echo ""
echo "2️⃣  Construction du Backend..."
cd backend
docker build -t order-app-backend:latest .
if [ $? -eq 0 ]; then
    echo "✅ Backend construit"
else
    echo "❌ Erreur lors de la construction du backend"
    exit 1
fi
cd ..

echo ""
echo "═════════════════════════════════════"
echo "✅ Images construites avec succès!"
echo "═════════════════════════════════════"
echo ""
echo "Images disponibles:"
docker images | grep order-app
echo ""
echo "Prochaine étape:"
echo "  kind load docker-image order-app-frontend:latest --name order-app"
echo "  kind load docker-image order-app-backend:latest --name order-app"
echo ""
echo "Ou exécutez simplement: ./deploy.sh"
