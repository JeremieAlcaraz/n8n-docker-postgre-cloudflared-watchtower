#!/usr/bin/env bash
set -euo pipefail

# ╭─────────────────────────────────────────────────────────────╮
# │   N8N • POSTGRES • CLOUDFLARED • WATCHTOWER – BOOTSTRAP     │
# ╰─────────────────────────────────────────────────────────────╯
#  (powered by Jeremiaou 😻 – remix by ChatGPT 🚀)

# ────────────────
# Couleurs “so fancy”
# ────────────────
GREEN="\033[0;32m"    # ✅
CYAN="\033[0;36m"     # ℹ️
YELLOW="\033[1;33m"   # ⚠️
RED="\033[0;31m"      # ❌
RESET="\033[0m"
TICK="${GREEN}✅${RESET}"
DOC_TUNNEL_LINK="https://github.com/JeremieAlcaraz/n8n-docker-postgre-cloudflared-watchtower/tree/main"

# ╭─────────────────────────────────────────────────────────────╮
# │  Fonctions utilitaires                                     │
# ╰─────────────────────────────────────────────────────────────╯
error() { echo -e "${RED}❌ $*${RESET}"; }
warn()  { echo -e "${YELLOW}⚠️  $*${RESET}"; }
info()  { echo -e "${CYAN}ℹ️  $*${RESET}"; }

valid_identifier() {
  [[ $1 =~ ^[A-Za-z0-9_]+$ ]]
}

# ╭─────────────────────────────────────────────────────────────╮
# │  Bandeau d’intro                                           │
# ╰─────────────────────────────────────────────────────────────╯
cat <<'BANNER'
╭─────────────────────────────────────────────────────────────╮
│   N8N • POSTGRES • CLOUDFLARED • WATCHTOWER – BOOTSTRAP     │
╰─────────────────────────────────────────────────────────────╯
(powered by Jeremiaou 😻 – remix by ChatGPT 🚀)
BANNER

info "✨ Initialisation de l’environnement n8n, ready ? ✨\n"

# ────────────────
# 0) Vérifications rapides 🩺
# ────────────────
if [[ ! -f docker-compose.yml ]]; then
  warn "Lance ce script à la racine du repo contenant ton docker-compose.yml !"
  exit 1
fi

# ────────────────
# 1) Saisie interactive des variables 🔐
# ────────────────
read -rp  "👤  User DB [n8n] : " DB_USER
DB_USER="${DB_USER:-n8n}"

if ! valid_identifier "$DB_USER"; then
  error "L’identifiant ne doit contenir que lettres, chiffres ou _ (pas d’espace)."
  exit 1
fi

# Mot de passe : au moins 4 caractères
while true; do
  read -rsp "🔑  Password DB (min 4 caractères) : " DB_PASSWORD; echo
  [[ ${#DB_PASSWORD} -ge 4 ]] && break
  warn "Mot de passe trop court."
done

read -rp  "🗄️   Nom de la base [$DB_USER] : " DB_NAME
DB_NAME="${DB_NAME:-$DB_USER}"

if ! valid_identifier "$DB_NAME"; then
  error "Le nom de base ne doit contenir que lettres, chiffres ou _ (pas d’espace)."
  exit 1
fi

read -rp  "🌍  Nom de domaine complet (ex : n8n.example.com) : " FULL_DOMAIN
[[ -z $FULL_DOMAIN ]] && { error "Le domaine ne peut pas être vide."; exit 1; }

info "📖  Besoin d’aide pour le token Cloudflare ? ${DOC_TUNNEL_LINK}"
read -rp  "🔐  Token Cloudflare : " TUNNEL_TOKEN
[[ -z $TUNNEL_TOKEN ]] && { error "Le token Cloudflare est obligatoire."; exit 1; }

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
DB_POSTGRESDB_USER=$DB_USER
DB_POSTGRESDB_PASSWORD=$DB_PASSWORD
DB_POSTGRESDB_DATABASE=$DB_NAME      # ← n8n en a besoin
POSTGRES_USER=$DB_USER
POSTGRES_PASSWORD=$DB_PASSWORD
POSTGRES_DB=$DB_NAME

# ——— n8n server ———
N8N_HOST=$FULL_DOMAIN
N8N_PORT=5678
N8N_PROTOCOL=https
NODE_ENV=production
WEBHOOK_URL=https://$FULL_DOMAIN
GENERIC_TIMEZONE=Europe/Paris
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# ——— Cloudflared ———
TUNNEL_TOKEN=$TUNNEL_TOKEN
EOF

echo -e "${TICK} Fichier ${YELLOW}.env${RESET} généré / mis à jour !"

# ────────────────
# 3) Récapitulatif (infos non sensibles) 📋
# ────────────────
echo -e "\n${GREEN}✔️  Configuration terminée !${RESET}"
echo -e "  Domaine        : ${YELLOW}$FULL_DOMAIN${RESET}"
echo -e "  Utilisateur DB : ${YELLOW}$DB_USER${RESET}"
echo -e "  Base de données: ${YELLOW}$DB_NAME${RESET}"
echo -e "  Guide Token    : ${CYAN}${DOC_TUNNEL_LINK}${RESET}\n"

info "🚀 Tu peux maintenant lancer :  docker compose up -d"
