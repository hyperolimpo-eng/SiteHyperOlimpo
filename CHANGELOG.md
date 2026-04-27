# Histórico de Alterações — HyperOlimpo

Registro de todas as alterações de comportamento do código feitas neste projeto.

---

## Formato de entrada

Cada entrada documenta:
- **Data** da alteração
- **Arquivo(s)** modificado(s)
- **Comportamento anterior** (o que existia antes)
- **Comportamento novo** (o que foi implementado)
- **Motivação** (por que foi feito)

---

<!-- As entradas mais recentes ficam no topo -->

## 2026-04-27 — Separação de CSS em arquivos externos

- **Arquivos criados:** `base.css`, `index.css`, `cadastro-cliente.css`, `reset-password.css`
- **Arquivos modificados:** `index.html`, `cadastro-cliente.html`, `reset-password.html`
- **Comportamento anterior:** Todo o CSS de cada página estava inline em blocos `<style>` dentro do próprio HTML. Variáveis `:root` e reset duplicados nas três páginas.
- **Comportamento novo:**
  - `base.css`: reset universal, variáveis CSS (`:root`) e estilos base (scrollbar, `::selection`) compartilhados por todas as páginas
  - `index.css`: todos os estilos exclusivos da landing page (`index.html`)
  - `cadastro-cliente.css`: todos os estilos exclusivos da página de cadastro
  - `reset-password.css`: todos os estilos exclusivos da página de redefinição de senha
  - Cada HTML carrega `base.css` + seu CSS específico via `<link rel="stylesheet">`
  - Blocos `<style>` inline removidos completamente dos três arquivos HTML
- **Motivação:** Solicitação do usuário para melhorar a manutenibilidade e separação de responsabilidades

## 2026-04-27 — Integração completa com Supabase (banco de dados e autenticação)

- **Arquivos:** `supabase-config.js` (novo), `schema.sql` (novo), `reset-password.html` (novo), `index.html`, `cadastro-cliente.html`
- **Comportamento anterior:** Todos os formulários eram fake (sem backend). Login, recuperação de senha, contato e cadastro não persistiam dados.
- **Comportamento novo:**
  - **`supabase-config.js`:** Inicializa cliente Supabase global (`db`) com URL e anon key. Carregado por todas as páginas.
  - **`schema.sql`:** Esquema completo do banco com tabelas `clientes`, `contatos` e `solicitacoes_parceria`. RLS habilitado: insert público para todas; select/update próprio para clientes via `auth.uid() = user_id`. Trigger `update_updated_at` na tabela clientes.
  - **`reset-password.html`:** Página de redefinição de senha. Detecta evento `PASSWORD_RECOVERY` via `db.auth.onAuthStateChange()` e chama `db.auth.updateUser({ password })`.
  - **`index.html` — Formulário de contato:** `handleSubmit` agora é `async`; salva no Supabase `db.from('contatos').insert({...})` com todos os campos com `name` attribute.
  - **`index.html` — Login:** Usa `db.auth.signInWithPassword({ email, password })`.
  - **`index.html` — Recuperar acesso:** Usa `db.auth.resetPasswordForEmail(email, { redirectTo: .../reset-password.html })`.
  - **`index.html` — Solicitar Parceria:** Salva e-mail em `db.from('solicitacoes_parceria').insert({ email })` antes de enviar EmailJS e CallMeBot.
  - **`cadastro-cliente.html`:** Submit handler agora `async`. Chama `db.auth.signUp({ email, password })` para criar conta Auth, depois `db.from('clientes').insert({...})` com todos os campos do formulário (PF e PJ). Datas convertidas de DD/MM/YYYY para ISO YYYY-MM-DD. Arrays (horário, serviços) passados como TEXT[].
- **Pendente de configuração pelo usuário:**
  - Criar projeto no Supabase, rodar `schema.sql` no SQL Editor
  - Preencher `SUPABASE_URL` e `SUPABASE_ANON_KEY` em `supabase-config.js`
  - Configurar EmailJS (templates TPL_LINK_CADASTRO e TPL_NOTIF_INTERNA)
  - Registrar CallMeBot para obter apikey do WhatsApp
  - Configurar URL de redirecionamento de auth no painel Supabase
- **Motivação:** Solicitação do usuário para substituir os formulários fake por banco de dados real

## 2026-04-27 — Fluxo "Solicitar Parceria" na pop-up de login

