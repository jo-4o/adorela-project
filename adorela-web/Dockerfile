# Stage 1: Build Angular
FROM docker.io/library/node:22-alpine AS build
WORKDIR /app
# Fix for podman rootless capability drops:
RUN chown -R node:node /app
USER node
COPY --chown=node:node package.json package-lock.json* ./
RUN npm ci
COPY --chown=node:node . .
RUN npm run build -- --configuration production

# Stage 2: Serve com Nginx
FROM docker.io/library/nginx:1.27-alpine
WORKDIR /usr/share/nginx/html

# Remove config padrão do Nginx
RUN rm -rf /etc/nginx/conf.d/default.conf /usr/share/nginx/html/*

# Copia o build do Angular (output path: dist/adorela-web/browser)
COPY --from=build /app/dist/adorela-web/browser ./

# Copia template de config do Nginx
COPY nginx.conf.template /etc/nginx/conf.d/default.conf.template

# Certificados TLS são montados via volume no docker-compose
# (./certs/ -> /etc/nginx/certs/)

# Copia template de env.js para substituição em runtime
COPY public/assets/env.template.js /usr/share/nginx/html/assets/env.template.js

# Copia entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/docker-entrypoint.sh"]
