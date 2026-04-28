# Roteiro de Testes — Fluxo OIDC com 4 Perfis

> **Projeto:** Adorela  
> **Realm Keycloak:** `adorela`  
> **Client:** `adorela-web`  
> **Data:** 2026-04-28  

---

## Pré-requisitos

| Item | Detalhe |
|------|---------|
| Keycloak rodando | `http://localhost:8181` |
| Frontend Angular | `http://localhost:4200` **ou** `https://sistema1.net` |
| Backend API | `http://localhost:8080` |
| Realm importado | `keycloak/realm-adorela.json` importado via `--import-realm` |

### Iniciar o ambiente

```bash
# 1. Subir todos os serviços
docker compose up -d

# 2. Aguardar Keycloak estar saudável e criar os usuários
bash keycloak/init-users.sh
```

> **Nota:** Se preferir usar o realm JSON diretamente (sem o script), os 4 usuários
> já estão declarados no `realm-adorela.json` com credenciais fixas para testes.

---

## Credenciais dos Usuários de Teste

| Usuário | Senha | Roles |
|---------|-------|-------|
| `admin` | `Admin@1234` | `dono`, `gerente`, `revisao`, `limitado`, `exclusivo1`, `exclusivo2` |
| `user_limitado` | `Limitado@1234` | `limitado` |
| `user_ex1` | `Exclusivo1@1234` | `exclusivo1` |
| `user_ex2` | `Exclusivo2@1234` | `exclusivo2` |

---

## TC-01 — Usuário `admin` (perfil dono — acesso total)

**Objetivo:** Verificar que o usuário `admin` possui todas as roles e consegue acessar todos os recursos.

### Passos

1. Acesse `http://localhost:4200` (ou `https://sistema1.net`).
2. Clique em **"Entrar"** — o sistema deve redirecionar para o Keycloak.
3. Faça login com `admin` / `Admin@1234`.
4. Após redirecionamento de volta ao Angular, abra o console do navegador e execute:

   ```js
   authService.getRoles()
   // Esperado: ["dono", "gerente", "revisao", "limitado", "exclusivo1", "exclusivo2", ...]
   ```

5. Verifique que os helpers retornam `true`:

   ```js
   authService.isDono()      // true
   authService.isGerente()   // true
   authService.isRevisao()   // true
   authService.isLimitado()  // true
   authService.isExclusivo1() // true
   authService.isExclusivo2() // true
   ```

6. Realize uma operação de **criação de produto** (POST `/api/products`).
7. Realize uma operação de **exclusão de produto** (DELETE `/api/products/{id}`).

### Resultado Esperado

- ✅ Login bem-sucedido sem erro de redirect.
- ✅ Token JWT retornado com `claim.roles` contendo todas as 6 roles.
- ✅ Criação e exclusão de produto com status `200 / 204`.
- ✅ `authService.getUserInfo()` retorna `username: "admin"`.

---

## TC-02 — Usuário `user_limitado` (perfil limitado)

**Objetivo:** Verificar que o usuário `user_limitado` só consegue visualizar produtos públicos.

### Passos

1. Acesse a aplicação (logout se necessário).
2. Faça login com `user_limitado` / `Limitado@1234`.
3. No console do navegador:

   ```js
   authService.getRoles()
   // Esperado: ["limitado"]

   authService.isLimitado()   // true
   authService.isDono()       // false
   authService.isGerente()    // false
   authService.isExclusivo1() // false
   authService.isExclusivo2() // false
   ```

4. Tente acessar a listagem de produtos públicos (GET `/api/products`).
5. Tente acessar uma rota administrativa protegida (ex.: `/admin/products`).

### Resultado Esperado

- ✅ Login bem-sucedido.
- ✅ GET `/api/products` retorna `200` com lista de produtos.
- ✅ Acesso a rotas administrativas bloqueado (redirect para `/unauthorized` ou `403`).
- ✅ Botões de criação/edição/exclusão **não aparecem** na UI.

---

## TC-03 — Usuário `user_ex1` (perfil exclusivo1)

**Objetivo:** Verificar que `user_ex1` acessa apenas recursos do grupo exclusivo 1.

