# MAXIMOS Hub — Documento de Design

**Data:** 2026-06-11
**Objetivo:** Sistema web interno para substituir e centralizar as planilhas Excel da MAXIMOS, organizado por departamentos.

## Decisões (validadas com o usuário)

| Tema | Decisão | Motivo |
|---|---|---|
| Arquitetura | Frontend HTML estático + **Supabase** (PostgreSQL gerenciado) | Máquina sem runtime; só LAN; usuário não quer manter servidor. Supabase = Postgres + Auth JWT + backup automático. |
| Hospedagem | GitHub Pages (fluxo já usado) | Zero runtime, deploy trivial. |
| Planilhas | **Híbrido**: colunas tipadas + colunas de fórmula | Equilíbrio entre robustez (tipo ERP) e flexibilidade. |
| Criação de planilhas | **Livre**: qualquer usuário cria planilhas e colunas pela tela | "Sem programação" via JSONB por linha. |
| Permissões | **Leves**: todo logado tem acesso total; admin gerencia usuários e vê logs | Pedido do usuário ("controle, mas tudo liberado"). |
| Build | **Fase 1 primeiro** (núcleo usável), depois 2 e 3 | Entregar valor rápido. |

## Como mapeia na lista original do usuário

- Front React/Next → HTML estático (mesmo resultado, sem build).
- Back-end Node → API automática do Supabase (sem servidor a manter).
- PostgreSQL → Supabase.
- JWT → Supabase Auth.
- Backup automático → Supabase.

## Banco de dados (6 tabelas)

- `perfis` — usuário ligado ao login (nome, papel admin/usuario, ativo).
- `departamentos` — Fiscal, Contábil, DP, Financeiro, Comercial, TI (admin cria mais).
- `planilhas` — pertence a um departamento.
- `colunas` — estrutura da planilha (nome, tipo, fórmula, ordem).
- `linhas` — registros; dados em **JSONB** (planilha sem migração de schema).
- `logs` — auditoria (quem, ação, o quê, quando).

Segurança via **RLS**: só autenticado acessa; admin gerencia usuários e lê logs; demais tabelas liberadas a qualquer logado.

## Motor das planilhas (Híbrido)

- Tipos de coluna: Texto, Número, Moeda (R$), Data, Sim/Não, Seleção, **Fórmula**.
- Fórmula por linha referencia outras colunas: `[base] * [aliquota] / 100`, com `SE()`, `ARRED()`, `SOMA()`, etc. Avaliação por parser próprio (sem `eval`).
- Rodapé com totais (soma/média/contagem) sobre o conjunto filtrado.
- Busca global + ordenação por coluna. Paginação no render (aguenta milhares de registros).
- Exporta Excel (SheetJS) e PDF (jsPDF + autotable).

## Fases

1. **Núcleo** (esta entrega): login, departamentos, CRUD de planilhas, grade híbrida com fórmulas, busca/ordenação, totais, export Excel/PDF, layout responsivo corporativo. Logs já são gravados.
2. **Admin & Import**: importar Excel existente; painel de usuários/departamentos; visualizador de logs.
3. **Dashboard**: indicadores por departamento, gráficos (Chart.js), alertas/pendências, estatísticas.

## Entregáveis

`index.html` (app) · `banco.sql` (schema + RLS + seed) · `MANUAL.md` (instalação) · pasta própria com repo/GitHub Pages.

## Stack / bibliotecas (CDN, já usadas pela MAXIMOS)

SheetJS `xlsx@0.18.5` · jsPDF `2.5.1` + autotable `3.8.2` · `@supabase/supabase-js@2` · (Fase 3) Chart.js.
