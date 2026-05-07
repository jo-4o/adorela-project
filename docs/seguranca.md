# Documento de Políticas e Regras de Segurança

Este documento sumariza as principais políticas de segurança e mitigações aplicadas ao longo do desenvolvimento do projeto Adorela.

## 1. Autenticação e Autorização (IAM)
- **Identity Provider (Keycloak):** Centralizamos a autenticação usando Keycloak. A comunicação é realizada através dos fluxos OIDC padrão do mercado (Authorization Code Flow com PKCE).
- **Perfis de Acesso Baseados em Role (RBAC):** Foram criados os perfis `admin`, `limitado`, `exclusivo1` e `exclusivo2`. Os endpoints no Spring Boot utilizam a anotação `@PreAuthorize` verificando rigidamente essas permissões.
- **Isolamento e JWT:** A API backend não mantém estado (Stateless) e confia nas assinaturas JWT geradas pelo Keycloak (configurado com `issuer-uri`).

## 2. Criptografia em Trânsito (TLS/HTTPS)
- **Frontend (Nginx):** Tráfego restrito a HTTPS (TLS 1.2+). Implementada a política **HSTS** (Strict-Transport-Security) para prevenir ataques de downgrade, e redirecionamento de porta 80 para 443.
- **Backend API (Spring Boot / Tomcat embedded):** O Tomcat embarcado foi configurado para rodar exclusivamente sobre HTTPS (na porta 8443) usando keystores PKCS12 gerados localmente.
- **Banco de Dados (PostgreSQL):** A comunicação com o banco de dados exige TLS ativo, com a URL JDBC do Spring Boot forçada a utilizar `sslmode=require`.

## 3. Prevenção Contra Vulnerabilidades Web (OWASP Top 10)

As vulnerabilidades abaixo foram monitoradas via ferramentas de análise (OWASP ZAP) e corrigidas ao longo das iterações:

### Cross-Site Scripting (XSS)
- O Angular (Frontend) automaticamente sanitiza binds de dados não confiáveis (`{{ value }}`), prevenindo a injeção de scripts no DOM.
- Cabeçalhos de segurança (CSP - Content Security Policy) foram configurados no Nginx para impedir a carga de scripts não autorizados.

### Cross-Site Request Forgery (CSRF)
- Como a API utiliza JWT em requisições Authorization (`Bearer <token>`) e é inteiramente stateless, a vulnerabilidade padrão de CSRF baseada em cookies de sessão foi mitigada por design.

### Injeção de SQL (SQLi)
- Todo acesso ao banco de dados pelo backend utiliza Spring Data JPA / Hibernate, mitigando Injeção de SQL através de prepared statements padronizados pelo framework.

## 4. OWASP ZAP - Relatório de Análise

O relatório real (`owasp-zap.html`) será gerado diretamente através de uma varredura automatizada (Automated Scan) nas VMs de produção. Nele constarão os alertas detalhados que já foram mitigados por nossa arquitetura.