### Passos

1. Logout do usuário anterior.
2. Faça login com `user_ex1` / `Exclusivo1@1234`.
3. No console:

   ```js
   authService.getRoles()
   // Esperado: ["exclusivo1"]

   authService.isExclusivo1()  // true
   authService.isExclusivo2()  // false
   authService.isLimitado()    // false
   authService.isDono()        // false
   ```

4. Acesse a área exclusiva do grupo 1 (ex.: `/exclusive/group1`).
5. Tente acessar a área exclusiva do grupo 2 (ex.: `/exclusive/group2`).

### Resultado Esperado

- ✅ Login bem-sucedido.
- ✅ Área do grupo 1 acessível.
- ✅ Área do grupo 2 bloqueada (`403` ou redirect).
- ✅ Token JWT contém `roles: ["exclusivo1"]` na claim `roles`.

---

## TC-04 — Usuário `user_ex2` (perfil exclusivo2)

**Objetivo:** Verificar que `user_ex2` acessa apenas recursos do grupo exclusivo 2.

### Passos

1. Logout do usuário anterior.
2. Faça login com `user_ex2` / `Exclusivo2@1234`.
3. No console:

   ```js
   authService.getRoles()
   // Esperado: ["exclusivo2"]

   authService.isExclusivo2()  // true
   authService.isExclusivo1()  // false
   authService.isLimitado()    // false
   ```

4. Acesse a área exclusiva do grupo 2 (ex.: `/exclusive/group2`).
5. Tente acessar a área exclusiva do grupo 1 (ex.: `/exclusive/group1`).

### Resultado Esperado

- ✅ Login bem-sucedido.
- ✅ Área do grupo 2 acessível.
- ✅ Área do grupo 1 bloqueada.
- ✅ Token JWT contém `roles: ["exclusivo2"]`.

---

## TC-05 — Validação dos redirectUris (sistema1.net)

**Objetivo:** Confirmar que o fluxo OIDC funciona tanto em `localhost:4200` quanto em `https://sistema1.net`.

### Passos

1. Configure `/etc/hosts` (ou DNS) para apontar `sistema1.net` para o IP da VM do frontend.
2. Acesse `https://sistema1.net`.
3. Tente login com qualquer um dos 4 usuários.
4. Após autenticação, o Keycloak deve redirecionar de volta para `https://sistema1.net/*`.

### Resultado Esperado

- ✅ Keycloak **não** retorna erro `"Invalid redirect URI"`.
- ✅ Após login, URL final é `https://sistema1.net/` (ou rota de destino).
- ✅ Token JWT válido recebido e sessão Angular estabelecida.

---

## TC-06 — Decodificação do JWT (validação do claim `roles`)

**Objetivo:** Confirmar que o `protocolMapper` está inserindo as roles no token corretamente.

### Passos

1. Faça login com qualquer usuário.
2. No console do navegador, obtenha o token:

   ```js
   const token = authService.getToken();
   console.log(token);
   ```

3. Cole o token em [https://jwt.io](https://jwt.io) e verifique o payload.

### Resultado Esperado (exemplo para `user_limitado`)

```json
{
  "exp": 1234567890,
  "iss": "http://localhost:8181/realms/adorela",
  "azp": "adorela-web",
  "roles": ["limitado"],
  "preferred_username": "user_limitado"
}
```

- ✅ Campo `roles` presente como array (não `realm_access.roles`).
- ✅ Roles corretas por usuário conforme tabela de credenciais.
- ✅ `iss` aponta para o realm `adorela`.

---

## Tabela de Resultados

Preencha após executar os testes:

| Caso | Usuário | Status | Observação |
|------|---------|--------|------------|
| TC-01 | `admin` | ⬜ | |
| TC-02 | `user_limitado` | ⬜ | |
| TC-03 | `user_ex1` | ⬜ | |
| TC-04 | `user_ex2` | ⬜ | |
| TC-05 | Qualquer (sistema1.net) | ⬜ | |
| TC-06 | JWT decode | ⬜ | |

**Legenda:** ✅ Passou · ❌ Falhou · ⚠️ Parcial · ⬜ Não executado
