#!/bin/bash
# =====================================================================
# VM 2 - Backend API (Spring Boot, sem Docker)
#
# Pré-requisitos:
#   - Java 17+ instalado
#   - O projeto clonado nesta VM
#
# O script builda e roda o JAR diretamente.
# =====================================================================

set -e

# ---------- Configuração ----------
# Troque pelos IPs reais das suas VMs
DB_HOST="${DB_HOST:-192.168.0.40}"
WEB_HOST="${WEB_HOST:-192.168.0.38}"

export SPRING_DATASOURCE_URL="jdbc:postgresql://${DB_HOST}:5432/adorela"
export SPRING_DATASOURCE_USERNAME="${POSTGRES_USER:-postgres}"
export SPRING_DATASOURCE_PASSWORD="${POSTGRES_PASSWORD:-123456}"
export SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI="http://${DB_HOST}:8181/realms/adorela"
export ADORELA_CORS_ALLOWED_ORIGINS="http://${WEB_HOST}"
export ADORELA_UPLOAD_DIR="${ADORELA_UPLOAD_DIR:-./uploads}"

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== VM 2: Backend API ==="
echo "  Banco: $SPRING_DATASOURCE_URL"
echo "  Keycloak: $SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI"
echo "  CORS: $ADORELA_CORS_ALLOWED_ORIGINS"
echo ""

cd "$PROJECT_DIR"

# Criar pasta de uploads
mkdir -p "$ADORELA_UPLOAD_DIR"

# Build se não existir JAR ou se o código mudou
JAR_FILE=$(find target -name "*.jar" ! -name "*.original" 2>/dev/null | head -1)

if [ -z "$JAR_FILE" ]; then
  echo "[1/2] Buildando o projeto..."
  ./mvnw clean package -DskipTests -q
  JAR_FILE=$(find target -name "*.jar" ! -name "*.original" | head -1)
else
  echo "[1/2] JAR já existe: $JAR_FILE (use ./mvnw clean package -DskipTests pra rebuildar)"
fi

echo "[2/2] Iniciando API na porta 8080..."
echo "  Swagger: http://localhost:8080/swagger-ui.html"
echo ""

java -jar "$JAR_FILE"
