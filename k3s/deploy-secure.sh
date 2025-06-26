#!/bin/bash
# ====================================
# SCRIPT DE DÉPLOIEMENT SIMPLIFIÉ
# ====================================
# Sans dashboard Traefik

set -e

echo "🚀 Déploiement de la stack DocuSeal (sans dashboard Traefik)..."
echo ""

# ====================================
# 1. VÉRIFIER LES SECRETS
# ====================================
echo "🔐 Vérification des secrets..."

if [ ! -f "secrets.yaml" ]; then
    echo "❌ Erreur: Le fichier secrets.yaml n'existe pas !"
    echo "   Exécutez d'abord: ./generate-secrets.sh"
    exit 1
fi

# ====================================
# 2. VÉRIFICATIONS KUBERNETES
# ====================================
echo "📋 Vérifications Kubernetes..."

if ! kubectl version &> /dev/null; then
    echo "❌ Erreur: kubectl n'est pas installé ou configuré"
    exit 1
fi

NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
if [ $NODE_COUNT -lt 2 ]; then
    echo "❌ Erreur: Il faut au moins 2 nodes (trouvé: $NODE_COUNT)"
    exit 1
fi

NODES=($(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'))
NODE1=${NODES[0]}
NODE2=${NODES[1]}

echo "✅ Cluster détecté:"
echo "   Node 1: $NODE1"
echo "   Node 2: $NODE2"

# ====================================
# 3. LABELLISER LES NODES
# ====================================
echo ""
echo "🏷️ Configuration des nodes..."

kubectl label node $NODE1 node-role=node1 --overwrite
kubectl label node $NODE2 node-role=node2 --overwrite

# ====================================
# 4. CRÉER LES NAMESPACES
# ====================================
echo ""
echo "📁 Création des namespaces..."

kubectl create namespace traefik --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace postgres --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace docuseal --dry-run=client -o yaml | kubectl apply -f -

kubectl label namespace traefik name=traefik --overwrite
kubectl label namespace postgres name=postgres --overwrite
kubectl label namespace docuseal name=docuseal --overwrite

# ====================================
# 5. DÉPLOYER LES SECRETS
# ====================================
echo ""
echo "🔐 Déploiement des secrets..."

kubectl apply -f secrets.yaml

# ====================================
# 6. DÉPLOYER TRAEFIK (SIMPLIFIÉ)
# ====================================
echo ""
echo "🔀 [1/3] Déploiement de Traefik (sans dashboard)..."

kubectl apply -f traefik/traefik-rbac.yaml
kubectl apply -f traefik/traefik-deployment.yaml
kubectl apply -f traefik/traefik-network.yaml
# PAS de traefik-service.yaml ni traefik-ingress.yaml !

echo "⏳ Attente de Traefik..."
kubectl wait --for=condition=available --timeout=120s deployment/traefik -n traefik || true

# ====================================
# 7. DÉPLOYER POSTGRESQL
# ====================================
echo ""
echo "🐘 [2/3] Déploiement de PostgreSQL..."

kubectl apply -f postgres/postgres-storage.yaml
kubectl apply -f postgres/postgres-config.yaml
kubectl apply -f postgres/postgres-deployment.yaml
kubectl apply -f postgres/postgres-service.yaml
kubectl apply -f postgres/postgres-network.yaml

echo "⏳ Attente de PostgreSQL..."
kubectl wait --for=condition=available --timeout=120s deployment/postgres -n postgres || true

# ====================================
# 8. DÉPLOYER DOCUSEAL
# ====================================
echo ""
echo "📄 [3/3] Déploiement de DocuSeal..."

kubectl apply -f docuseal/docuseal-storage.yaml
kubectl apply -f docuseal/docuseal-config.yaml
kubectl apply -f docuseal/docuseal-deployment.yaml
kubectl apply -f docuseal/docuseal-service.yaml
kubectl apply -f docuseal/docuseal-ingress.yaml
kubectl apply -f docuseal/docuseal-network.yaml

echo "⏳ Attente de DocuSeal..."
kubectl wait --for=condition=ready pod -l app=docuseal -n docuseal --timeout=300s || true

# ====================================
# 9. RÉSULTATS
# ====================================
NODE1_IP=$(kubectl get node $NODE1 -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')

echo ""
echo "✅ Déploiement terminé !"
echo ""
echo "🎉 ACCÈS :"
echo "========="
echo ""
echo "📄 DocuSeal : https://docuseal.vincent.mrt.fr"
echo ""
echo "📊 Architecture :"
echo "   Node1 ($NODE1) : Traefik + DocuSeal-0"
echo "   Node2 ($NODE2) : PostgreSQL + DocuSeal-1"
echo ""
echo "⚠️  NOTE : Pas de dashboard Traefik dans cette configuration"
echo ""
echo "💡 Commandes utiles :"
echo "   kubectl logs -n traefik deployment/traefik"
echo "   kubectl logs -n docuseal -l app=docuseal"
echo "   kubectl get pods -A -o wide"
