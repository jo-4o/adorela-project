import Keycloak from 'keycloak-js';
import { environment } from '../../environments/environment';

class AuthService {
  private keycloak: Keycloak | null = null;
  private refreshIntervalId: ReturnType<typeof setInterval> | null = null;

  async init(): Promise<boolean> {
    this.keycloak = new Keycloak({
      url: environment.keycloakUrl,
      realm: environment.keycloakRealm,
      clientId: environment.keycloakClientId
    });

    const authenticated = await this.keycloak.init({
      checkLoginIframe: false
    });

    if (authenticated) {
      this.scheduleTokenRefresh();
    }

    return authenticated;
  }

  login(): void {
    this.keycloak?.login();
  }

  loginWithRedirect(returnPath: string): void {
    const redirectUri = window.location.origin + (returnPath || '/');
    this.keycloak?.login({ redirectUri });
  }

  logout(): void {
    this.clearRefreshInterval();
    this.keycloak?.logout();
  }

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
      const refreshed = await this.keycloak.updateToken(minValidity);
      return refreshed;
    } catch {
      return false;
    }
  }

  /**
   * Verifica se o usuário logado possui uma role específica (realm role).
   */
  hasRole(role: string): boolean {
    return this.keycloak?.hasRealmRole(role) ?? false;
  }

  /**
   * Retorna lista de realm roles do usuário.
   */
  getRoles(): string[] {
    return this.keycloak?.realmAccess?.roles ?? [];
  }

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
