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
*Nota: A documentação adicional sobre os passos detalhados das VMs, geração dos certificados TLS e importação do Keycloak será incluída neste documento posteriormente nas tarefas de Infraestrutura.*
