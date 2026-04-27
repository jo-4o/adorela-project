#!/bin/sh
set -e

# Gera env.js com as variáveis de ambiente para o Angular
envsubst < /usr/share/nginx/html/assets/env.template.js > /usr/share/nginx/html/assets/env.js

# Gera nginx.conf a partir do template com as variáveis de proxy
export API_HOST="${API_HOST:-adorela-api}"
export API_PORT="${API_PORT:-8080}"
envsubst '${API_HOST} ${API_PORT}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

exec nginx -g 'daemon off;'
