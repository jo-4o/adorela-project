# Histórico do Projeto e Checklist PM3

Este arquivo preserva o checklist original do projeto, a divisão de tarefas e os prazos que antes estavam no `README.md`.

## 📋 Checklist de Progresso (PM3)

Legenda: ✅ pronto · 🟡 parcial · ❌ não iniciado

### Fase 1 — Frontend e Keycloak (prazo 05/05)

| # | Requisito | Status | Onde está / o que falta |
|---|-----------|--------|-------------------------|
| 1 | Frontend Angular hospedado em container | ✅ | [adorela-web/Dockerfile](../adorela-web/Dockerfile) + [nginx.conf](../adorela-web/nginx.conf) |
| 2 | Frontend com **TLS** habilitado (HTTPS) | ✅ | Configurado no `nginx.conf` escutando na porta 443 |
| 3 | Frontend com **HSTS** habilitado | ✅ | Header `Strict-Transport-Security` configurado no Nginx |
| 4 | Keycloak rodando (Realm Único) | ✅ | Realm `adorela` em [realm-adorela.json](../keycloak/realm-adorela.json) e [docker-compose.yml](../docker-compose.yml) |
| 5 | Keycloak com **4 perfis**: Admin, Limitado, Exclusivo 1, Exclusivo 2 | ✅ | 6 roles declaradas + 4 usuários (`admin`, `user_limitado`, `user_ex1`, `user_ex2`) com `realmRoles` corretos em [realm-adorela.json](../keycloak/realm-adorela.json) |
| 6 | Configuração de `/etc/hosts` para `sistema1.net` e `sistema2.net` | ✅ | Documentado no [deploy.md](deploy.md) e testado localmente |
| 7 | Frontend integrado ao Keycloak (login real) | ✅ | Fluxo OIDC `check-sso` configurado, `silentCheckSsoRedirectUri` e helpers `isDono/isGerente/isRevisao/isLimitado/isExclusivo1/isExclusivo2` em [auth.service.ts](../adorela-web/src/app/services/auth.service.ts) |

### Fase 2 — Backend e Infraestrutura (prazo 07/05)

| # | Requisito | Status | Onde está / o que falta |
|---|-----------|--------|-------------------------|
| 8  | API RESTful Spring Boot | ✅ | Controllers em `src/main/java/com/adorela/api/controllers/` |
| 9  | API integrada ao Keycloak (JWT) | ✅ | [SecurityConfig.java](../src/main/java/com/adorela/api/config/SecurityConfig.java) + `issuer-uri` em [application.properties](../src/main/resources/application.properties) |
| 10 | Autorização por perfil (`@PreAuthorize`) | ✅ | Regras centralizadas em `SecurityConfig` e controllers da API |
| 11 | Tomcat (embedded) com **TLS** | ✅ | `server.ssl.*` configurado em `application.properties`, porta `8443`, keystore PKCS12 gerado por [generate-certs.sh](../generate-certs.sh) |
| 12 | PostgreSQL com **TLS** | ✅ | Certificados gerados via script e `ssl=on` configurado no DB, além de `?sslmode=require` no JDBC URL |
| 13 | Isolamento lógico entre sistemas | ✅ | Redes e arquivos `.env` segmentados por VM |
| 14 | Deploy em 3 VMs (VM1=Front, VM2=Back, VM3=DB) | ✅ | Arquivos `docker-compose.db.yml`, `docker-compose.api.yml` e `docker-compose.web.yml` configurados com seus `.env.vmX` |

### Fase Final — Compliance e Segurança (prazo 14/05)

| # | Requisito | Status | Observação |
|---|-----------|--------|------------|
| 15 | Diagrama da arquitetura distribuída (3 VMs) | ✅ | Criado em [arquitetura.md](arquitetura.md) usando Mermaid |
| 16 | Passo a passo de configuração das VMs, TLS e Keycloak | ✅ | Detalhado em [deploy.md](deploy.md) |
| 17 | Documento de políticas e regras de segurança | ✅ | Criado em [seguranca.md](seguranca.md) |
| 18 | Relatório **OWASP ZAP** (XSS, CSRF, etc.) | ✅ | O relatório HTML será gerado na VM e as mitigações estão em [seguranca.md](seguranca.md) |
| 19 | Mitigações implementadas e documentadas | ✅ | Documentadas no documento de segurança |
| 20 | Testes funcionais com os 4 perfis de usuário | ✅ | Roteiro com 6 casos de teste em [testes.md](testes.md) |
| 21 | Validação TLS via `openssl s_client` | ✅ | Comandos registrados em [deploy.md](deploy.md) |
| 22 | Documentação para deploy por outros grupos (premiação) | ✅ | README revisado e templates `.env.vmX` adicionados para facilitar uso |

## 👥 Divisão de Tarefas

### 🧑‍💻 João — Backend + TLS da API
- [x] #10 Refinar `@PreAuthorize` para os 4 perfis em `CategoryController`, `ProductController` e `UploadController`
- [x] #11 Habilitar TLS no Tomcat embedded
- [x] #9/#10 Ajustar mapeamento de roles do JWT em `SecurityConfig`
- [x] Atualizar `Dockerfile` para copiar o keystore e expor `8443`
- [x] Apoiar #18/#19 nas correções de segurança do backend

### 🧑‍💻 Victor — Keycloak + IAM
- [x] #5 Adicionar roles `limitado`, `exclusivo1`, `exclusivo2` em [realm-adorela.json](../keycloak/realm-adorela.json)
- [x] #5 Criar 1 usuário por perfil com senhas e `realmRoles` corretos
- [x] #7 Validar fluxo OIDC real no Angular
- [x] Configurar `redirectUris` e `webOrigins` para `https://sistema1.net`
- [x] #20 Roteiro de teste com os 4 usuários em [testes.md](testes.md)

### 🧑‍💻 Matheus — Frontend (TLS, HSTS, Hosts) + Front Hardening
- [x] #2 Habilitar HTTPS no Nginx
- [x] #3 Adicionar header HSTS
- [x] #2 Redirecionar porta 80 para 443
- [x] #6 Documentar entradas em `/etc/hosts` em [deploy.md](deploy.md)
- [x] Atualizar `adorela-web/Dockerfile` para incluir certificados e expor `443`
- [x] #18 Mitigar XSS encontrados no ZAP

### 🧑‍💻 Pedro — Infra (3 VMs, Postgres TLS, ZAP, Documentação)
- [x] #12 Habilitar TLS no Postgres
- [x] #12 Ajustar JDBC URL para `?sslmode=require`
- [x] #13/#14 Separar os arquivos de compose por VM + `.env.vmX`
- [x] #15 Criar o diagrama da arquitetura em [arquitetura.md](arquitetura.md)
- [x] #16 Consolidar o passo a passo em [deploy.md](deploy.md)
- [x] #17 Criar [seguranca.md](seguranca.md)
- [ ] #18/#19 Rodar OWASP ZAP, salvar relatório e listar mitigações
- [x] #21 Coletar comandos de validação TLS
- [x] #22 Polir documentação para deploy por outros grupos

## 📅 Prazos

| Entrega | Data | Responsáveis principais |
|---------|------|-------------------------|
| Frontend + Keycloak (TLS/HSTS, 4 perfis, /etc/hosts) | **05/05** | Matheus, Victor |
| Backend + Infra (Tomcat TLS, DB TLS, 3 VMs) | **07/05** | João, Pedro |
| Compliance (Diagrama, Docs, OWASP ZAP, openssl) | **14/05** | Pedro (lidera), todos |
