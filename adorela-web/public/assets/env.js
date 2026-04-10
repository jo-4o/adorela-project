// Arquivo de configuração em runtime.
// Em desenvolvimento, os defaults de environment.ts são usados.
// Em produção (Docker), este arquivo é gerado pelo entrypoint com os valores reais.
(function(window) {
  window.__env = window.__env || {};
  // window.__env.API_URL = 'http://localhost:8080';
  // window.__env.KEYCLOAK_URL = 'http://localhost:8181';
})(this);
