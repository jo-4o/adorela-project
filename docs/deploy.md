# Deploy e Configuração da Infraestrutura

## Configuração de DNS Local (`/etc/hosts`)

Para garantir que o redirecionamento, a autenticação OIDC (Keycloak) e os certificados TLS (HTTPS) funcionem corretamente utilizando os domínios configurados no Nginx, é **obrigatório** adicionar as seguintes entradas no arquivo de hosts da máquina de onde você irá acessar a aplicação.

### No Linux / macOS
Edite o arquivo `/etc/hosts` com permissões de superusuário:
```bash
sudo nano /etc/hosts
```
Adicione as seguintes linhas ao final do arquivo:
```text
# Adorela - Domínios Locais / Teste
127.0.0.1       sistema1.net sistema2.net e-instancia.net

# OBS: Caso esteja acessando as VMs remotamente, substitua "127.0.0.1" 
# pelo IP público ou local da VM 3 (onde está rodando o Frontend/Nginx).
```

### No Windows
1. Abra o **Bloco de Notas** como Administrador.
2. Navegue até `C:\Windows\System32\drivers\etc\` e abra o arquivo `hosts` (selecione "Todos os Arquivos" no canto inferior direito para visualizar).
3. Adicione as seguintes linhas ao final do arquivo:
```text
# Adorela - Dominios Locais / Teste
127.0.0.1       sistema1.net sistema2.net e-instancia.net
```
4. Salve o arquivo.

---
---

## Deploy nas 3 VMs

O deploy segue uma divisão lógica em três máquinas virtuais. 

### Preparação Comum
1. Clone o repositório em todas as VMs.
2. Certifique-se de configurar os IPs corretos em cada arquivo `.env` gerado a partir dos templates `.env.vmX`.

### VM 1: Banco de Dados e IAM (PostgreSQL + Keycloak)
1. Antes de iniciar, execute o script de geração de certificados TLS para o Postgres:
   ```bash
   ./scripts/generate-pg-certs.sh
   ```
2. Inicie os containers usando o docker-compose correspondente:
   ```bash
   docker compose -f docker-compose.db.yml --env-file .env.vm1 up -d
   ```
3. Acesse o Keycloak em `http://<VM1_IP>:8080`, acesse a aba Clients e configure o `adorela-web` para aceitar `Valid Redirect URIs` do IP do Frontend (VM3).

### VM 2: Backend API
1. Atualize o arquivo `.env.vm2` garantindo que o IP do Keycloak (VM1) está preenchido corretamente para validação de JWT, e que os CORS apontem para o Frontend.
2. Inicie a API:
   ```bash
   docker compose -f docker-compose.api.yml --env-file .env.vm2 up -d --build
   ```

### VM 3: Frontend Web
1. Atualize o arquivo `.env.vm3` apontando para o IP da API (VM2) e do Keycloak (VM1).
2. Inicie o Frontend, que ficará disponível em HTTPS (TLS) na porta 443:
   ```bash
   docker compose -f docker-compose.web.yml --env-file .env.vm3 up -d --build
   ```

## Verificação TLS e Testes (Task #21)
Para validar os certificados configurados (tanto na API, Frontend e DB), utilize os comandos abaixo:
- **API/Frontend TLS:** `openssl s_client -connect sistema1.net:443 -showcerts < /dev/null`
- **PostgreSQL TLS:** `openssl s_client -starttls postgres -connect <VM1_IP>:5432 -showcerts < /dev/null`
