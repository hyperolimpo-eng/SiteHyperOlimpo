-- ═══════════════════════════════════════════════════════════════════════════
-- HyperOlimpo — Schema do Banco de Dados (Supabase / PostgreSQL)
-- Execute este arquivo no SQL Editor do seu projeto Supabase:
-- https://app.supabase.com → seu projeto → SQL Editor → New query
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Tabela: clientes ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS clientes (
  id               UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW(),

  -- Tipo e autenticação
  tipo_pessoa      TEXT        NOT NULL CHECK (tipo_pessoa IN ('PF','PJ')),
  user_id          UUID        REFERENCES auth.users(id) ON DELETE SET NULL,
  status           TEXT        DEFAULT 'pendente' CHECK (status IN ('pendente','ativo','inativo')),

  -- Dados Pessoa Física
  nome_completo    TEXT,
  cpf              TEXT        UNIQUE,
  rg               TEXT,
  orgao_emissor    TEXT,
  data_nascimento  DATE,
  estado_civil     TEXT,
  genero           TEXT,
  profissao        TEXT,
  nacionalidade    TEXT,

  -- Dados Pessoa Jurídica
  razao_social     TEXT,
  nome_fantasia    TEXT,
  cnpj             TEXT        UNIQUE,
  inscricao_est    TEXT,
  inscricao_mun    TEXT,
  data_abertura    DATE,
  natureza_juridica TEXT,
  porte            TEXT,
  ramo_atividade   TEXT,
  site_empresa     TEXT,
  cargo            TEXT,

  -- Contato
  email            TEXT        NOT NULL UNIQUE,
  email_secundario TEXT,
  celular          TEXT,
  telefone_fixo    TEXT,
  linkedin         TEXT,
  instagram        TEXT,
  horario_contato  TEXT[],

  -- Endereço
  cep              TEXT,
  logradouro       TEXT,
  numero           TEXT,
  complemento      TEXT,
  bairro           TEXT,
  cidade           TEXT,
  estado_uf        TEXT,
  pais             TEXT        DEFAULT 'Brasil',

  -- Interesse
  servicos         TEXT[],
  origem           TEXT,
  orcamento        TEXT,
  descricao        TEXT,
  observacoes      TEXT
);

-- Atualiza updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_clientes_updated_at
  BEFORE UPDATE ON clientes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ── Tabela: contatos ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS contatos (
  id            UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  nome          TEXT,
  empresa       TEXT,
  email         TEXT,
  telefone      TEXT,
  tipo_projeto  TEXT,
  mensagem      TEXT
);


-- ── Tabela: solicitacoes_parceria ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS solicitacoes_parceria (
  id         UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  email      TEXT        NOT NULL,
  status     TEXT        DEFAULT 'enviado' CHECK (status IN ('enviado','cadastrado','cancelado'))
);


-- ═══════════════════════════════════════════════════════════════════════════
-- RLS — Row Level Security (execute após criar as tabelas)
-- ═══════════════════════════════════════════════════════════════════════════

ALTER TABLE clientes             ENABLE ROW LEVEL SECURITY;
ALTER TABLE contatos             ENABLE ROW LEVEL SECURITY;
ALTER TABLE solicitacoes_parceria ENABLE ROW LEVEL SECURITY;

-- clientes: qualquer um pode cadastrar; só o próprio usuário lê/edita seus dados
CREATE POLICY "insert_clientes_public"  ON clientes FOR INSERT WITH CHECK (true);
CREATE POLICY "select_clientes_own"     ON clientes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "update_clientes_own"     ON clientes FOR UPDATE USING (auth.uid() = user_id);

-- contatos: qualquer um pode inserir (formulário público); leitura só via service role
CREATE POLICY "insert_contatos_public"  ON contatos FOR INSERT WITH CHECK (true);

-- solicitacoes_parceria: qualquer um pode inserir; leitura só via service role
CREATE POLICY "insert_parceria_public"  ON solicitacoes_parceria FOR INSERT WITH CHECK (true);
