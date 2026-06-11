-- =====================================================================
--  MAXIMOS HUB — Banco de dados (Supabase / PostgreSQL)
--  Rode este script inteiro no Supabase: SQL Editor > New query > Run
--
--  SEGURO para rodar num projeto JÁ EXISTENTE: usa nomes próprios
--  (prefixo maximoshub_) para funções/gatilho e só cria tabelas novas,
--  sem mexer no que outros apps já tenham. Pode rodar mais de uma vez.
-- =====================================================================

-- ---------- TABELAS ----------

-- Perfil do usuário (ligado ao login do Supabase Auth)
create table if not exists public.perfis (
  id          uuid primary key references auth.users on delete cascade,
  nome        text,
  papel       text not null default 'usuario' check (papel in ('admin','usuario')),
  ativo       boolean not null default true,
  criado_em   timestamptz not null default now()
);

-- Departamentos (Fiscal, Contábil, DP, ...)
create table if not exists public.departamentos (
  id          uuid primary key default gen_random_uuid(),
  nome        text not null,
  descricao   text,
  cor         text default '#1e40af',
  icone       text default '📁',
  ordem       int  default 0,
  criado_em   timestamptz not null default now()
);
-- nome único = seeding repetível (não duplica ao rodar de novo)
create unique index if not exists idx_departamentos_nome on public.departamentos(nome);

-- Planilhas (cada uma pertence a um departamento)
create table if not exists public.planilhas (
  id              uuid primary key default gen_random_uuid(),
  departamento_id uuid references public.departamentos on delete cascade,
  nome            text not null,
  descricao       text,
  criado_por      uuid references auth.users,
  criado_em       timestamptz not null default now(),
  atualizado_em   timestamptz not null default now()
);

-- Colunas = estrutura da planilha (o que torna "planilha sem programação")
create table if not exists public.colunas (
  id           uuid primary key default gen_random_uuid(),
  planilha_id  uuid references public.planilhas on delete cascade,
  nome         text not null,
  tipo         text not null default 'texto'
               check (tipo in ('texto','numero','moeda','data','booleano','selecao','formula')),
  formula      text,            -- usado quando tipo = 'formula', ex: [base] * [aliquota] / 100
  opcoes       jsonb,           -- lista de opções quando tipo = 'selecao'
  ordem        int default 0,
  largura      int,
  criado_em    timestamptz not null default now()
);

-- Linhas = registros. Dados ficam em JSONB { coluna_id: valor }
create table if not exists public.linhas (
  id            uuid primary key default gen_random_uuid(),
  planilha_id   uuid references public.planilhas on delete cascade,
  dados         jsonb not null default '{}'::jsonb,
  ordem         int default 0,
  criado_por    uuid references auth.users,
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

-- Logs de auditoria (quem fez o quê e quando)
create table if not exists public.logs (
  id           bigint generated always as identity primary key,
  usuario_id   uuid references auth.users,
  usuario_nome text,
  acao         text,            -- criou | editou | excluiu
  entidade     text,            -- planilha | coluna | linha | departamento | usuario
  entidade_id  uuid,
  planilha_id  uuid,
  detalhe      jsonb,
  criado_em    timestamptz not null default now()
);

-- Índices para escala (milhares de registros)
create index if not exists idx_planilhas_depto on public.planilhas(departamento_id);
create index if not exists idx_colunas_planilha on public.colunas(planilha_id);
create index if not exists idx_linhas_planilha on public.linhas(planilha_id);
create index if not exists idx_logs_data on public.logs(criado_em desc);

-- ---------- FUNÇÃO AUXILIAR: é admin? ----------
-- security definer = ignora RLS (evita recursão ao checar a própria tabela perfis)
create or replace function public.maximoshub_is_admin()
returns boolean language sql security definer stable as $$
  select exists(select 1 from public.perfis where id = auth.uid() and papel = 'admin');
$$;

-- ---------- GATILHO: cria perfil automático ao registrar usuário ----------
-- Nome próprio (maximoshub_) para coexistir com gatilhos de outros apps no mesmo projeto.
create or replace function public.maximoshub_handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.perfis (id, nome, papel)
  values (new.id,
          coalesce(new.raw_user_meta_data->>'nome', split_part(new.email,'@',1)),
          'usuario')
  on conflict (id) do nothing;
  return new;
end; $$;

drop trigger if exists on_auth_user_created_maximoshub on auth.users;
create trigger on_auth_user_created_maximoshub
  after insert on auth.users
  for each row execute function public.maximoshub_handle_new_user();

-- ---------- SEGURANÇA (RLS) ----------
alter table public.perfis        enable row level security;
alter table public.departamentos enable row level security;
alter table public.planilhas     enable row level security;
alter table public.colunas       enable row level security;
alter table public.linhas        enable row level security;
alter table public.logs          enable row level security;

-- perfis: todo logado lê (para mostrar nomes); só admin altera (cada um pode editar o próprio nome)
drop policy if exists perfis_select on public.perfis;
create policy perfis_select on public.perfis for select to authenticated using (true);
drop policy if exists perfis_update on public.perfis;
create policy perfis_update on public.perfis for update to authenticated
  using (public.maximoshub_is_admin() or id = auth.uid()) with check (public.maximoshub_is_admin() or id = auth.uid());
drop policy if exists perfis_insert on public.perfis;
create policy perfis_insert on public.perfis for insert to authenticated
  with check (public.maximoshub_is_admin() or id = auth.uid());
drop policy if exists perfis_delete on public.perfis;
create policy perfis_delete on public.perfis for delete to authenticated using (public.maximoshub_is_admin());

-- departamentos / planilhas / colunas / linhas: TUDO LIBERADO para quem está logado
do $$
declare t text;
begin
  foreach t in array array['departamentos','planilhas','colunas','linhas'] loop
    execute format('drop policy if exists %I_all on public.%I', t, t);
    execute format('create policy %I_all on public.%I for all to authenticated using (true) with check (true)', t, t);
  end loop;
end $$;

-- logs: qualquer logado grava; só admin lê
drop policy if exists logs_insert on public.logs;
create policy logs_insert on public.logs for insert to authenticated with check (true);
drop policy if exists logs_select on public.logs;
create policy logs_select on public.logs for select to authenticated using (public.maximoshub_is_admin());

-- ---------- DEPARTAMENTOS INICIAIS ----------
insert into public.departamentos (nome, descricao, cor, icone, ordem) values
  ('Fiscal',               'Apuração de impostos e obrigações fiscais', '#2563eb', '🧾', 1),
  ('Contábil',             'Escrituração e demonstrações contábeis',    '#0891b2', '📊', 2),
  ('Departamento Pessoal', 'Folha, admissões e rotinas trabalhistas',   '#7c3aed', '👥', 3),
  ('Financeiro',           'Contas a pagar, a receber e fluxo de caixa','#16a34a', '💰', 4),
  ('Comercial',            'Clientes, propostas e vendas',              '#ea580c', '🤝', 5),
  ('TI',                   'Sistemas, acessos e infraestrutura',        '#475569', '💻', 6)
on conflict (nome) do nothing;

-- =====================================================================
--  DEPOIS DE RODAR: crie seu 1º usuário em Authentication > Users > Add user
--  e promova-o a admin trocando o e-mail abaixo:
--
--    update public.perfis set papel = 'admin'
--    where id = (select id from auth.users where email = 'voce@maximos.com');
-- =====================================================================
