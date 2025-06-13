# 🚀 Install
Pour avoir accès en HTTPS et en URL à notre Docuseal, il nous faut un reverse Proxy. 

On va l'installer dans une nouvelle stack dans Portainer tout comme nous l'avons fait pour Docuseal 
Voici le [docker-compose.yml](https://github.com/xNagatsu/B02/blob/main/nginx-proxy-manager/docker-compose.yml)

# ⚙️ Config
Ensuite, on doit mettre en place un certificat SSL 
Pour cela, on peut soit le faire à la création de l'hôte, ou bien en amont. 

![ssl](https://github.com/user-attachments/assets/85f7a8bd-9724-44aa-baaf-65354f306fec)

Une fois le certificat SSL en notre possession, on créer notre hôte en renseignant l'URL et la zone de destination puis nous disons qu'il faut utiliser le certificat que l'on vient d'obtenir. 

![image](https://github.com/user-attachments/assets/f87c5874-b0d5-46dd-94ad-2d6f5701eb8e)
 ![host](https://github.com/user-attachments/assets/f0379c1e-dc8e-431a-8c55-eb95a913b77e)

Maintenant grâce au enregistrement DNS de notre routeur ou bien de notre fichier host, on peut se rendre sur :
https://vincent.mrt.fr 

Et voilà !  
(￣y▽,￣)╭ 
