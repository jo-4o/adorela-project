# Deploy e Configuração da Infraestrutura

Este documento concentra as instruções de deploy e infraestrutura do projeto Adorela.

## Visão geral

- **VM 1:** PostgreSQL + Keycloak
- **VM 2:** API Spring Boot
- **VM 3:** Frontend Angular servido pelo Nginx

Para complementar este guia:

- [Arquitetura](arquitetura.md)
- [Segurança](seguranca.md)
- [Roteiro de testes](testes.md)

## Configuração de hosts / DNS local

Para que autenticação OIDC, redirecionamentos e certificados TLS funcionem corretamente com os domínios configurados no Nginx, adicione uma entrada para `sistema1.net`, `sistema2.net` e `e-instancia.net` na máquina cliente.

### Linux / macOS

```bash
sudo nano /etc/hosts
```

Adicione ao final do arquivo:

```text
# Adorela - Domínios Locais / Teste
127.0.0.1       sistema1.net sistema2.net e-instancia.net
```

> Se estiver acessando as VMs remotamente, substitua `127.0.0.1` pelo IP da VM 3 (Frontend/Nginx).

### Windows

1. Abra o **Bloco de Notas** como Administrador.
2. Abra `C:\Windows\System32\drivers\etc\hosts`.
3. Adicione:

```text
# Adorela - Domínios Locais / Teste
127.0.0.1       sistema1.net sistema2.net e-instancia.net
```

## Deploy com Docker Compose por VM

Os arquivos `.env.vm1`, `.env.vm2` e `.env.vm3` servem como base para a configuração de cada máquina.

### VM 1 — Banco de dados e IAM

1. Gere os certificados do PostgreSQL:

   ```bash
   ./scripts/generate-pg-certs.sh
   ```

2. Suba PostgreSQL + Keycloak:

   ```bash
   docker compose -f docker-compose.db.yml --env-file .env.vm1 up -d
   ```

3. No Keycloak, ajuste o client `adorela-web` para aceitar o endereço do frontend em **Valid Redirect URIs** e **Web Origins**.

### VM 2 — Backend API

1. Revise o `.env.vm2` com o IP da VM 1 (issuer/JWT) e o host do frontend.
2. Suba a API:

   ```bash
   docker compose -f docker-compose.api.yml --env-file .env.vm2 up -d --build
   ```

### VM 3 — Frontend Web

1. Revise o `.env.vm3` com os IPs da API (VM 2) e do Keycloak (VM 1).
2. Suba o frontend:

   ```bash
   docker compose -f docker-compose.web.yml --env-file .env.vm3 up -d --build
   ```

## Execução manual com scripts

Caso prefira executar os serviços fora do Docker, use os scripts em `scripts/`.

### VM 1

Dependências recomendadas:

```bash
sudo apt update && sudo apt install -y postgresql openjdk-17-jre-headless
```

```bash
chmod +x scripts/vm1-start.sh
./scripts/vm1-start.sh
```

### VM 2

Dependências recomendadas:

```bash
sudo apt update && sudo apt install -y openjdk-17-jdk maven
```

```bash
chmod +x scripts/vm2-start.sh
export VM1_HOST=<IP_DA_VM1>
export WEB_HOST=<IP_DA_VM3>
./scripts/vm2-start.sh
```

### VM 3

Dependências recomendadas:

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
```

```bash
chmod +x scripts/vm3-start.sh
export VM1_HOST=<IP_DA_VM1>
export API_HOST=<IP_DA_VM2>
./scripts/vm3-start.sh
```

## Desenvolvimento local

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

## Endereços úteis

### Deploy em 3 VMs

- **Frontend:** `http://<VM3_IP>` ou `https://sistema1.net`
- **API:** `http://<VM2_IP>:8080/api/products`
- **Swagger:** `http://<VM2_IP>:8080/swagger-ui.html`
- **Keycloak:** `http://<VM1_IP>:8080`

### Desenvolvimento local

- **Frontend:** `http://localhost:4200`
- **API:** `http://localhost:8080`
- **Swagger:** `http://localhost:8080/swagger-ui.html`
- **Keycloak:** `http://localhost:8080`

## Verificação

- **Frontend/API com TLS:** `openssl s_client -connect sistema1.net:443 -showcerts < /dev/null`
- **PostgreSQL com TLS:** `openssl s_client -starttls postgres -connect <VM1_IP>:5432 -showcerts < /dev/null`
- **Headers HTTPS:** `curl -I -k https://sistema1.net`
- **Redirect HTTP → HTTPS:** `curl -I http://sistema1.net`