- **Arquivo:** `index.html`
- **Comportamento anterior:** Pop-up de login com dois painéis (login e recuperação de acesso). Sem forma de novos clientes solicitarem cadastro.
- **Comportamento novo:**
  - Botão "🤝 Solicitar Parceria" adicionado ao painel de login, separado por divisor "ou"
  - Novo **painel Parceria** (3º painel no modal): campo de e-mail + botão "Enviar Link de Cadastro" + estado de sucesso
  - Navegação bidirecional entre todos os painéis (login ↔ forgot ↔ parceria)
  - Ao submeter o e-mail no painel Parceria, 3 ações ocorrem:
    1. **EmailJS** envia e-mail ao cliente com link direto para `cadastro-cliente.html`
    2. **EmailJS** envia notificação interna para a equipe HyperOlimpo
    3. **CallMeBot API** envia mensagem automática no WhatsApp da HyperOlimpo com e-mail do cliente, horário e link
  - SDK EmailJS carregado via CDN (`@emailjs/browser@4`)
  - Configurações com constantes comentadas no topo do bloco JS (PUBLIC_KEY, SERVICE_ID, template IDs, WA_NUMBER, WA_APIKEY)
  - Falha do WhatsApp é silenciosa (`.catch(() => {})`) para não bloquear o fluxo
  - CSS: `.modal-or` (separador), `.btn-modal-secondary` (botão estilo secundário)
- **Pendente de configuração:**
  - Conta EmailJS com dois templates (cliente + interno)
  - Registro no CallMeBot para obter apikey do WhatsApp
- **Motivação:** Solicitação do usuário para fluxo de cadastro de novos clientes com notificação automática por e-mail e WhatsApp

## 2026-04-27 — Página de cadastro de clientes (PF e PJ)

- **Arquivo:** `cadastro-cliente.html` (novo)
- **Comportamento anterior:** Sem página de cadastro.
- **Comportamento novo:**
  - Toggle Pessoa Física / Pessoa Jurídica no topo — mostra/oculta seções relevantes dinamicamente
  - **Seção 1 (PJ):** Razão Social, Nome Fantasia, CNPJ, Inscrição Estadual e Municipal, Data de Abertura, Natureza Jurídica, Porte, Ramo de Atividade, Site
  - **Seção Dados Pessoais / Responsável:** Nome, CPF, RG, Órgão Emissor, Data de Nascimento, Estado Civil, Gênero, Profissão, Nacionalidade (PF) / Cargo (PJ)
  - **Seção Contato:** E-mail principal e secundário, Celular/WhatsApp, Telefone Fixo, LinkedIn, Instagram, horário de atendimento preferencial (checkboxes)
  - **Seção Endereço:** CEP com busca automática via API ViaCEP, Logradouro, Número, Complemento, Bairro, Cidade, Estado, País
  - **Seção Interesse:** Checkboxes de serviços, origem, orçamento estimado, descrição do projeto, observações
  - **Seção Acesso:** Senha + confirmar senha com toggle de visibilidade e barra de força de senha (5 níveis com cores)
  - Masks de entrada: CPF, CNPJ, CEP, celular, telefone fixo, data
  - Validação frontend com highlight de campos inválidos e scroll automático ao primeiro erro
  - Overlay de sucesso com nome personalizado pós-envio
  - Topbar com logo + link "Voltar ao site"; `noindex, nofollow` nas meta tags
  - Design 100% consistente com o site principal (mesmo sistema de cores, tipografia, cards)
  - Backend pendente: submissão do formulário precisa de API / Firebase / Supabase (TODO no JS)
- **Motivação:** Solicitação do usuário para página profissional de cadastro PF e PJ

## 2026-04-27 — Área do Cliente: modal de login e recuperação de acesso

- **Arquivo:** `index.html`
- **Comportamento anterior:** Sem área do cliente. Nenhum link de acesso no menu.
- **Comportamento novo:**
  - Link "Área do Cliente" adicionado ao `#navMenu` (desktop) e `#navOverlay` (mobile), com estilo visual diferenciado (borda + cor accent)
  - Modal fullscreen com `backdrop-filter: blur` e animação de entrada (scale + translateY)
  - **Painel 1 — Login:** campos e-mail e senha, botão "Entrar", estado de carregamento, mensagem de erro, link "Esqueci meu acesso"
  - **Painel 2 — Recuperar Acesso:** campo de e-mail, botão com estado de carregamento, links de suporte (e-mail `atendimento@hyperolimpo.com.br` e WhatsApp), estado de sucesso com ícone e mensagem
  - Modal fecha ao clicar no overlay, no botão ✕ ou pressionar Esc; body scroll bloqueado quando aberto
  - Validação de e-mail via regex no frontend
  - **Integração de backend pendente:** autenticação (login) e envio de e-mail de recuperação precisam de API/Firebase/Supabase — pontos `TODO` marcados no código
- **Motivação:** Solicitação do usuário para adicionar acesso à área do cliente com fluxo de login e recuperação de senha

## 2026-04-27 — Correção do hamburger menu (backdrop-filter containing block)

