# Adorela

Sistema de gestão de produtos e categorias — Projeto Mensal 3 (Engenharia de Software 2026.1).

## Stack

- **Backend:** Spring Boot 3 (Java 17), Spring Security (OAuth2 Resource Server / JWT)
- **Frontend:** Angular 18 + TailwindCSS + Nginx
- **Banco:** PostgreSQL 16
- **IAM:** Keycloak 21
- **Infra:** Docker / Docker Compose (alvo: 3 VMs)

---

## 📋 Checklist de Progresso (PM3)

Legenda: ✅ pronto · 🟡 parcial · ❌ não iniciado

### Fase 1 — Frontend e Keycloak (prazo 05/05)

| # | Requisito | Status | Onde está / o que falta |
|---|-----------|--------|-------------------------|
| 1 | Frontend Angular hospedado em container | ✅ | [adorela-web/Dockerfile](adorela-web/Dockerfile) + [nginx.conf](adorela-web/nginx.conf) |
| 2 | Frontend com **TLS** habilitado (HTTPS) | ❌ | Nginx só escuta `:80` em [nginx.conf#L2](adorela-web/nginx.conf#L2) — falta certificado e bloco `listen 443 ssl` |
| 3 | Frontend com **HSTS** habilitado | ❌ | Falta header `Strict-Transport-Security` no Nginx |
| 4 | Keycloak rodando (Realm Único) | ✅ | Realm `adorela` em [keycloak/realm-adorela.json](keycloak/realm-adorela.json) e [docker-compose.yml#L21](docker-compose.yml#L21) |
| 5 | Keycloak com **4 perfis**: Admin, Limitado, Exclusivo 1, Exclusivo 2 | 🟡 | Só existe a role `admin` em [realm-adorela.json#L14-L17](keycloak/realm-adorela.json#L14-L17). Faltam `limitado`, `exclusivo1`, `exclusivo2` + 1 usuário de cada |
| 6 | Configuração de `/etc/hosts` para `sistema1.net` e `sistema2.net` | ❌ | Não documentado nem aplicado |
| 7 | Frontend integrado ao Keycloak (login real) | 🟡 | Existem [auth.service.ts](adorela-web/src/app/services/auth.service.ts), [auth.guard.ts](adorela-web/src/app/auth.guard.ts) e [auth.interceptor.ts](adorela-web/src/app/services/auth.interceptor.ts), mas precisa validar fluxo OIDC real com os 4 perfis |

### Fase 2 — Backend e Infraestrutura (prazo 07/05)

| # | Requisito | Status | Onde está / o que falta |
|---|-----------|--------|-------------------------|
| 8  | API RESTful Spring Boot | ✅ | [CategoryController.java](src/main/java/com/adorela/api/controllers/CategoryController.java), [ProductController.java](src/main/java/com/adorela/api/controllers/ProductController.java), [UploadController.java](src/main/java/com/adorela/api/controllers/UploadController.java) |
| 9  | API integrada ao Keycloak (JWT) | ✅ | [SecurityConfig.java](src/main/java/com/adorela/api/config/SecurityConfig.java) + `issuer-uri` em [application.properties#L24](src/main/resources/application.properties#L24) |
| 10 | Autorização por perfil (`@PreAuthorize`) | 🟡 | Hoje só `hasRole('admin')` (ver matches em [CategoryController.java#L35](src/main/java/com/adorela/api/controllers/CategoryController.java#L35), [ProductController.java#L71](src/main/java/com/adorela/api/controllers/ProductController.java#L71)). Precisa diferenciar Limitado / Exclusivo1 / Exclusivo2 |
| 11 | Tomcat (embedded) com **TLS** | ❌ | [application.properties](src/main/resources/application.properties) usa `server.port=8080` HTTP. Falta `server.ssl.*` + keystore |
| 12 | PostgreSQL com **TLS** | ❌ | [docker-compose.yml#L4-L9](docker-compose.yml#L4-L9) sem `ssl=on`, sem certificados, sem `sslmode=require` na URL JDBC |
| 13 | Isolamento lógico entre sistemas | ❌ | Tudo na mesma rede default do compose. Falta segmentar redes / schemas |
| 14 | Deploy em 3 VMs (VM1=Front, VM2=Back, VM3=DB) | ❌ | Hoje tudo roda em 1 host via [docker-compose.yml](docker-compose.yml). Falta separar compose por VM e variáveis de host |

### Fase Final — Compliance e Segurança (prazo 14/05)

| # | Requisito | Status | Observação |
|---|-----------|--------|------------|
| 15 | Diagrama da arquitetura distribuída (3 VMs) | ❌ | Criar em `docs/arquitetura.png` |
| 16 | Passo a passo de configuração das VMs, TLS e Keycloak | ❌ | Criar `docs/deploy.md` |
| 17 | Documento de políticas e regras de segurança | ❌ | Criar `docs/seguranca.md` |
| 18 | Relatório **OWASP ZAP** (XSS, CSRF, etc.) | ❌ | Rodar ZAP contra front + back e salvar em `docs/owasp-zap.html` |
| 19 | Mitigações implementadas e documentadas | ❌ | Anotar correções no relatório |
| 20 | Testes funcionais com os 4 perfis de usuário | ❌ | Roteiro de teste em `docs/testes.md` |
| 21 | Validação TLS via `openssl s_client` | ❌ | Coletar evidências (saída de `openssl`) e anexar |
| 22 | Documentação para deploy por outros grupos (premiação) | 🟡 | Existe README básico — precisa ficar “plug and play” |

---

## 👥 Divisão de Tarefas

> Ideia: separar por *camadas/responsabilidades* para minimizar conflito de merge. Cada um abre PRs para `main`.

### 🧑‍💻 João — Backend + TLS da API
- [ ] #10 Refinar `@PreAuthorize` para os 4 perfis (`admin`, `limitado`, `exclusivo1`, `exclusivo2`) em [CategoryController.java](src/main/java/com/adorela/api/controllers/CategoryController.java), [ProductController.java](src/main/java/com/adorela/api/controllers/ProductController.java) e [UploadController.java](src/main/java/com/adorela/api/controllers/UploadController.java).
- [ ] #11 Habilitar TLS no Tomcat embedded (gerar keystore PKCS12, configurar `server.ssl.*` em [application.properties](src/main/resources/application.properties), expor `8443`).
- [ ] #9/#10 Ajustar mapeamento de roles do JWT em [SecurityConfig.java](src/main/java/com/adorela/api/config/SecurityConfig.java) (claim `roles` → `ROLE_*`).
- [ ] Atualizar [Dockerfile](Dockerfile) para copiar o keystore e expor `8443`.
- [ ] Apoiar #18/#19 nas correções de segurança do backend (CSRF/headers).

### 🧑‍💻 Victor — Keycloak + IAM
- [ ] #5 Adicionar roles `limitado`, `exclusivo1`, `exclusivo2` em [realm-adorela.json](keycloak/realm-adorela.json).
- [ ] #5 Criar 1 usuário por perfil (admin / user_limitado / user_ex1 / user_ex2) com senhas e `realmRoles` corretos.
- [ ] #7 Validar fluxo OIDC real no Angular ([auth.service.ts](adorela-web/src/app/services/auth.service.ts)) com cada perfil.
- [ ] Configurar `redirectUris` e `webOrigins` para `https://sistema1.net` (não só `localhost:4200`).
- [ ] #20 Roteiro de teste com os 4 usuários (`docs/testes.md`).

### 🧑‍💻 Matheus — Frontend (TLS, HSTS, Hosts) + Front Hardening
- [ ] #2 Habilitar HTTPS no Nginx ([nginx.conf](adorela-web/nginx.conf)) com `listen 443 ssl`, certificado em `/etc/nginx/certs`.
- [ ] #3 Adicionar `add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;`.
- [ ] #2 Redirect 80 → 443.
- [ ] #6 Documentar entradas em `/etc/hosts` (`sistema1.net`, `sistema2.net`) em `docs/deploy.md`.
- [ ] Atualizar [adorela-web/Dockerfile](adorela-web/Dockerfile) para incluir certificados e expor `443`.
- [ ] #18 Mitigar XSS encontrados no ZAP (sanitização Angular, CSP).

### 🧑‍💻 Pedro — Infra (3 VMs, Postgres TLS, ZAP, Documentação)
- [ ] #12 Habilitar TLS no Postgres (gerar `server.crt`/`server.key`, montar em [docker-compose.yml#L4](docker-compose.yml#L4), `command: -c ssl=on -c ssl_cert_file=... -c ssl_key_file=...`).
- [ ] #12 Ajustar JDBC URL para `?sslmode=require` em [application.properties#L5](src/main/resources/application.properties#L5).
- [ ] #13/#14 Quebrar [docker-compose.yml](docker-compose.yml) em 3 arquivos: `compose.vm1-frontend.yml`, `compose.vm2-backend.yml`, `compose.vm3-db.yml` + `.env` por VM.
- [ ] #15 Diagrama da arquitetura (`docs/arquitetura.png`).
- [ ] #16 `docs/deploy.md` — passo a passo das VMs, TLS e Keycloak.
- [ ] #17 `docs/seguranca.md` — políticas aplicadas.
- [ ] #18/#19 Rodar OWASP ZAP, salvar relatório e listar mitigações.
- [ ] #21 Coletar saída de `openssl s_client -connect sistema1.net:443` (e DB).
- [ ] #22 Polir documentação para deploy por outros grupos (premiação).

---

## 🚀 Execução local (estado atual)

```bash
git clone <repo-url>
cd adorela-project
docker compose up -d --build
```

Serviços (HTTP — TLS ainda não configurado):

- Frontend: http://localhost:4200
- API: http://localhost:8080 — Swagger em http://localhost:8080/swagger-ui.html
- Keycloak: http://localhost:8181 (admin/admin)
- Postgres: `localhost:5433` (postgres/123456)

## 🛠️ Desenvolvimento

### Backend
```bash
docker compose up -d postgres keycloak
./mvnw spring-boot:run
```

### Frontend
```bash
cd adorela-web
npm install
npm start
```

## 📁 Estrutura

```
adorela-project/
├── src/                    # Backend Spring Boot
├── adorela-web/            # Frontend Angular + Nginx
├── keycloak/               # Realm de importação
├── docker-compose.yml      # Stack atual (single host)
├── Dockerfile              # Build da API
└── docs/                   # (a criar) diagramas, deploy, segurança, OWASP
```

## 🧪 Testes

```bash
./mvnw test
cd adorela-web && npm test
```

## 📅 Prazos

| Entrega | Data | Responsáveis principais |
|---------|------|-------------------------|
| Frontend + Keycloak (TLS/HSTS, 4 perfis, /etc/hosts) | **05/05** | Matheus, Victor |
| Backend + Infra (Tomcat TLS, DB TLS, 3 VMs) | **07/05** | João, Pedro |
| Compliance (Diagrama, Docs, OWASP ZAP, openssl) | **14/05** | Pedro (lidera), todos |

## Licença

MIT
