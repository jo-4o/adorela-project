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

# Verificar certificados para HTTPS
if [ ! -f "../certs/api-cert.pem" ]; then
  echo "⚠️ AVISO: Certificados não encontrados em ../certs/."
  echo "  Tentando gerar certificados automaticamente..."
  chmod +x ../generate-certs.sh
  cd .. && ./generate-certs.sh && cd adorela-web
fi

echo ""
echo "=== Build concluído! ==="
echo ""
echo "Opção A - Servir com 'serve' (APENAS PARA TESTE RÁPIDO, SEM HTTPS):"
echo "  npx serve -s $DIST_DIR -l 80"
echo ""
echo "Opção B - Servir com Nginx e HTTPS (RECOMENDADO PARA ENTREGA):"
echo "  1. Instale o Nginx: sudo apt install nginx"
echo "  2. Copie os arquivos: sudo cp -r $DIST_DIR/* /var/www/html/"
echo "  3. Use o template 'nginx.conf.template' como base para o seu /etc/nginx/sites-available/default"
echo "  4. Certifique-se de que os certificados estão em /etc/nginx/certs/"
echo ""
echo "Opção C - Usar Docker (MAIS SEGURO E RÁPIDO):"
echo "  docker compose -f docker-compose.web.yml --env-file ../.env up -d --build"
echo ""

# Servir automaticamente se 'serve' estiver disponível
if command -v npx &> /dev/null; then
  echo "Servindo na porta 80 (precisa de sudo)..."
  sudo npx serve -s "$DIST_DIR" -l 80
fi
