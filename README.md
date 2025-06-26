# Kubernetes 
> Cluster K3S avec 2 VM , un node sur le master et un node sur le worker
> 

## 📁 Structure des fichiers

```
~/kube/
├── deploy-secure.sh
├── generate-secrets.sh
├── secrets.yaml              # Ne pas commit !
├── .gitignore
├── postgres/
│   ├── postgres-storage.yaml
│   ├── postgres-config.yaml  # Sans secrets
│   ├── postgres-deployment.yaml
│   ├── postgres-service.yaml
│   └── postgres-network.yaml
├── docuseal/
│   ├── docuseal-storage.yaml
│   ├── docuseal-config.yaml  # Sans secrets
│   ├── docuseal-deployment.yaml
│   ├── docuseal-service.yaml
│   ├── docuseal-ingress.yaml
│   └── docuseal-network.yaml
└── traefik/
├── traefik-rbac.yaml
├── traefik-deployment.yaml  
└── traefik-network.yaml     
# SUPPRIMÉS DEPUIS PASSAGE A KUBERNETES SECRETS :
# - traefik-config.yaml (vide)
# - traefik-service.yaml
# - traefik-ingress.yaml
```

## 🚀 Déploiement de ma stack Docuseal
* Lancement de generate-secrets.sh pour rentrer les valeurs (OVH keys)
  * Il créer également un mot de passe random pour postgre
* Lancement de deploy-secure.sh
  * Il créer les namespaces
  * Labelise les nodes
  * Déploie les secrets précédemment générés
  * Déploie toute la stack
