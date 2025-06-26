#!/bin/bash

# ====================================
# GÉNÉRATEUR DE SECRETS KUBERNETES
# ====================================
# Ce script génère un fichier secrets.yaml avec des valeurs sécurisées

set -e

echo "🔐 Génération des secrets Kubernetes..."

# Fonction pour générer un mot de passe sécurisé
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# Fonction pour générer une clé secrète Rails
generate_rails_secret() {
    openssl rand -hex 64
}

# Demander les informations OVH
echo ""
echo "📋 Configuration API OVH (pour Let's Encrypt)"
echo "Si vous n'avez pas ces clés, créez-les sur: https://eu.api.ovh.com/createToken/"
echo ""

read -p "OVH Application Key: " OVH_APP_KEY
read -p "OVH Application Secret: " OVH_APP_SECRET
read -p "OVH Consumer Key: " OVH_CONSUMER_KEY

# Générer les mots de passe
POSTGRES_PASSWORD=$(generate_password)
RAILS_SECRET=$(generate_rails_secret)

# Créer le fichier secrets.yaml
cat > secrets.yaml << EOF
# ====================================
# SECRETS KUBERNETES - GÉNÉRÉ AUTOMATIQUEMENT
# ====================================
# Généré le: $(date)
# ⚠️  NE PAS COMMITER CE FICHIER !

# ====================================
# POSTGRESQL
# ====================================
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
  namespace: postgres
type: Opaque
stringData:
  POSTGRES_PASSWORD: "${POSTGRES_PASSWORD}"

---
# ====================================
# DOCUSEAL
# ====================================
apiVersion: v1
kind: Secret
metadata:
  name: docuseal-secret
  namespace: docuseal
type: Opaque
stringData:
  SECRET_KEY_BASE: "${RAILS_SECRET}"
  DATABASE_URL: "postgresql://docuseal_user:${POSTGRES_PASSWORD}@postgres-service.postgres:5432/docuseal"

---
# ====================================
# TRAEFIK (OVH)
# ====================================
apiVersion: v1
kind: Secret
metadata:
  name: traefik-ovh-secret
  namespace: traefik
type: Opaque
stringData:
  OVH_ENDPOINT: "ovh-eu"
  OVH_APPLICATION_KEY: "${OVH_APP_KEY}"
  OVH_APPLICATION_SECRET: "${OVH_APP_SECRET}"
  OVH_CONSUMER_KEY: "${OVH_CONSUMER_KEY}"
EOF

# Créer aussi un fichier de sauvegarde
cat > secrets-backup.txt << EOF
=== SAUVEGARDE DES SECRETS ===
Généré le: $(date)

PostgreSQL Password: ${POSTGRES_PASSWORD}
Rails Secret Key: ${RAILS_SECRET}
OVH Application Key: ${OVH_APP_KEY}
OVH Application Secret: ${OVH_APP_SECRET}
OVH Consumer Key: ${OVH_CONSUMER_KEY}

Database URL: postgresql://docuseal_user:${POSTGRES_PASSWORD}@postgres-service.postgres:5432/docuseal
EOF

# Sécuriser les fichiers
chmod 600 secrets.yaml secrets-backup.txt

echo ""
echo "✅ Secrets générés avec succès !"
echo ""
echo "📁 Fichiers créés :"
echo "   - secrets.yaml : À utiliser avec kubectl apply"
echo "   - secrets-backup.txt : Sauvegarde des valeurs"
echo ""
echo "🔒 IMPORTANT :"
echo "   1. Ajoutez ces lignes dans .gitignore :"
echo "      secrets.yaml"
echo "      secrets-backup.txt"
echo "      *.key"
echo "      *.secret"
echo ""
echo "   2. Gardez une copie sécurisée de secrets-backup.txt"
echo "   3. Ne partagez JAMAIS ces fichiers"
echo ""
