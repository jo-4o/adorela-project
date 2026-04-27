#!/bin/bash
# =================================================================
# Script de inicialização de usuários do Keycloak via Admin REST API
#
# Cria os 3 usuários com roles após o Keycloak estar disponível.
# As senhas são lidas do .env — nunca ficam no realm JSON.
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

# Função auxiliar: cria usuário e atribui role
create_user() {
  local USERNAME="$1"
  local EMAIL="$2"
  local FIRST="$3"
  local LAST="$4"
  local PASS="$5"
  local ROLE="$6"

  echo "--> Criando usuário: ${USERNAME} (role: ${ROLE})"

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

  # Busca ID da role
  ROLE_ID=$(curl -sf \
    -H "Authorization: Bearer ${TOKEN}" \
    "${KC_URL}/admin/realms/${KC_REALM}/roles/${ROLE}" \
    | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

  # Atribui role ao usuário
  curl -sf -X POST \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    -d "[{\"id\": \"${ROLE_ID}\", \"name\": \"${ROLE}\"}]" \
    "${KC_URL}/admin/realms/${KC_REALM}/users/${USER_ID}/role-mappings/realm"

  echo "    OK - ${USERNAME} criado com role '${ROLE}'"
}

# Cria os 3 usuários com suas respectivas roles e senhas do .env
create_user "dono"    "dono@adorela.com"    "Admin"  "Dono"    "${USER_DONO_PASS}"    "dono"
create_user "gerente" "gerente@adorela.com" "Maria"  "Gerente" "${USER_GERENTE_PASS}" "gerente"
create_user "revisao" "revisao@adorela.com" "Joao"   "Revisao" "${USER_REVISAO_PASS}" "revisao"

echo ""
echo "==> Usuários criados com sucesso no realm '${KC_REALM}'!"
