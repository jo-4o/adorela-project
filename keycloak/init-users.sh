#!/bin/bash
# =================================================================
# Script de inicialização de usuários do Keycloak via Admin REST API
#
# Cria os 4 usuários do sistema com suas respectivas roles.
# As senhas são lidas do .env — nunca ficam hardcoded aqui.
#
# Usuários criados:
#   admin        → roles: dono, gerente, revisao, limitado, exclusivo1, exclusivo2
#   user_limitado → role: limitado
#   user_ex1      → role: exclusivo1
#   user_ex2      → role: exclusivo2
#
# Execute após o docker-compose up:
#   bash keycloak/init-users.sh
# =================================================================

set -e

KC_URL="${KEYCLOAK_URL:-http://localhost:8181}"
KC_REALM="adorela"
KC_ADMIN="${KEYCLOAK_ADMIN:-admin}"
KC_ADMIN_PASS="${KEYCLOAK_ADMIN_PASSWORD:-admin}"

# Senhas dos usuários de negócio — lidas do ambiente (.env)
USER_DONO_PASS="${ADORELA_USER_DONO_PASSWORD:?Defina ADORELA_USER_DONO_PASSWORD no .env}"
USER_GERENTE_PASS="${ADORELA_USER_GERENTE_PASSWORD:?Defina ADORELA_USER_GERENTE_PASSWORD no .env}"
USER_REVISAO_PASS="${ADORELA_USER_REVISAO_PASSWORD:?Defina ADORELA_USER_REVISAO_PASSWORD no .env}"
USER_LIMITADO_PASS="${ADORELA_USER_LIMITADO_PASSWORD:?Defina ADORELA_USER_LIMITADO_PASSWORD no .env}"
USER_EX1_PASS="${ADORELA_USER_EX1_PASSWORD:?Defina ADORELA_USER_EX1_PASSWORD no .env}"
USER_EX2_PASS="${ADORELA_USER_EX2_PASSWORD:?Defina ADORELA_USER_EX2_PASSWORD no .env}"

echo "==> Aguardando Keycloak estar disponível em ${KC_URL}..."
until curl -sf "${KC_URL}/realms/master" > /dev/null 2>&1; do
  sleep 3
done
echo "==> Keycloak disponível!"

echo "==> Obtendo token de admin..."
TOKEN=$(curl -sf \
  -d "client_id=admin-cli" \
  -d "username=${KC_ADMIN}" \
  -d "password=${KC_ADMIN_PASS}" \
  -d "grant_type=password" \
  "${KC_URL}/realms/master/protocol/openid-connect/token" \
  | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "ERRO: Não foi possível obter token de admin. Verifique KEYCLOAK_ADMIN e KEYCLOAK_ADMIN_PASSWORD."
  exit 1
fi

# Função auxiliar: cria usuário e atribui uma ou mais roles
# Uso: create_user USERNAME EMAIL FIRST LAST PASS ROLE1 [ROLE2 ...]
create_user() {
  local USERNAME="$1"
  local EMAIL="$2"
  local FIRST="$3"
  local LAST="$4"
  local PASS="$5"
  shift 5
  local ROLES=("$@")

  echo "--> Criando usuário: ${USERNAME} (roles: ${ROLES[*]})"

  # Verifica se já existe
  EXISTS=$(curl -sf \
    -H "Authorization: Bearer ${TOKEN}" \
    "${KC_URL}/admin/realms/${KC_REALM}/users?username=${USERNAME}" \
    | grep -c '"id"' || true)

  if [ "$EXISTS" -gt 0 ]; then
    echo "    (já existe, pulando criação)"
  else
    # Cria usuário
    curl -sf -X POST \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      -d "{
        \"username\": \"${USERNAME}\",
        \"email\": \"${EMAIL}\",
        \"firstName\": \"${FIRST}\",
        \"lastName\": \"${LAST}\",
        \"enabled\": true,
        \"emailVerified\": true,
        \"credentials\": [{
          \"type\": \"password\",
          \"value\": \"${PASS}\",
          \"temporary\": false
        }]
      }" \
      "${KC_URL}/admin/realms/${KC_REALM}/users"
  fi

  # Busca ID do usuário
  USER_ID=$(curl -sf \
    -H "Authorization: Bearer ${TOKEN}" \
    "${KC_URL}/admin/realms/${KC_REALM}/users?username=${USERNAME}" \
    | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

  # Monta payload JSON com todas as roles
  ROLE_PAYLOAD="["
  FIRST_ROLE=true
  for ROLE in "${ROLES[@]}"; do
    ROLE_ID=$(curl -sf \
      -H "Authorization: Bearer ${TOKEN}" \
      "${KC_URL}/admin/realms/${KC_REALM}/roles/${ROLE}" \
      | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ "$FIRST_ROLE" = true ]; then
      FIRST_ROLE=false
    else
      ROLE_PAYLOAD+=","
    fi
    ROLE_PAYLOAD+="{\"id\": \"${ROLE_ID}\", \"name\": \"${ROLE}\"}"
  done
  ROLE_PAYLOAD+="]"

  # Atribui todas as roles ao usuário
  curl -sf -X POST \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    -d "${ROLE_PAYLOAD}" \
    "${KC_URL}/admin/realms/${KC_REALM}/users/${USER_ID}/role-mappings/realm"

  echo "    OK - ${USERNAME} criado com roles: ${ROLES[*]}"
}

# ─── Usuários originais ─────────────────────────────────────────────────────
create_user "dono"    "dono@adorela.com"    "Admin"   "Dono"    "${USER_DONO_PASS}"    "dono"
create_user "gerente" "gerente@adorela.com" "Maria"   "Gerente" "${USER_GERENTE_PASS}" "gerente"
create_user "revisao" "revisao@adorela.com" "Joao"    "Revisao" "${USER_REVISAO_PASS}" "revisao"

# ─── Novos usuários (Entrega 03) ────────────────────────────────────────────
create_user "admin"        "admin@adorela.local"      "Admin"   "Sistema"  "${USER_DONO_PASS}"     \
  "dono" "gerente" "revisao" "limitado" "exclusivo1" "exclusivo2"

create_user "user_limitado" "limitado@adorela.local"  "Usuário" "Limitado"  "${USER_LIMITADO_PASS}" "limitado"
create_user "user_ex1"      "exclusivo1@adorela.local" "Usuário" "Exclusivo1" "${USER_EX1_PASS}"    "exclusivo1"
create_user "user_ex2"      "exclusivo2@adorela.local" "Usuário" "Exclusivo2" "${USER_EX2_PASS}"    "exclusivo2"

echo ""
echo "==> Usuários criados com sucesso no realm '${KC_REALM}'!"
