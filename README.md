
# Installation de n8n avec Multipass et Cloudflared

Ce projet permet de créer une instance n8n de chez soi via un tunnel SSH (cloudflared) en utilisant multipass pour créer une VM. Il y a également Watchtower qui permet une MàJ automatique de n8n.

---

## Prérequis

- Un nom de domaine enregistré ou proxisé sur Cloudflare
- Multipass installé sur votre machine hôte

## Étapes d'installation

### 1. Installation de Multipass

Téléchargez et installez Multipass depuis le site officiel : [https://canonical.com/multipass](https://canonical.com/multipass)

### 2. Création et connextion à l'instance Ubuntu avec Docker

Ouvrez le terminal de votre machine hôte et exécutez la commande suivante :

```bash
multipass launch docker \
  --name <instance_name> \
  --cpus 2 \
  --memory 4G \
  --disk 50G \
  --bridged

multipass shell <instance_name>
```


### 3. Clonage du repository

Une fois connecté à l'instance, clonez le repository :

```bash
git clone https://github.com/JeremieAlcaraz/n8n-cloudflared-install-multipass.git
```

### 4. Configuration du fichier .env

#### 4.1 Démarrer le script d'initialisation

Se placer dans le dossier 

```bash
cd n8n-cloudflared-install-multipass.git
```

Rendre le script exécutable

```bash
chmod +x init.sh
```

Exécuter le script de démarrage 

```bash
./bootstrap.sh
```

#### 4.2 Création du tunnel Cloudflared

1. Connectez-vous à [https://one.dash.cloudflare.com](https://one.dash.cloudflare.com)
2. Naviguez dans le menu latéral vers "Network"
3. Choisissez "Créer un tunnel cloudflared"
4. Nommez le tunnel (par exemple : `n8n_app_prod`)
5. Sélectionnez Docker
6. Copiez la commande et extrayez uniquement le token
7. Rentrer les infos suivantes en adaptant votre nom de domaine (puis enregistrer)

   ![10109](https://github.com/user-attachments/assets/25416f3a-1dfd-45b8-bfeb-3e6a77d8aa7a)

Puis suivre les directives dans le terminal ! 

### 6. Lancement de l'application

Une fois le fichier .env ready, lancer la stack n8n avec la commande : 

```bash
docker compose up -d
```

## Dépannage

- Assurez-vous que votre nom de domaine est correctement configuré sur Cloudflare
- Vérifiez les permissions et la validité du token Cloudflared
- Consultez les logs en cas de problème d'installation

## Ressources

- [Documentation Multipass](https://multipass.run/docs)
- [Documentation Cloudflare](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Documentation n8n](https://docs.n8n.io/)

