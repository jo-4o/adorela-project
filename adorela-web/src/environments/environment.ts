/**
 * Configuração de ambiente com suporte a injeção em runtime (Docker).
 *
 * Em desenvolvimento, usa os valores padrão (localhost).
 * Em produção (Docker), o entrypoint gera /assets/env.js que popula window.__env
 * ANTES do Angular inicializar.
 */
const env = (window as any).__env || {};

export const environment = {
  apiUrl: env.API_URL || 'http://localhost:8080',
  keycloakUrl: env.KEYCLOAK_URL || 'http://localhost:8181',
  keycloakRealm: env.KEYCLOAK_REALM || 'adorela',
  keycloakClientId: env.KEYCLOAK_CLIENT_ID || 'adorela-web',
};
