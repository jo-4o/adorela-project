# Adorela

Sistema de gestão de produtos e categorias desenvolvido para a disciplina de Engenharia de Software.

## Stack

- **Backend:** Spring Boot 4 + Java 17
- **Frontend:** Angular 21 + Tailwind CSS + Nginx
- **Banco de dados:** PostgreSQL 16
- **Autenticação:** Keycloak 21
- **Infraestrutura:** Docker / Docker Compose com opção de deploy em 3 VMs

## Estrutura do repositório

```text
adorela-project/
├── src/                    # Backend Spring Boot
├── adorela-web/            # Frontend Angular + Nginx
├── docs/                   # Guias de deploy, arquitetura, segurança e testes
├── keycloak/               # Realm e utilitários do Keycloak
├── scripts/                # Scripts auxiliares para subir as VMs
├── docker-compose*.yml     # Variações de deploy com Docker Compose
├── .env.example            # Exemplo de variáveis para Docker Compose
├── .env.vm1/.env.vm2/.env.vm3
└── Dockerfile              # Imagem da API
```

## Documentação

- [Índice da documentação](docs/README.md)
- [Guia de deploy](docs/deploy.md)
- [Arquitetura](docs/arquitetura.md)
- [Segurança](docs/seguranca.md)
- [Roteiro de testes](docs/testes.md)
- [Histórico do projeto / checklist PM3](docs/project-status.md)

## Começando rápido

### Backend

```bash
./mvnw spring-boot:run
```

### Frontend

```bash
cd adorela-web
npm install
npm start
```

## Testes

```bash
./mvnw clean verify
cd adorela-web && npm ci && npm test -- --watch=false
```

> O build de produção do Angular pode depender de acesso externo para inlining de fontes do Google Fonts.

## Deploy

O guia principal de infraestrutura, hosts locais, TLS e execução por VM está em [docs/deploy.md](docs/deploy.md).

## Licença

MIT
