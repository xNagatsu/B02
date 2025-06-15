# Installation de K3S

Installation de k3s sans traefik

```bash
curl -sfL [https://get.k3s.io](https://get.k3s.io/) | INSTALL_K3S_EXEC="--disable traefik" sh -
```

Verification de l’instalaltion : 

```bash
sudo k3s kubectl get nodes
```

Configurer kubectl pour l’utilisateur actuel

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

Forcer kubectl à utiliser notre fichier $HOME/.kube/config

```bash
nano .bashrc
```

Puis on a joute la ligne en fin de fichier : 

```bash
export KUBECONFIG=$HOME/.kube/config
```

Charger le changement

```bash
source .bashrc
```

Test de kubectl

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```
# Installation de k3d
```
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

Créer un cluster avec 1 master + 2 workers (ajouts des 2 node worker)
```
k3d cluster create docuseal-cluster --agents 2
```

# Vérifier
```
kubectl get nodes
```
