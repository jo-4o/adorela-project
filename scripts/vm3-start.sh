#!/bin/bash
# =====================================================================
# VM 3 - Frontend Web (Angular, sem Docker)
#
# Pré-requisitos:
#   - Node.js 22+ e npm instalados
#   - O projeto clonado nesta VM
#
# Opção A: Serve com 'npx serve' (mais simples)
# Opção B: Serve com Nginx (mais robusto)
# =====================================================================

set -e

# ---------- Configuração ----------
# Troque pelos IPs reais das suas VMs
VM1_HOST="${VM1_HOST:-192.168.1.10}"
API_HOST="${API_HOST:-192.168.1.11}"

PROJECT_DIR="$(cd "$(dirname "$0")/../adorela-web" && pwd)"

echo "=== VM 3: Frontend Angular ==="

cd "$PROJECT_DIR"

# Instalar dependências
if [ ! -d "node_modules" ]; then
  echo "[1/3] Instalando dependências..."
  npm ci
else
  echo "[1/3] Dependências já instaladas."
fi

# Gerar env.js com as URLs corretas
echo "[2/3] Configurando URLs..."
mkdir -p public/assets
cat > public/assets/env.js << EOF
(function(window) {
  window.__env = window.__env || {};
  window.__env.API_URL = 'http://${API_HOST}:8080';
  window.__env.KEYCLOAK_URL = 'http://${VM1_HOST}:8080';
  window.__env.KEYCLOAK_REALM = 'adorela';
  window.__env.KEYCLOAK_CLIENT_ID = 'adorela-web';
})(this);
EOF

echo "  API: http://${API_HOST}:8080"
echo "  Keycloak: http://${VM1_HOST}:8080"

# Build de produção
echo "[3/3] Buildando Angular..."
npx ng build --configuration production

DIST_DIR="$PROJECT_DIR/dist/adorela-web/browser"

echo ""
echo "=== Build concluído! ==="
echo ""
echo "Opção A - Servir com 'serve' (simples):"
echo "  npx serve -s $DIST_DIR -l 80"
echo ""
echo "Opção B - Servir com Nginx:"
echo "  sudo cp -r $DIST_DIR/* /var/www/html/"
echo "  (configure o Nginx com proxy_pass para http://${API_HOST}:8080 em /api/)"
echo ""

# Servir automaticamente se 'serve' estiver disponível
if command -v npx &> /dev/null; then
  echo "Servindo na porta 80 (precisa de sudo)..."
  sudo npx serve -s "$DIST_DIR" -l 80
fi
