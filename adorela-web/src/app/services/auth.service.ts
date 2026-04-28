import Keycloak from 'keycloak-js';
import { environment } from '../../environments/environment';

/**
 * AuthService — integração OIDC com Keycloak.
 *
 * Perfis suportados pelo realm adorela:
 *   - dono       → acesso total ao sistema
 *   - gerente    → criar/editar produtos e categorias
 *   - revisao    → somente leitura
 *   - limitado   → visualização de produtos públicos
 *   - exclusivo1 → área exclusiva grupo 1
 *   - exclusivo2 → área exclusiva grupo 2
 */
class AuthService {
  private keycloak: Keycloak | null = null;
  private refreshIntervalId: ReturnType<typeof setInterval> | null = null;

  /**
   * Inicializa o cliente Keycloak com fluxo OIDC (check-sso).
   *
   * Utiliza `onLoad: 'check-sso'` para detectar sessão ativa sem forçar
   * redirecionamento imediato — ideal para SPAs que têm páginas públicas.
   * O `silentCheckSsoRedirectUri` evita flash de login em iframes.
   */
  async init(): Promise<boolean> {
    this.keycloak = new Keycloak({
      url: environment.keycloakUrl,
      realm: environment.keycloakRealm,
      clientId: environment.keycloakClientId
    });

    const authenticated = await this.keycloak.init({
      onLoad: 'check-sso',
      checkLoginIframe: false,
      silentCheckSsoRedirectUri:
        window.location.origin + '/assets/silent-check-sso.html'
    });

    if (authenticated) {
      this.scheduleTokenRefresh();
    }

    return authenticated;
  }

  // ─── Navegação ────────────────────────────────────────────────────────────

  login(): void {
    this.keycloak?.login();
  }

  /**
   * Faz login redirecionando de volta para `returnPath` após autenticação.
   * Funciona tanto em localhost:4200 quanto em https://sistema1.net.
   */
  loginWithRedirect(returnPath: string): void {
    const redirectUri = window.location.origin + (returnPath || '/');
    this.keycloak?.login({ redirectUri });
  }

  logout(): void {
    this.clearRefreshInterval();
    this.keycloak?.logout({
      redirectUri: window.location.origin + '/login'
    });
  }

  // ─── Token ────────────────────────────────────────────────────────────────

  getToken(): string | null {
    return this.keycloak?.token ?? null;
  }

  isLoggedIn(): boolean {
    return !!this.keycloak?.token;
  }

  /**
   * Atualiza o token se faltar menos de `minValidity` segundos para expirar.
   * Retorna true se atualizado com sucesso, false caso contrário.
   */
  async updateToken(minValidity: number = 30): Promise<boolean> {
    if (!this.keycloak) return false;
    try {
      return await this.keycloak.updateToken(minValidity);
    } catch {
      return false;
    }
  }

  /**
   * Retorna informações do usuário logado (sub, preferred_username, email).
   */
  getUserInfo(): { id: string; username: string; email: string } | null {
    const p = this.keycloak?.tokenParsed;
    if (!p) return null;
    return {
      id: p['sub'] ?? '',
      username: p['preferred_username'] ?? '',
      email: p['email'] ?? ''
    };
  }

  // ─── Roles ────────────────────────────────────────────────────────────────

  /**
   * Verifica se o usuário logado possui uma role específica (realm role).
   */
  hasRole(role: string): boolean {
    return this.keycloak?.hasRealmRole(role) ?? false;
  }

  /**
   * Retorna lista de realm roles do usuário autenticado.
   */
  getRoles(): string[] {
    return this.keycloak?.realmAccess?.roles ?? [];
  }

  // ─── Helpers de perfil ────────────────────────────────────────────────────

  /** Acesso total — perfil dono */
  isDono(): boolean {
    return this.hasRole('dono');
  }

  /** Pode criar/editar — perfil gerente ou dono */
  isGerente(): boolean {
    return this.hasRole('gerente') || this.hasRole('dono');
  }

  /** Somente leitura — perfil revisao, gerente ou dono */
  isRevisao(): boolean {
    return this.hasRole('revisao') || this.isGerente();
  }

  /** Acesso limitado — apenas produtos públicos */
  isLimitado(): boolean {
    return this.hasRole('limitado');
  }

  /** Área exclusiva grupo 1 */
  isExclusivo1(): boolean {
    return this.hasRole('exclusivo1');
  }

  /** Área exclusiva grupo 2 */
  isExclusivo2(): boolean {
    return this.hasRole('exclusivo2');
  }

  // ─── Privado ──────────────────────────────────────────────────────────────

  private scheduleTokenRefresh(): void {
    // Atualiza token a cada 60 segundos
    this.refreshIntervalId = setInterval(async () => {
      await this.updateToken(70);
    }, 60_000);
  }

  private clearRefreshInterval(): void {
    if (this.refreshIntervalId) {
      clearInterval(this.refreshIntervalId);
      this.refreshIntervalId = null;
    }
  }
}

export const authService = new AuthService();
