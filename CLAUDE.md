# CLAUDE.md — HyperOlimpo

Documentação do projeto e registro de ações executadas pelo assistente.

---

## Projeto

**Nome:** HyperOlimpo — Site institucional / landing page  
**Stack:** HTML, CSS, JavaScript (site estático)  
**Servidor local:** `python -m http.server 8080`  
**Banco de dados:** Nenhum — site 100% estático

---

## Convenções

- Todo código gerado deve ser registrado no `CHANGELOG.md` (comportamento anterior vs. novo)
- Todo código gerado deve ser registrado na seção **Histórico de Ações** deste arquivo
- Após cada alteração no site, criar um commit na branch `staging` com mensagem descritiva
- Não há backend; integrações externas (e-mail, WhatsApp) devem usar serviços de terceiros (Formspree, EmailJS, etc.)

### Fluxo de branches
- `staging` — branch de desenvolvimento; todo commit de alteração vai aqui
- `main` — branch de produção; merge feito manualmente pelo usuário quando pronto

---

## Histórico de Ações

<!-- As entradas mais recentes ficam no topo -->

### 2026-04-27 — Botão flutuante de WhatsApp
- Adicionado botão circular fixo no canto inferior direito com ícone SVG do WhatsApp
- Animação de pulso contínua, tooltip ao hover, responsivo em mobile
- Número atual é placeholder (`5500000000000`) — substituir pelo número real
- Motivação: acesso rápido ao WhatsApp em qualquer ponto da navegação

### 2026-04-27 — Implementação de SEO completo no index.html
- Adicionadas meta tags (description, keywords, robots, canonical)
- Adicionadas tags Open Graph e Twitter Card para compartilhamento social
- Adicionados dados estruturados JSON-LD (Organization + WebSite)
- Keywords focadas em: desenvolvimento de software, criação de sites, automação, BI — segmento tecnologia, Brasil
- Motivação: solicitação do usuário para otimizar o site para buscadores

### 2026-04-27 — Configuração da branch staging e convenção de commits
- Criada branch `staging` a partir de `main`
- Definida convenção: cada alteração no site gera um commit na branch `staging`
- Motivação: solicitação do usuário para versionar cada alteração separadamente

### 2026-04-27 — Criação dos arquivos de rastreamento
- Criado `CHANGELOG.md` para histórico de alterações de código
- Criado `CLAUDE.md` (este arquivo) para documentação e log de ações
- Motivação: solicitação do usuário para rastrear todas as ações executadas pelo assistente
