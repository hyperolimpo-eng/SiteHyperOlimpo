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
