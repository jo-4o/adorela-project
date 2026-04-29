# Adorela

Sistema de gestão de produtos e categorias — Projeto Mensal 3 (Engenharia de Software 2026.1).

## Stack

- **Backend:** Spring Boot 3 (Java 17), Spring Security (OAuth2 Resource Server / JWT)
- **Frontend:** Angular 18 + TailwindCSS + Nginx
- **Banco:** PostgreSQL 16
- **IAM:** Keycloak 21
- **Infra:** Docker / Docker Compose (alvo: 3 VMs)
- **Backend:** Spring Boot 4, PostgreSQL, Keycloak
- **Frontend:** Angular 21, Tailwind CSS

## Arquitetura de Deploy (3 VMs)

```
┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│       VM 1          │     │       VM 2          │     │       VM 3          │
│  PostgreSQL :5432   │◄────│  Spring Boot :8080  │     │   Angular :80       │
│  Keycloak   :8080   │     │  (adorela-api)      │     │  (adorela-web)      │
│                     │     │                     │     │                     │
│  scripts/           │     │  scripts/           │     │  scripts/           │
│  vm1-start.sh       │     │  vm2-start.sh       │     │  vm3-start.sh       │
└─────────────────────┘     └─────────────────────┘     └─────────────────────┘
         ▲                           ▲                           │
         │                           │          API calls        │
         │                           └───────────────────────────┘
         │                                       ▲
         └───────────────────────────────────────┘
                    JWT issuer-uri
```

---

## 📋 Checklist de Progresso (PM3)

Legenda: ✅ pronto · 🟡 parcial · ❌ não iniciado

### Fase 1 — Frontend e Keycloak (prazo 05/05)

