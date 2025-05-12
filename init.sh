#!/usr/bin/env bash
set -euo pipefail

# ╭─────────────────────────────────────────────────────────────╮
# │   N8N • POSTGRES • CLOUDFLARED • WATCHTOWER – BOOTSTRAP     │
# ╰─────────────────────────────────────────────────────────────╯
#  (powered by Jeremiaou 😻 – remix by ChatGPT 🚀)

# ────────────────
# Couleurs “so fancy”
# ────────────────
GREEN="\033[0;32m"    # ✅
CYAN="\033[0;36m"     # ℹ️
YELLOW="\033[1;33m"   # ⚠️
RESET="\033[0m"
TICK="${GREEN}✅${RESET}"
DOC_TUNNEL_LINK="https://github.com/JeremieAlcaraz/n8n-docker-postgre-cloudflared-watchtower/tree/main"


# Affiche le joli bandeau d'intro
cat <<'BANNER'
╭─────────────────────────────────────────────────────────────╮
│   N8N • POSTGRES • CLOUDFLARED • WATCHTOWER – BOOTSTRAP     │
╰─────────────────────────────────────────────────────────────╯
(powered by Jeremiaou 😻 – remix by ChatGPT 🚀)
BANNER

echo -e "${CYAN}✨ Initialisation de l’environnement n8n, ready ? ✨${RESET}\n"

# ────────────────
# 0) Vérifications rapides 🩺
# ────────────────
if [[ ! -f docker-compose.yml ]]; then
  echo -e "${YELLOW}🚨 Lance ce script à la racine du repo contenant ton docker‑compose.yml !${RESET}"
  exit 1
fi

# ────────────────
# 1) Saisie interactive des variables 🔐
# ────────────────
read -rp  "👤  User DB [n8n] : " DB_USER
DB_USER="${DB_USER:-n8n}"

read -rsp "🔑  Password DB (invisible) : " DB_PASSWORD; echo

read -rp  "🌍  Nom de domaine complet (ex : n8n.sandrineriguet.com) : " FULL_DOMAIN
if [[ -z "${FULL_DOMAIN}" ]]; then
  echo -e "${YELLOW}⚠️  Le domaine ne peut pas être vide.${RESET}"; exit 1
fi

# Affiche le tuto avant la saisie du token (lien cliquable dans la plupart des terminaux)
echo -e "${CYAN}📖  Besoin d’aide pour créer le token Cloudflare ? Suis le guide 👉 ${DOC_TUNNEL_LINK}${RESET}"
read -rp  "🔐  Token Cloudflare : " TUNNEL_TOKEN
if [[ -z "${TUNNEL_TOKEN}" ]]; then
  echo -e "${YELLOW}⚠️  Le token Cloudflare est obligatoire.${RESET}"; exit 1
fi

echo

# ────────────────
# 2) Génération / mise à jour du fichier .env 📄
# ────────────────
cat <<EOF > .env
########################################
# 🌱 Variables d’environnement n8n
# Généré automatiquement par bootstrap.sh
########################################

# ——— Database ———
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=n8n-db
DB_POSTGRESDB_USER=$DB_USER          # 👤 Utilisateur Postgres
DB_POSTGRESDB_PASSWORD=$DB_PASSWORD  # 🔑 Mot de passe Postgres
POSTGRES_USER=$DB_USER               # 👤 Utilisateur Postgres (service DB)
POSTGRES_PASSWORD=$DB_PASSWORD       # 🔑 Mot de passe Postgres (service DB)
POSTGRES_DB=$DB_USER                 # 🗄️  Nom de la base

# ——— n8n server ———
N8N_HOST=$FULL_DOMAIN                # 🌍 Nom de domaine public
N8N_PORT=5678                        # 🚪 Port interne n8n (défaut)
N8N_PROTOCOL=https                   # 🔒 Protocole
NODE_ENV=production                  # ⚙️  Mode prod
WEBHOOK_URL=https://$FULL_DOMAIN     # 🔗 URL webhook
GENERIC_TIMEZONE=Europe/Paris        # 🕑 Fuseau horaire

# ——— Cloudflared ———
TUNNEL_TOKEN=$TUNNEL_TOKEN           # 🔐 Token du tunnel Cloudflare
EOF

echo -e "${TICK} Fichier ${YELLOW}.env${RESET} généré / mis à jour ! 🎉"

# ────────────────
# 3) Récapitulatif (infos non sensibles) 📋
# ────────────────
echo -e "\n${GREEN}✔️  Configuration terminée !${RESET}"
echo -e "  Domaine        : ${YELLOW}$FULL_DOMAIN${RESET}"
echo -e "  Utilisateur DB : ${YELLOW}$DB_USER${RESET}"
echo -e "  Guide Token    : ${CYAN}${DOC_TUNNEL_LINK}${RESET}\n"

echo -e "${CYAN}🚀 Tu peux maintenant lancer :  docker compose up -d${RESET}"
