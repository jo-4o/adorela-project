#!/bin/bash
# =====================================================================
# VM 1 - PostgreSQL + Keycloak (sem Docker)
#
# Pré-requisitos:
#   - Ubuntu/Debian com PostgreSQL instalado
#   - Java 17+ instalado
#   - Keycloak 21.1.1 baixado em /opt/keycloak
#
# Instalação rápida (rodar como root/sudo):
#   apt update && apt install -y postgresql openjdk-17-jre-headless
#   wget -qO- https://github.com/keycloak/keycloak/releases/download/21.1.1/keycloak-21.1.1.tar.gz | tar xz -C /opt
#   ln -s /opt/keycloak-21.1.1 /opt/keycloak
# =====================================================================

set -e

# ---------- Configuração ----------
POSTGRES_DB="${POSTGRES_DB:-adorela}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-123456}"
KEYCLOAK_ADMIN="${KEYCLOAK_ADMIN:-admin}"
KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-admin}"
KEYCLOAK_DIR="${KEYCLOAK_DIR:-/opt/keycloak}"
REALM_FILE="$(dirname "$0")/keycloak/realm-adorela.json"

echo "=== VM 1: Configurando PostgreSQL + Keycloak ==="

# ---------- PostgreSQL ----------
echo "[1/3] Configurando banco de dados..."
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname='$POSTGRES_DB'" | grep -q 1 || \
  sudo -u postgres createdb "$POSTGRES_DB"

sudo -u postgres psql -c "ALTER USER $POSTGRES_USER PASSWORD '$POSTGRES_PASSWORD';" 2>/dev/null

# Permitir conexões externas
PGCONF=$(sudo -u postgres psql -tc "SHOW config_file" | xargs)
PGHBA=$(sudo -u postgres psql -tc "SHOW hba_file" | xargs)

if ! grep -q "listen_addresses = '\*'" "$PGCONF" 2>/dev/null; then
  echo "  Configurando PostgreSQL para aceitar conexões externas..."
  sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PGCONF"
  echo "host    all    all    0.0.0.0/0    md5" | sudo tee -a "$PGHBA" > /dev/null
  sudo systemctl restart postgresql
fi

echo "  Banco '$POSTGRES_DB' pronto."

# ---------- Keycloak ----------
echo "[2/3] Iniciando Keycloak..."

if [ ! -d "$KEYCLOAK_DIR" ]; then
  echo "  ERRO: Keycloak não encontrado em $KEYCLOAK_DIR"
  echo "  Baixe com: wget -qO- https://github.com/keycloak/keycloak/releases/download/21.1.1/keycloak-21.1.1.tar.gz | tar xz -C /opt && ln -s /opt/keycloak-21.1.1 /opt/keycloak"
  exit 1
fi

export KEYCLOAK_ADMIN
export KEYCLOAK_ADMIN_PASSWORD
export KC_DB=postgres
export KC_DB_URL="jdbc:postgresql://localhost:5432/$POSTGRES_DB"
export KC_DB_USERNAME="$POSTGRES_USER"
export KC_DB_PASSWORD="$POSTGRES_PASSWORD"
export KC_HTTP_ENABLED=true
export KC_HOSTNAME_STRICT=false

# Importar realm se existir
IMPORT_FLAG=""
if [ -f "$REALM_FILE" ]; then
  mkdir -p "$KEYCLOAK_DIR/data/import"
  cp "$REALM_FILE" "$KEYCLOAK_DIR/data/import/"
  IMPORT_FLAG="--import-realm"
fi

echo "[3/3] Keycloak rodando na porta 8080..."
echo "  Admin: http://localhost:8080 (user: $KEYCLOAK_ADMIN / pass: $KEYCLOAK_ADMIN_PASSWORD)"

"$KEYCLOAK_DIR/bin/kc.sh" start-dev $IMPORT_FLAG
