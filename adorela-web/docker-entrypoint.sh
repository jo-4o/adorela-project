#!/bin/sh
set -e

# Gera env.js com as variáveis de ambiente para o Angular
envsubst < /usr/share/nginx/html/assets/env.template.js > /usr/share/nginx/html/assets/env.js

# Gera nginx.conf a partir do template com as variáveis de proxy
export API_HOST="${API_HOST:-adorela-api}"
export API_PORT="${API_PORT:-8080}"
export KEYCLOAK_URL="${KEYCLOAK_URL:-http://localhost:8080}"

# Se CSP_CONNECT_SRC não for definido, monta um default baseado nos hosts
if [ -z "$CSP_CONNECT_SRC" ]; then
    export CSP_CONNECT_SRC="${API_HOST}:${API_PORT} ${KEYCLOAK_URL} *.net"
fi

envsubst '${API_HOST} ${API_PORT} ${CSP_CONNECT_SRC}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

exec nginx -g 'daemon off;'
