# Adorela - Sistema de Gestão de Padaria

Sistema completo para gestão de produtos e categorias de padaria, com:
- **Backend**: Spring Boot 4 + PostgreSQL + Keycloak (OAuth2)
- **Frontend**: Angular 21 + Tailwind CSS

---

## 📋 Pré-requisitos

- Docker & Docker Compose
- Java 17+ (para desenvolvimento local)
- Node.js 20+ (para desenvolvimento do frontend)
- Maven 3.9+

---

## 🚀 Executando com Docker (recomendado)

1. **Clone o repositório e entre na pasta:**
   ```bash
   git clone <repo-url>
   cd adorela-project
   ```

2. **Copie as variáveis de ambiente:**
   ```bash
   cp .env.example .env
   ```

3. **Suba os containers:**
   ```bash
   docker compose up -d
   ```

4. **Acesse os serviços:**
   - **API**: http://localhost:8080
   - **Swagger UI**: http://localhost:8080/swagger-ui.html
   - **Keycloak**: http://localhost:8180 (admin/admin)

---

## 🛠️ Desenvolvimento Local

### Backend (Spring Boot)

```bash
# Certifique-se de ter PostgreSQL rodando na porta 5432
# Suba apenas o Keycloak se necessário:
docker compose up -d keycloak postgres

# Rode a aplicação:
./mvnw spring-boot:run
```

### Frontend (Angular)

```bash
cd adorela-web
npm install
npm start
```

Acesse: http://localhost:4200

---

## 🔐 Autenticação

O Keycloak é configurado automaticamente com:

| Campo    | Valor         |
|----------|---------------|
| Realm    | `adorela`     |
| Client   | `adorela-web` |
| Usuário  | `admin`       |
| Senha    | `admin`       |
| Role     | `admin`       |

Para logar no painel administrativo do frontend, acesse `/login` e autentique-se via Keycloak.

---

## 📁 Estrutura do Projeto

```
adorela-project/
├── src/                      # Código-fonte do backend (Spring Boot)
│   └── main/
│       ├── java/com/adorela/api/
│       │   ├── config/       # SecurityConfig
│       │   ├── controllers/  # REST controllers
│       │   ├── exceptions/   # GlobalExceptionHandler
│       │   ├── models/       # Entidades JPA
│       │   └── repositories/ # Spring Data JPA
│       └── resources/
│           ├── application.properties
│           └── data.sql      # Seed de dados
├── adorela-web/              # Frontend Angular
│   └── src/app/
│       ├── components/
│       ├── pages/
│       ├── services/
│       └── models/
├── keycloak/                 # Configuração do realm Keycloak
├── docker-compose.yml        # Ambiente completo
├── Dockerfile                # Build do backend
└── .github/workflows/ci.yml  # Pipeline CI
```

---

## 📡 Endpoints da API

| Método | Endpoint                       | Descrição                    | Auth     |
|--------|--------------------------------|------------------------------|----------|
| GET    | `/api/products`                | Lista produtos ativos        | Público  |
| GET    | `/api/products/search`         | Busca paginada               | Público  |
| GET    | `/api/products/featured`       | Produtos em destaque         | Público  |
| GET    | `/api/products/{id}`           | Detalhes do produto          | Público  |
| GET    | `/api/products/category/{id}`  | Produtos por categoria       | Público  |
| POST   | `/api/products`                | Criar produto                | Admin    |
| PUT    | `/api/products/{id}`           | Atualizar produto            | Admin    |
| DELETE | `/api/products/{id}`           | Remover produto              | Admin    |
| GET    | `/api/categories`              | Lista categorias             | Público  |
| POST   | `/api/categories`              | Criar categoria              | Admin    |
| PUT    | `/api/categories/{id}`         | Atualizar categoria          | Admin    |
| DELETE | `/api/categories/{id}`         | Remover categoria            | Admin    |
| POST   | `/api/uploads`                 | Upload de imagem             | Admin    |
| GET    | `/api/uploads/{filename}`      | Servir imagem                | Público  |

---

## 🧪 Testes

### Backend
```bash
./mvnw test
```

### Frontend
```bash
cd adorela-web
npm test
```

---

## 📄 Licença

MIT
# adorela-project
# adorela-project
# adorela-project
