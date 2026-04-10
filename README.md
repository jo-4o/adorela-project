# Adorela

Sistema de gestão de produtos e categorias.

## Stack

- **Backend:** Spring Boot 4, PostgreSQL, Keycloak
- **Frontend:** Angular 21, Tailwind CSS
- **Infraestrutura:** Docker, Nginx

## Arquitetura de Deploy (3 VMs)

```
┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│       VM 1          │     │       VM 2          │     │       VM 3          │
│  PostgreSQL :5432   │◄────│  Spring Boot :8080  │     │   Nginx :80         │
│  Keycloak   :8080   │     │  (adorela-api)      │     │  (adorela-web)      │
│                     │     │                     │     │                     │
│  docker-compose     │     │  docker-compose     │     │  docker-compose     │
│  .db.yml            │     │  .api.yml           │     │  .web.yml           │
└─────────────────────┘     └─────────────────────┘     └─────────────────────┘
         ▲                           ▲                           │
         │                           │        proxy /api/        │
         │                           └───────────────────────────┘
         │                                       ▲
         └───────────────────────────────────────┘
                    JWT issuer-uri
```

## Requisitos

- Docker e Docker Compose (nas VMs)
- Java 17+ e Maven (desenvolvimento local)
- Node.js 22+ e npm (desenvolvimento local)

---

## Deploy em Produção (3 VMs)

### 1. Preparar o `.env`

```bash
cp .env.example .env
```

Edite o `.env` com os IPs reais das suas VMs:

```env
# IPs das VMs
VM1_HOST=192.168.1.10      # PostgreSQL + Keycloak
API_HOST=192.168.1.11      # Backend API
WEB_HOST=192.168.1.12      # Frontend Nginx

# Senhas (TROQUE!)
POSTGRES_PASSWORD=sua_senha_segura
KEYCLOAK_ADMIN_PASSWORD=sua_senha_segura

# Backend -> Banco
SPRING_DATASOURCE_URL=jdbc:postgresql://192.168.1.10:5432/adorela
SPRING_DATASOURCE_PASSWORD=sua_senha_segura

# Backend -> Keycloak (URL pública)
SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI=http://192.168.1.10:8080/realms/adorela

# Backend -> CORS (URL do frontend)
ADORELA_CORS_ALLOWED_ORIGINS=http://192.168.1.12

# Frontend -> Keycloak (URL pública)
KEYCLOAK_URL=http://192.168.1.10:8080
```

### 2. VM 1 — PostgreSQL + Keycloak

```bash
# Copie o projeto para a VM e entre no diretório
docker compose -f docker-compose.db.yml --env-file .env up -d
```

> Após o primeiro deploy, acesse o Keycloak Admin (`http://<VM1_HOST>:8080`)
> e ajuste no client `adorela-web`:
> - **Valid Redirect URIs:** `http://<WEB_HOST>/*`
> - **Web Origins:** `http://<WEB_HOST>`

### 3. VM 2 — Backend API

```bash
docker compose -f docker-compose.api.yml --env-file .env up -d --build
```

### 4. VM 3 — Frontend Web

```bash
docker compose -f docker-compose.web.yml --env-file .env up -d --build
```

### Verificação

| Serviço    | URL                              |
| ---------- | -------------------------------- |
| Frontend   | `http://<WEB_HOST>`              |
| API        | `http://<API_HOST>:8080/api/products` |
| Swagger    | `http://<API_HOST>:8080/swagger-ui.html` |
| Keycloak   | `http://<VM1_HOST>:8080`         |

---

## Desenvolvimento Local

### Tudo junto (Docker)

```bash
cp .env.example .env
# Ajuste as senhas no .env
docker compose up -d --build
```

Acesse:
- Frontend: http://localhost
- API: http://localhost:8080
- Keycloak: http://localhost:8181

### Sem Docker (dev)

#### Backend

```bash
docker compose up -d postgres keycloak   # só banco + auth
./mvnw spring-boot:run
```

#### Frontend

```bash
cd adorela-web
npm install
npm start
```

Frontend em http://localhost:4200

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
│   ├── Dockerfile              # Build Angular + Nginx
│   ├── nginx.conf.template     # Config Nginx com proxy reverso
│   └── docker-entrypoint.sh    # Injeta env vars em runtime
├── keycloak/
│   └── realm-adorela.json      # Config do realm
├── Dockerfile                  # Build do backend
├── docker-compose.yml          # Dev local (tudo junto)
├── docker-compose.db.yml       # VM 1: PostgreSQL + Keycloak
├── docker-compose.api.yml      # VM 2: Backend API
├── docker-compose.web.yml      # VM 3: Frontend Nginx
└── .env.example                # Template de variáveis
```

## Testes

```bash
./mvnw test
cd adorela-web && npm test
```

## Licença

MIT
