// Ambiente de produção (Docker / VM)
// API em HTTPS (TLS), porta 8443
// Keycloak acessado pelo domínio e-instancia.net via /etc/hosts
export const environment = {
  production: true,
  apiUrl: 'https://e-instancia.net:8443',
  keycloakUrl: 'http://e-instancia.net:8181',
  keycloakRealm: 'adorela',
  keycloakClientId: 'adorela-web'
};
