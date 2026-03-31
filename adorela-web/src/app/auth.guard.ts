import { CanActivateFn } from '@angular/router';
import { authService } from './services/auth.service';

export const adminGuard: CanActivateFn = (route, state) => {
  if (!authService.isLoggedIn()) {
    // Redireciona o usuário para o Keycloak caso não esteja logado, e retorna para a URL atual depois
    authService.loginWithRedirect(state.url);
    return false;
  }
  
  // TODO: Implementar verificação de role no token JWT
  // Por enquanto, qualquer usuário logado pode acessar admin
  
  return true;
};
