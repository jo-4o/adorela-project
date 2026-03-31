# Adorela

Sistema de gestão de produtos e categorias.

## Stack

* Backend: Spring Boot, PostgreSQL, Keycloak
* Frontend: Angular

## Requisitos

* Docker
* Java 17+
* Node.js 20+
* Maven

## Execução com Docker

```bash
git clone <repo-url>
cd adorela-project
cp .env.example .env
docker compose up -d
```

Serviços:

* API: http://localhost:8080
* Swagger: http://localhost:8080/swagger-ui.html
* Keycloak: http://localhost:8180

## Desenvolvimento

### Backend

```bash
docker compose up -d keycloak postgres
./mvnw spring-boot:run
```

### Frontend

```bash
cd adorela-web
npm install
npm start
```

## Autenticação

* Realm: adorela
* Client: adorela-web
* Usuário: admin
* Senha: admin

## Estrutura

```
adorela-project/
├── src/
├── adorela-web/
├── keycloak/
├── docker-compose.yml
└── Dockerfile
```

## Testes

```bash
./mvnw test
cd adorela-web && npm test
```

## Licença

MIT
