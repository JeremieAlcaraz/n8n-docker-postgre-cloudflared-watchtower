#!/usr/bin/env bash
set -euo pipefail

# ╭─────────────────────────────────────────────────────────────╮
# │   N8N • POSTGRES • CLOUDFLARED • WATCHTOWER – BOOTSTRAP     │
# ╰─────────────────────────────────────────────────────────────╯
#  (powered by Jeremiaou 😻 – remix by ChatGPT 🚀)

# ────────────────
# Couleurs “so fancy”
# ────────────────
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"
TICK="${GREEN}✅${RESET}"
DOC_TUNNEL_LINK="https://github.com/JeremieAlcaraz/n8n-docker-postgre-cloudflared-watchtower/tree/main"

# ────────────────
# Fonctions utilitaires
# ────────────────
error() { echo -e "${RED}❌ $*${RESET}"; }
warn() { echo -e "${YELLOW}⚠️  $*${RESET}"; }
info() { echo -e "${CYAN}ℹ️  $*${RESET}"; }

valid_identifier() { [[ $1 =~ ^[A-Za-z0-9_]+$ ]]; }

# Bandeau
cat <<'BANNER'
╭─────────────────────────────────────────────────────────────╮
│   N8N • POSTGRES • CLOUDFLARED • WATCHTOWER – BOOTSTRAP     │
╰─────────────────────────────────────────────────────────────╯
(powered by Jeremiaou 😻 – remix by ChatGPT 🚀)
BANNER
info "✨ Initialisation de l’environnement n8n, ready ? ✨\n"

# ────────────────
# 0) Vérifications rapides
# ────────────────
[[ -f docker-compose.yml ]] || {
  warn "Lance ce script à la racine du repo contenant ton docker-compose.yml !"
  exit 1
}

# ────────────────
# 1) Variables interactives
# ────────────────
read -rp "👤  User DB [n8n] : " DB_USER
DB_USER="${DB_USER:-n8n}"
valid_identifier "$DB_USER" || {
  error "Seuls lettres, chiffres ou _ sont autorisés."
  exit 1
}

while true; do
  read -rsp "🔑  Password DB (min 4 caractères) : " DB_PASSWORD
  echo
  [[ ${#DB_PASSWORD} -ge 4 ]] && break
  warn "Mot de passe trop court."
done

DB_NAME="n8n" # ← imposé, plus de saisie

read -rp "🌍  Nom de domaine complet (ex : n8n.example.com) : " FULL_DOMAIN
[[ -z $FULL_DOMAIN ]] && {
  error "Le domaine ne peut pas être vide."
  exit 1
}

# ────────────────
# 1.a) Clé tunnel cloudflared
# ────────────────

info "📖  Besoin d’aide pour le token Cloudflare ? ${DOC_TUNNEL_LINK}"
read -rp "🔐  Token Cloudflare : " TUNNEL_TOKEN
[[ -z $TUNNEL_TOKEN ]] && {
  error "Le token Cloudflare est obligatoire."
  exit 1
}
echo

# ────────────────
# 1.b) Clé Firecrawl
# ────────────────
while true; do
  read -rsp "🔥  Clé API Firecrawl (non vide) : " FIRECRAWL_API_KEY
  echo
  [[ -n $FIRECRAWL_API_KEY ]] && break
  warn "La clé Firecrawl ne peut pas être vide."
done
echo

# ────────────────
# 2) Génération du .env
# ────────────────
cat <<EOF >.env
########################################
# 🌱 Variables d’environnement n8n
# Généré automatiquement par bootstrap.sh
########################################

# ——— Database ———
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=n8n-db
DB_POSTGRESDB_USER=$DB_USER
DB_POSTGRESDB_PASSWORD=$DB_PASSWORD
DB_POSTGRESDB_DATABASE=$DB_NAME
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

# ——— Firecrawl ———
FIRECRAWL_API_KEY=$FIRECRAWL_API_KEY

EOF
echo -e "${TICK} Fichier ${YELLOW}.env${RESET} généré / mis à jour !"

# ────────────────
# 3) Récapitulatif
# ────────────────
echo -e "\n${GREEN}✔️  Configuration terminée !${RESET}"
echo -e "  Domaine        : ${YELLOW}$FULL_DOMAIN${RESET}"
echo -e "  Utilisateur DB : ${YELLOW}$DB_USER${RESET}"
echo -e "  Base de données: ${YELLOW}$DB_NAME${RESET}"
echo -e "  Guide Token    : ${CYAN}${DOC_TUNNEL_LINK}${RESET}\n"

info "🚀 Tu peux maintenant lancer :  docker compose up -d"
