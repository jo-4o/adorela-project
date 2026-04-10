# Adorela

Sistema de gestão de produtos e categorias.

## Stack

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

## Requisitos

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
```

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

## Testes

```bash
./mvnw test
cd adorela-web && npm test
```

## Licença

MIT
