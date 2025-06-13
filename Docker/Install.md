Installation de Docker

```
# Check if packages in conflict

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install the Docker Package
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Set Permission
sudo usermod -aG docker $USER
```
On doit se déconnecter pour que l'ajout au groupe soit effectif, mais parfois sur une VM, il est nécessaire de robot la machine, du coup redémarrer la machine directement.
```
sudo reboot
```

Installation de Portainer sans l'exposition du port 8000 car nous utiliseront pas l'agent.

```
# PortainerCE  Install
# Creating Volume
docker volume create portainer_data

# Deploy Portainer sans le port 8000 car nous installons 
docker run -d -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var
```
Je vais mettre en place une façon de faire pour ne pas exposer les ports sur mon hôte. 
Seuls les ports de mon reverse proxy seront exposé sur mon hôte, je ne pourrais donc pas accédez a mes service via ip:port 
Mais uniquement via le proxy via service:port

Pour mettre cela en place, je dois créer 2 réseaux 

Un réseau intermédiaire entre mon proxy et mes services auquel je veux accéder (Réseau de type interne : proxy_to_front, puis un réseau externe to_wan

```
docker network create to_wan
docker network create proxy_to_front --internal
```
