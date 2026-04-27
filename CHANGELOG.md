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
