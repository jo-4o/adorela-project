# Stage 1: Build
FROM docker.io/library/node:20-alpine AS build
WORKDIR /app
# Fix for podman rootless capability drops:
RUN chown -R node:node /app
USER node
COPY --chown=node:node package*.json ./
RUN npm ci
COPY --chown=node:node . .
RUN npm run build

# Stage 2: Run
FROM docker.io/library/nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/adorela-web/browser /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