- **Arquivo:** `index.html`
- **Comportamento anterior:** O `<nav id="navMenu">` era filho do `<header id="navbar">`. Quando a página era rolada, o header recebia `backdrop-filter: blur(18px)`, o que criava um novo *containing block* para filhos com `position: fixed`. O `inset: 0` do nav passava a referenciar o header (altura ~70px) em vez da viewport, exibindo o menu apenas na faixa do topo com links cortados.
- **Comportamento novo:**
  - Criado `<nav id="navOverlay">` como **irmão do `<header>`**, fora do seu DOM — `position: fixed; inset: 0` referencia a viewport em qualquer posição de scroll
  - `<nav id="navMenu">` (dentro do header) permanece para exibição desktop, ocultado no breakpoint ≤768px
  - `#navbar` com `z-index: 1060` (acima do overlay 1050) — botão hamburger sempre clicável
  - JS atualizado para togular `#navOverlay`
- **Motivação:** Bug reportado pelo usuário — menu não abria corretamente ao rolar a página

## 2026-04-27 — Responsividade total (3 breakpoints + hamburger menu)

- **Arquivo:** `index.html`
- **Comportamento anterior:** Apenas um media query `max-width: 768px` que ocultava o `<nav>` sem oferecer alternativa de navegação mobile. Sem breakpoint para tablet ou mobile pequeno. Sem hamburger menu.
- **Comportamento novo:**
  - **Hamburger menu:** botão com 3 barras animadas para X ao abrir; nav vira overlay fullscreen com blur e fade; fecha ao clicar em link, botão ou tecla Esc; bloqueia scroll do body quando aberto
  - **Breakpoint ≤ 1024px (tablet grande):** grids de serviços e diferenciais ajustados para 2 colunas, gaps reduzidos
  - **Breakpoint ≤ 768px (tablet/mobile):** hero com padding reduzido e botões em coluna; seções com padding menor; stats em 2×2; serviços em 1 coluna; processo em 2×2; about empilhado com orbital menor; diferenciais em 2 colunas; contato empilhado; footer empilhado e centralizado
  - **Breakpoint ≤ 480px (mobile pequeno):** processo e diferenciais em 1 coluna; footer-links em coluna; hero-scroll oculto; padding mínimo
  - `body { overflow: hidden }` bloqueado enquanto menu mobile está aberto
  - `aria-expanded` no botão hamburger para acessibilidade
  - Suporte a `100svh` no hero para mobile com barra de navegador do browser
- **Motivação:** Solicitação do usuário para tornar o site 100% responsivo em todas as plataformas

## 2026-04-27 — Botão flutuante de WhatsApp

- **Arquivo:** `index.html`
- **Comportamento anterior:** Nenhum botão de acesso rápido ao WhatsApp; o único link estava na seção de contato, inacessível durante a navegação.
- **Comportamento novo:**
  - Botão circular fixo (`position: fixed`) no canto inferior direito, acompanha a rolagem em toda a página
  - Ícone SVG oficial do WhatsApp com fundo verde (`#25D366`)
  - Animação de pulso (`wa-pulse`) em anel ao redor do botão para chamar atenção
  - Efeito hover: escala + sombra ampliada
  - Tooltip "Fale conosco!" exibido ao passar o mouse (oculto em mobile)
  - Link `https://wa.me/5500000000000` abre conversa direta (número placeholder — substituir pelo real)
  - `target="_blank" rel="noopener noreferrer"` para segurança
  - Responsivo: tamanho reduzido em telas menores que 768px, tooltip ocultado
- **Motivação:** Facilitar o contato imediato pelo WhatsApp a qualquer momento da navegação

## 2026-04-27 — Implementação de SEO completo

- **Arquivo:** `index.html`
- **Comportamento anterior:** `<head>` continha apenas charset, viewport e título genérico ("HyperOlimpo — Tecnologia que Eleva"). Sem meta description, keywords, Open Graph ou dados estruturados.
- **Comportamento novo:**
  - `<title>` otimizado com keywords principais
  - `<meta name="description">` com 160 caracteres descrevendo o negócio
  - `<meta name="keywords">` com 20 termos de alto volume para o segmento de tecnologia no Brasil
  - `<meta name="robots" content="index, follow">`
  - `<link rel="canonical">` apontando para `https://hyperolimpo.com.br/`
  - Tags Open Graph (og:title, og:description, og:type, og:locale, og:image, og:url)
  - Tags Twitter Card (summary_large_image)
  - JSON-LD `Organization` com serviços, área de atendimento e contato
  - JSON-LD `WebSite` com SearchAction
- **Motivação:** Melhorar posicionamento orgânico nos buscadores para o segmento de desenvolvimento de software no Brasil
