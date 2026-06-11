# MAXIMOS Hub — Manual de Instalação

Sistema interno para centralizar as planilhas da MAXIMOS por departamento.
Roda no navegador (sem instalar nada no computador). Os dados ficam no **Supabase** (PostgreSQL na nuvem, com backup automático).

> Tempo estimado: ~15 minutos, só na primeira vez.

---

## Passo 1 — Criar o projeto no Supabase

1. Acesse **https://supabase.com** e crie uma conta grátis (pode entrar com o Google).
2. Clique em **New project**.
   - **Name:** `maximos-hub`
   - **Database Password:** crie uma senha forte e **guarde** (não precisa decorar).
   - **Region:** escolha *South America (São Paulo)*.
3. Aguarde ~2 minutos enquanto o banco é criado.

## Passo 2 — Criar as tabelas (rodar o banco.sql)

1. No menu lateral do Supabase, abra **SQL Editor**.
2. Clique em **New query**.
3. Abra o arquivo **`banco.sql`** (que veio nesta pasta), copie **todo** o conteúdo e cole ali.
4. Clique em **Run** (canto inferior direito). Deve aparecer *Success*.

## Passo 3 — Criar o primeiro usuário (admin)

1. No menu lateral, abra **Authentication > Users > Add user > Create new user**.
2. Informe um **e-mail** e uma **senha** (ex.: `voce@maximos.com`). Marque *Auto Confirm User*.
3. Volte ao **SQL Editor**, cole o comando abaixo trocando pelo e-mail que você criou e clique em **Run**:

   ```sql
   update public.perfis set papel = 'admin'
   where id = (select id from auth.users where email = 'voce@maximos.com');
   ```

   Pronto: esse usuário agora é **administrador**.

## Passo 4 — Conectar o sistema ao seu banco

1. No Supabase, abra **Project Settings (engrenagem) > API**.
2. Copie dois valores:
   - **Project URL** (algo como `https://xxxx.supabase.co`)
   - **anon public** key (uma chave longa)
3. Abra o arquivo **`index.html`** no Bloco de Notas e, lá no comecinho do `<script>`, preencha:

   ```js
   const SUPA_URL = 'COLE_AQUI_A_PROJECT_URL';
   const SUPA_KEY = 'COLE_AQUI_A_ANON_KEY';
   ```

4. Salve o arquivo.

> A chave **anon** pode ficar no arquivo — ela é pública por natureza; quem protege os dados é o login + as regras (RLS) que o `banco.sql` criou.

## Passo 5 — Abrir o sistema

- **Modo simples:** dê dois cliques em `index.html` para abrir no navegador.
- **Modo recomendado (todos acessam pela rede):** publique a pasta no **GitHub Pages** (mesmo esquema dos seus outros projetos) e compartilhe o link com a equipe.

Faça login com o e-mail e senha do Passo 3.

---

## Como usar (resumo)

1. **Entrar** → tela de login.
2. Escolher um **departamento** no menu lateral (Fiscal, Contábil, DP, Financeiro, Comercial, TI).
3. **Nova planilha** → dê um nome.
4. **Colunas** → adicione colunas e escolha o tipo (Texto, Número, R$, Data, Sim/Não, Seleção, **Fórmula**).
   - Coluna de **Fórmula**: escreva usando o nome das outras colunas entre colchetes.
     Exemplos: `[Base] * [Aliquota] / 100`  ·  `SE([Valor] > 1000; [Valor]*0,9; [Valor])`  ·  `ARRED([Total]; 2)`
5. **+ Linha** para adicionar registros. Clique numa célula para editar.
6. **Buscar** e **ordenar** (clique no título da coluna) ajudam a achar registros.
7. **Exportar** em Excel ou PDF quando precisar.

## Novos usuários

- Crie em **Authentication > Users > Add user** (eles entram como usuário comum, com acesso total às planilhas).
- Para tornar alguém admin, repita o comando do Passo 3 com o e-mail da pessoa.

## Dúvidas comuns

- **"Não carrega / fica em branco"** → confira se a `SUPA_URL` e a `SUPA_KEY` foram coladas certas (Passo 4).
- **"E-mail ou senha inválidos"** → o usuário precisa existir em *Authentication > Users*.
- **Backup** → o Supabase faz backup automático. Você também pode exportar qualquer planilha em Excel a qualquer momento.

---

*MAXIMOS Soluções Empresariais — sistema interno.*
