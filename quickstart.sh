#!/bin/bash

# Script de vérification des prérequis et information rapide
# Exécutez: ./quickstart.sh

echo "════════════════════════════════════════════════════════════"
echo "🚀 Vérification des Prérequis"
echo "════════════════════════════════════════════════════════════"
echo ""

# Vérifier Docker
if command -v docker &> /dev/null; then
    docker_version=$(docker --version)
    echo "✅ Docker: $docker_version"
else
    echo "❌ Docker: Non installé"
    echo "   Installez Docker: https://www.docker.com/products/docker-desktop"
fi

# Vérifier Kind
if command -v kind &> /dev/null; then
    kind_version=$(kind --version)
    echo "✅ Kind: $kind_version"
else
    echo "❌ Kind: Non installé"
    echo "   Installez Kind: go install sigs.k8s.io/kind@latest"
fi

# Vérifier kubectl
if command -v kubectl &> /dev/null; then
    kubectl_version=$(kubectl version --client --short 2>/dev/null || echo "installé")
    echo "✅ kubectl: $kubectl_version"
else
    echo "❌ kubectl: Non installé"
    echo "   Installez kubectl: https://kubernetes.io/docs/tasks/tools/"
fi

# Vérifier Java
if command -v java &> /dev/null; then
    java_version=$(java -version 2>&1 | head -1)
    echo "✅ Java: $java_version"
else
    echo "❌ Java: Non installé"
    echo "   Installez Java 21+"
fi

# Vérifier Maven
if command -v mvn &> /dev/null; then
    mvn_version=$(mvn --version | head -1)
    echo "✅ Maven: $mvn_version"
else
    echo "❌ Maven: Non installé"
    echo "   Installez Maven"
fi

# Vérifier Node.js
if command -v node &> /dev/null; then
    node_version=$(node --version)
    echo "✅ Node.js: $node_version"
else
    echo "❌ Node.js: Non installé"
    echo "   Installez Node.js"
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo "📚 Documentation"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "1. Démarrage Rapide"
echo "   → Lire: README.md"
echo ""
echo "2. Comprendre l'Architecture"
echo "   → Lire: ARCHITECTURE.md"
echo ""
echo "3. Guide de Déploiement"
echo "   → Lire: DEPLOYMENT_GUIDE.md"
echo ""
echo "4. Exercices Pratiques"
echo "   → Lire: EXERCISES.md"
echo ""
echo "5. Commandes Kubernetes"
echo "   → Lire: KUBECTL_CHEATSHEET.md"
echo ""
echo "6. Structure du Projet"
echo "   → Lire: STRUCTURE.md"
echo ""

echo "════════════════════════════════════════════════════════════"
echo "🚀 Démarrer l'Application"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Exécutez:"
echo "  chmod +x deploy.sh cleanup.sh"
echo "  ./deploy.sh"
echo ""
echo "Puis accédez à:"
echo "  kubectl port-forward service/frontend 8080:80 &"
echo "  open http://localhost:8080"
echo ""
echo "════════════════════════════════════════════════════════════"
