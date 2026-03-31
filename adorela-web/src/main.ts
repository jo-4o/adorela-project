import 'zone.js'; // Esta linha DEVE ser a primeira do arquivo
import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app/app.config';
import { AppComponent } from './app/app';
import { authService } from './app/services/auth.service';

(async () => {
  try {
    await authService.init();
  } catch (e) {
    // falha na inicialização do Keycloak não impede app de subir
    console.warn('Keycloak init falhou', e);
  }

  bootstrapApplication(AppComponent, appConfig)
    .catch((err) => console.error(err));
})();