| # | Requisito | Status | Onde está / o que falta |
|---|-----------|--------|-------------------------|
| 1 | Frontend Angular hospedado em container | ✅ | [adorela-web/Dockerfile](adorela-web/Dockerfile) + [nginx.conf](adorela-web/nginx.conf) |
| 2 | Frontend com **TLS** habilitado (HTTPS) | ✅ | Configurado no `nginx.conf` escutando na porta 443 |
| 3 | Frontend com **HSTS** habilitado | ✅ | Header `Strict-Transport-Security` configurado no Nginx |
| 4 | Keycloak rodando (Realm Único) | ✅ | Realm `adorela` em [keycloak/realm-adorela.json](keycloak/realm-adorela.json) e [docker-compose.yml#L21](docker-compose.yml#L21) |
| 5 | Keycloak com **4 perfis**: Admin, Limitado, Exclusivo 1, Exclusivo 2 | ✅ | 6 roles declaradas + 4 usuários (`admin`, `user_limitado`, `user_ex1`, `user_ex2`) com `realmRoles` corretos em [realm-adorela.json](keycloak/realm-adorela.json) |
| 6 | Configuração de `/etc/hosts` para `sistema1.net` e `sistema2.net` | ✅ | Documentado no `docs/deploy.md` e testado localmente |
| 7 | Frontend integrado ao Keycloak (login real) | ✅ | Fluxo OIDC `check-sso` configurado, `silentCheckSsoRedirectUri` e helpers `isDono/isGerente/isRevisao/isLimitado/isExclusivo1/isExclusivo2` em [auth.service.ts](adorela-web/src/app/services/auth.service.ts) |

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
| 20 | Testes funcionais com os 4 perfis de usuário | ✅ | Roteiro com 6 casos de teste (TC-01 a TC-06) em [docs/testes.md](docs/testes.md) |
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
- [x] #5 Adicionar roles `limitado`, `exclusivo1`, `exclusivo2` em [realm-adorela.json](keycloak/realm-adorela.json).
- [x] #5 Criar 1 usuário por perfil (admin / user_limitado / user_ex1 / user_ex2) com senhas e `realmRoles` corretos.
- [x] #7 Validar fluxo OIDC real no Angular ([auth.service.ts](adorela-web/src/app/services/auth.service.ts)) com cada perfil.
- [x] Configurar `redirectUris` e `webOrigins` para `https://sistema1.net` (não só `localhost:4200`).
- [x] #20 Roteiro de teste com os 4 usuários (`docs/testes.md`).

### 🧑‍💻 Matheus — Frontend (TLS, HSTS, Hosts) + Front Hardening
- [✅] #2 Habilitar HTTPS no Nginx ([nginx.conf](adorela-web/nginx.conf)) com `listen 443 ssl`, certificado em `/etc/nginx/certs`.
- [✅] #3 Adicionar `add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;`.
- [✅] #2 Redirect 80 → 443.
- [✅] #6 Documentar entradas em `/etc/hosts` (`sistema1.net`, `sistema2.net`) em `docs/deploy.md`.
- [✅] Atualizar [adorela-web/Dockerfile](adorela-web/Dockerfile) para incluir certificados e expor `443`.
- [✅] #18 Mitigar XSS encontrados no ZAP (sanitização Angular, CSP).

**Comandos de Validação (Provas Técnicas - Matheus):**
- **TLS/Certificado:** `openssl s_client -connect localhost:443 -showcerts < /dev/null`
- **HSTS e CSP:** `curl -I -k https://localhost`
- **Redirect 80->443:** `curl -I http://localhost`
- **Arquivo Hosts:** `ping -n 4 sistema1.net` e `curl -I -k https://sistema2.net`
- **Dockerfile e Portas:** `docker ps` e `docker exec adorela-web ls -la /etc/nginx/certs/`

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
Nas VMs (Ubuntu/Debian recomendado):

| VM | Requisitos |
|----|------------|
| VM 1 | PostgreSQL 16+, Java 17+ (para Keycloak) |
| VM 2 | Java 17+, Maven |
| VM 3 | Node.js 22+, npm |

---

## Deploy em Produção (3 VMs, sem Docker)

### 1. Clonar o projeto em cada VM

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

### 2. VM 1 — PostgreSQL + Keycloak

Instalar dependências:

```bash
sudo apt update && sudo apt install -y postgresql openjdk-17-jre-headless

# Baixar Keycloak 21.1.1
wget -qO- https://github.com/keycloak/keycloak/releases/download/21.1.1/keycloak-21.1.1.tar.gz | tar xz -C /opt
sudo ln -s /opt/keycloak-21.1.1 /opt/keycloak
```

Iniciar:

```bash
chmod +x scripts/vm1-start.sh
./scripts/vm1-start.sh
```

> Isso configura o PostgreSQL, importa o realm do Keycloak e inicia tudo.
>
> Após o primeiro start, acesse `http://<VM1_IP>:8080` e no client `adorela-web`:
> - **Valid Redirect URIs:** `http://<VM3_IP>/*`
> - **Web Origins:** `http://<VM3_IP>`

### 3. VM 2 — Backend API

Instalar dependências:

```bash
sudo apt update && sudo apt install -y openjdk-17-jdk maven
```

Configurar IPs e iniciar:

```bash
chmod +x scripts/vm2-start.sh
export VM1_HOST=<IP_DA_VM1>      # PostgreSQL + Keycloak
export WEB_HOST=<IP_DA_VM3>      # Frontend (para CORS)
./scripts/vm2-start.sh
```

### 4. VM 3 — Frontend Web

Instalar dependências:

```bash
# Instalar Node.js 22
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
```

Configurar IPs e iniciar:

```bash
chmod +x scripts/vm3-start.sh
export VM1_HOST=<IP_DA_VM1>      # Keycloak
export API_HOST=<IP_DA_VM2>      # Backend API
./scripts/vm3-start.sh
```

### Verificação

| Serviço    | URL                                      |
| ---------- | ---------------------------------------- |
| Frontend   | `http://<VM3_IP>`                        |
| API        | `http://<VM2_IP>:8080/api/products`      |
| Swagger    | `http://<VM2_IP>:8080/swagger-ui.html`   |
| Keycloak   | `http://<VM1_IP>:8080`                   |

---

## Desenvolvimento Local
### Backend
```bash
# Subir PostgreSQL + Keycloak localmente (precisa tê-los instalados)
# Ou usar Docker se disponível:
# docker compose up -d postgres keycloak

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
Frontend em http://localhost:4200

---

## Deploy com Docker (opcional)

Se tiver Docker disponível, também existem arquivos Docker Compose por VM:

```bash
cp .env.example .env
# Ajustar IPs no .env

# VM 1
docker compose -f docker-compose.db.yml --env-file .env up -d

# VM 2
docker compose -f docker-compose.api.yml --env-file .env up -d --build

# VM 3
docker compose -f docker-compose.web.yml --env-file .env up -d --build
```

---

## Autenticação

- **Realm:** adorela
- **Client:** adorela-web
- **Usuário padrão:** admin / admin

## Estrutura do Projeto

```
adorela-project/
├── src/                        # Backend Spring Boot
├── adorela-web/                # Frontend Angular
├── keycloak/
│   └── realm-adorela.json      # Configuração do realm
├── scripts/
│   ├── vm1-start.sh            # VM 1: PostgreSQL + Keycloak
│   ├── vm2-start.sh            # VM 2: Backend API
│   └── vm3-start.sh            # VM 3: Frontend Angular
├── docker-compose.yml          # Dev local com Docker (opcional)
├── docker-compose.db.yml       # VM 1 com Docker (opcional)
├── docker-compose.api.yml      # VM 2 com Docker (opcional)
├── docker-compose.web.yml      # VM 3 com Docker (opcional)
└── .env.example                # Template de variáveis (Docker)
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
