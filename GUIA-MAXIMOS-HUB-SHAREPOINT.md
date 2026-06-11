# MAXIMOS Hub — Guia de Montagem no Microsoft 365 (SharePoint)

Sistema interno para centralizar as planilhas da MAXIMOS **por departamento**, usando **Excel de verdade** (todas as fórmulas) na nuvem da Microsoft — sem servidor e sem custo extra (já está incluído no M365 Business).

> **Como funciona:** um site **SharePoint "MAXIMOS Hub"** é o portal. Cada departamento tem sua **biblioteca** com os arquivos `.xlsx`, editados no **Excel Online** (ou no Excel do PC). O **login** é a conta Microsoft de cada pessoa. As **permissões** dizem quem vê cada departamento (admin vê tudo).

**Pré-requisito:** estar logado com uma conta **administradora** do Microsoft 365.

---

## Passo 1 — Criar o site "MAXIMOS Hub"

1. Acesse **https://www.microsoft365.com** e faça login.
2. No canto superior esquerdo, clique no **menu de aplicativos** (9 pontinhos) → **SharePoint**.
3. Clique em **+ Criar site** → **Site de Equipe** (Team site).
4. Escolha um modelo simples (ex.: *Padrão/Equipe*). Em **Nome do site**, digite `MAXIMOS Hub`.
5. Avance: deixe **Privacidade = Privado**, idioma **Português (Brasil)** → **Concluir**.
6. *(Por enquanto, NÃO adicione todo mundo como membro — as pessoas entrarão por departamento no Passo 3/4. Pode adicionar só você e outro admin, se houver.)*

## Passo 2 — Criar uma biblioteca por departamento

Na página do site:
1. Clique em **+ Novo** → **Biblioteca de documentos**.
2. Nomeie como o departamento: `Fiscal` → **Criar**.
3. Repita para: `Contábil`, `Departamento Pessoal`, `Financeiro`, `Comercial`, `TI`.

> Cada biblioteca é como uma "pasta grande" independente — é o que permite dar permissão diferente por departamento.

## Passo 3 — Criar os grupos de cada departamento

1. Acesse o **Centro de administração**: **https://admin.microsoft.com**.
2. Menu **Equipes e grupos → Equipes e grupos ativos → aba Segurança**.
3. **Adicionar um grupo de segurança** → nome `MAXHUB - Fiscal` → **Avançar** → adicione as **pessoas do Fiscal** como membros → **Concluir**.
4. Repita criando: `MAXHUB - Contábil`, `MAXHUB - Departamento Pessoal`, `MAXHUB - Financeiro`, `MAXHUB - Comercial`, `MAXHUB - TI`.

> Daqui pra frente, **dar acesso a alguém = adicionar a pessoa ao grupo do departamento** (um lugar só). Simples de manter.

## Passo 4 — Definir as permissões de cada biblioteca

Faça isto **uma vez para cada biblioteca** (Fiscal, Contábil, …):

1. Abra a biblioteca (ex.: **Fiscal**) → engrenagem ⚙️ → **Configurações da biblioteca** → **Permissões para esta biblioteca de documentos**.
2. Clique em **Parar de herdar permissões** (confirme). Agora essa biblioteca tem permissão própria.
3. **Remova** os grupos herdados “Membros” e “Visitantes” do site (para ninguém de fora ver).
4. Clique em **Conceder Permissões** / **Compartilhar** → adicione o grupo **`MAXHUB - Fiscal`** → nível **Editar** → conceda (pode desmarcar o e-mail de convite).
5. Confirme que os **Proprietários do site** (você/admins) continuam com **Controle Total**.
6. Repita para cada biblioteca com o **grupo correspondente**.

Resultado: cada pessoa só enxerga e edita as planilhas do(s) seu(s) departamento(s); você (admin) vê tudo.

## Passo 5 — Montar a página inicial (o "portal")

1. Na página inicial do site, clique em **Editar** (canto superior direito).
2. Adicione uma seção e o web part **Links Rápidos** → layout **Blocos** (tiles).
3. Adicione **um bloco por departamento**, cada um apontando para a **URL da biblioteca** daquele departamento (abra a biblioteca e copie o endereço). Escolha um ícone/cor pra cada.
4. *(Opcional)* No topo, use o web part **Imagem/Hero** com o logo e o nome **MAXIMOS Hub**.
5. Clique em **Republicar**.

> Assim a equipe abre o MAXIMOS Hub e vê os departamentos como botões — clicou, entrou na planilha.

## Passo 6 — As planilhas (Excel de verdade)

Dentro de qualquer biblioteca de departamento:
- **Criar nova:** **+ Novo → Pasta de trabalho do Excel** → abre o **Excel Online** já salvando na nuvem.
- **Trazer uma existente:** **Carregar → Arquivos** e selecione o `.xlsx`. Depois clique nele para abrir no Excel Online.
- **Todas as fórmulas funcionam** (é o Excel mesmo). Salva sozinho, várias pessoas podem editar juntas, e dá pra ver o **Histórico de versões** (menu **…** do arquivo).
- Prefere o Excel do computador? **Abrir no aplicativo da área de trabalho**.

## Passo 7 — (Opcional) Aparecer no Teams

Em um canal do Teams → **+** (adicionar guia) → **SharePoint** → aponte para o site/biblioteca. Assim quem vive no Teams acessa por lá também.

---

## Administração no dia a dia
- **Novo funcionário / mudou de setor:** adicione/remova a pessoa no **grupo do departamento** (Passo 3). A permissão se ajusta sozinha.
- **Novo departamento:** crie a biblioteca (Passo 2), o grupo (Passo 3), ajuste permissões (Passo 4) e um bloco no portal (Passo 5).
- **Backup/segurança:** o Microsoft 365 mantém versões e lixeira (restauração de arquivos) automaticamente.
- **Boas práticas:** mantenha a permissão **na biblioteca** (departamento), evite permissão arquivo a arquivo; use nomes padronizados nas planilhas (ex.: `DAS 2026 - Cliente X.xlsx`).

> *Observação:* os protótipos HTML criados antes (`index.html`, `experimentar.html`, `banco.sql`) ficam **arquivados** nesta pasta apenas como referência — não fazem parte desta solução final.

---

*MAXIMOS Soluções Empresariais — sistema interno.*
