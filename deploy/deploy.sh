#!/bin/bash
# =============================================================================
#  Script de déploiement BURINFORT GED — Production
#  Usage : bash deploy.sh [build|start|stop|restart|logs|update]
# =============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_DIR="$REPO_DIR/compose"
SHARE_DIR="$REPO_DIR/share-theme"
COMPOSE_FILES="-f community-compose.yaml -f prod-override.yaml"

cd "$COMPOSE_DIR"

# Charger les variables d'environnement
if [ -f "$REPO_DIR/.env" ]; then
   set -a; source "$REPO_DIR/.env"; set +a
   echo "✓ Variables .env chargées"
else
   echo "⚠ ATTENTION : Fichier .env introuvable !"
   echo "  Copiez .env.example vers .env et renseignez vos valeurs."
   exit 1
fi

command="${1:-help}"

case "$command" in
   build)
      echo "=== Construction de l'image Share bordeaux ==="
      cd "$SHARE_DIR"
      docker build -t alfresco-share-bordeaux:latest .
      echo "✓ Image alfresco-share-bordeaux:latest construite"
      cd "$COMPOSE_DIR"
      ;;

   start)
      echo "=== Démarrage de la stack BURINFORT GED ==="
      docker compose $COMPOSE_FILES up -d
      echo ""
      echo "✓ Stack démarrée. Attente que les services soient prêts..."
      echo "  Suivez les logs avec : bash deploy.sh logs"
      echo "  ACS sera disponible dans ~2-3 min sur https://$PUBLIC_DOMAIN"
      ;;

   stop)
      echo "=== Arrêt de la stack ==="
      docker compose $COMPOSE_FILES down
      ;;

   restart)
      echo "=== Redémarrage de la stack ==="
      docker compose $COMPOSE_FILES down
      docker compose $COMPOSE_FILES up -d
      ;;

   update)
      echo "=== Mise à jour depuis Git ==="
      cd "$REPO_DIR"
      git pull origin master
      cd "$SHARE_DIR"
      docker build -t alfresco-share-bordeaux:latest .
      cd "$COMPOSE_DIR"
      docker compose $COMPOSE_FILES up -d --no-deps --force-recreate share
      echo "✓ Mise à jour Share terminée"
      ;;

   logs)
      docker compose $COMPOSE_FILES logs -f --tail=100 "${2:-}"
      ;;

   status)
      docker compose $COMPOSE_FILES ps
      ;;

   full-deploy)
      echo "=== Déploiement complet (build + start) ==="
      bash "$REPO_DIR/deploy/deploy.sh" build
      bash "$REPO_DIR/deploy/deploy.sh" start
      ;;

   local-start)
      echo "=== Démarrage local (dev) ==="
      cd "$SHARE_DIR"
      docker build -t alfresco-share-bordeaux:latest .
      cd "$COMPOSE_DIR"
      docker compose -f community-compose.yaml -f local-override.yaml up -d
      echo ""
      echo "✓ Stack locale démarrée."
      echo "  ACS disponible dans ~2-3 min sur http://localhost:8085/share"
      ;;

   local-stop)
      echo "=== Arrêt de la stack locale ==="
      docker compose -f community-compose.yaml -f local-override.yaml down
      ;;

   local-update)
      echo "=== Mise à jour locale (rebuild Share) ==="
      cd "$SHARE_DIR"
      docker build -t alfresco-share-bordeaux:latest .
      cd "$COMPOSE_DIR"
      docker compose -f community-compose.yaml -f local-override.yaml up -d --no-deps --force-recreate share
      echo "✓ Share local mis à jour"
      ;;

   openclaw-start)
      echo "=== Démarrage OpenClaw + BOAMP Cron ==="
      cd "$COMPOSE_DIR"
      docker compose --env-file "$REPO_DIR/.env" -f openclaw-compose.yaml up -d
      echo ""
      echo "✓ OpenClaw Gateway  : http://localhost:18789"
      echo "✓ BOAMP Cron        : archivage automatique toutes les 24h"
      ;;

   openclaw-stop)
      echo "=== Arrêt OpenClaw ==="
      cd "$COMPOSE_DIR"
      docker compose -f openclaw-compose.yaml down
      ;;

   openclaw-status)
      cd "$COMPOSE_DIR"
      docker compose -f openclaw-compose.yaml ps
      ;;

   openclaw-logs)
      cd "$COMPOSE_DIR"
      docker compose -f openclaw-compose.yaml logs -f --tail=100 "${2:-}"
      ;;

   *)
      echo "Usage : bash deploy.sh <commande>"
      echo ""
      echo "  build         Construire l'image Share personnalisée"
      echo "  start         Démarrer tous les services"
      echo "  stop          Arrêter tous les services"
      echo "  restart       Redémarrer tous les services"
      echo "  update        Mettre à jour depuis Git + reconstruire Share"
      echo "  logs [svc]    Voir les logs (optionnel: nom du service)"
      echo "  status        État des containers"
      echo "  full-deploy   Build + Start en une commande"
      echo ""
      echo "  openclaw-start   Démarrer OpenClaw Gateway + BOAMP Cron"
      echo "  openclaw-stop    Arrêter OpenClaw"
      echo "  openclaw-status  État des services OpenClaw"
      echo "  openclaw-logs    Logs OpenClaw en temps réel"
      ;;
esac
