-- ═══════════════════════════════════════════════════════════════════════════
-- HyperOlimpo — Painel Interno (execute após supabase-schema.sql)
-- ═══════════════════════════════════════════════════════════════════════════


-- ── 1. Tabelas ──────────────────────────────────────────────────────────────

create table if not exists public.perfis (
  id          uuid        primary key default gen_random_uuid(),
  nome        text        not null unique,
  descricao   text,
  criado_em   timestamptz not null default now()
);

create table if not exists public.usuarios (
  id            uuid        primary key default gen_random_uuid(),
  user_id       uuid        references auth.users(id) on delete set null,
  perfil_id     uuid        references public.perfis(id) on delete set null,
  nome_completo text        not null,
  email         text        not null unique,
  cargo         text,
  departamento  text,
  telefone      text,
  ativo         boolean     not null default true,
  criado_em     timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table if not exists public.projetos (
  id             uuid        primary key default gen_random_uuid(),
  nome           text        not null,
  descricao      text,
  cliente_id     uuid        references public.clientes(id) on delete set null,
  responsavel_id uuid        references public.usuarios(id) on delete set null,
  status         text        not null default 'solicitado'
                             check (status in ('solicitado','em_andamento','finalizado','cancelado','pausado')),
  prioridade     text        not null default 'media'
                             check (prioridade in ('baixa','media','alta','urgente')),
  valor          numeric(12,2),
  data_inicio    date,
  data_previsao  date,
  data_conclusao date,
  criado_em      timestamptz not null default now(),
  atualizado_em  timestamptz not null default now()
);

create table if not exists public.cliente_servicos (
  id           uuid        primary key default gen_random_uuid(),
  cliente_id   uuid        not null references public.clientes(id) on delete cascade,
  nome_servico text        not null,
  descricao    text,
  status       text        not null default 'ativo' check (status in ('ativo','pausado','encerrado')),
  valor_mensal numeric(10,2),
  data_inicio  date,
  data_fim     date,
  observacoes  text,
  criado_em    timestamptz not null default now()
);

create table if not exists public.financeiro_gastos (
  id             uuid        primary key default gen_random_uuid(),
  descricao      text        not null,
  categoria      text,
  valor          numeric(10,2) not null,
  data           date        not null,
  status         text        not null default 'pago' check (status in ('pendente','pago','cancelado')),
  responsavel_id uuid        references public.usuarios(id) on delete set null,
  observacoes    text,
  criado_em      timestamptz not null default now()
);

create table if not exists public.financeiro_contas_pagar (
  id              uuid          primary key default gen_random_uuid(),
  descricao       text          not null,
  fornecedor      text,
  categoria       text,
  valor           numeric(10,2) not null,
  data_vencimento date          not null,
  data_pagamento  date,
  status          text          not null default 'pendente'
                                check (status in ('pendente','pago','vencido','cancelado')),
  observacoes     text,
  criado_em       timestamptz   not null default now()
);

create table if not exists public.financeiro_contas_receber (
  id               uuid          primary key default gen_random_uuid(),
  descricao        text          not null,
  cliente_id       uuid          references public.clientes(id) on delete set null,
  projeto_id       uuid          references public.projetos(id) on delete set null,
  valor            numeric(10,2) not null,
  data_vencimento  date          not null,
  data_recebimento date,
  status           text          not null default 'pendente'
                                 check (status in ('pendente','recebido','vencido','cancelado')),
  observacoes      text,
  criado_em        timestamptz   not null default now()
);


-- ── 2. Triggers atualizado_em ────────────────────────────────────────────────

create or replace trigger usuarios_updated_at
  before update on public.usuarios
  for each row execute function public.set_updated_at();

create or replace trigger projetos_updated_at
  before update on public.projetos
  for each row execute function public.set_updated_at();


-- ── 3. Função de verificação de funcionário (SECURITY DEFINER) ───────────────
-- SECURITY DEFINER evita recursão ao consultar a própria tabela usuarios com RLS ativo

create or replace function public.is_funcionario()
returns boolean
language sql
security definer
set search_path = public
stable as $$
  select exists (
    select 1 from usuarios where user_id = auth.uid() and ativo = true
  );
$$;


-- ── 4. RLS ───────────────────────────────────────────────────────────────────

alter table public.perfis enable row level security;
create policy "perfis: funcionarios"
  on public.perfis for all
  using (public.is_funcionario());

alter table public.usuarios enable row level security;
create policy "usuarios: select"
  on public.usuarios for select
  using (auth.uid() = user_id or public.is_funcionario());
create policy "usuarios: write"
  on public.usuarios for all
  using (public.is_funcionario());

alter table public.projetos enable row level security;
create policy "projetos: funcionarios"
  on public.projetos for all
  using (public.is_funcionario());

alter table public.cliente_servicos enable row level security;
create policy "servicos: funcionarios"
  on public.cliente_servicos for all
  using (public.is_funcionario());
create policy "servicos: cliente proprio"
  on public.cliente_servicos for select
  using (exists (
    select 1 from clientes
    where clientes.id = cliente_servicos.cliente_id
      and clientes.user_id = auth.uid()
  ));

alter table public.financeiro_gastos enable row level security;
create policy "gastos: funcionarios"
  on public.financeiro_gastos for all
  using (public.is_funcionario());

alter table public.financeiro_contas_pagar enable row level security;
create policy "pagar: funcionarios"
  on public.financeiro_contas_pagar for all
  using (public.is_funcionario());

alter table public.financeiro_contas_receber enable row level security;
create policy "receber: funcionarios"
  on public.financeiro_contas_receber for all
  using (public.is_funcionario());

-- Permite funcionários verem todos os clientes (complementa a policy existente)
create policy "clientes: funcionarios veem tudo"
  on public.clientes for select
  using (public.is_funcionario());
create policy "clientes: funcionarios escrevem"
  on public.clientes for all
  using (public.is_funcionario());


-- ── 5. Dados de exemplo ──────────────────────────────────────────────────────

-- Perfis
insert into public.perfis (id, nome, descricao) values
  ('f1000000-0000-0000-0000-000000000001', 'Administrador',  'Acesso total ao sistema'),
  ('f2000000-0000-0000-0000-000000000002', 'Desenvolvedor',  'Acesso a projetos e clientes'),
  ('f3000000-0000-0000-0000-000000000003', 'Financeiro',     'Acesso ao módulo financeiro'),
  ('f4000000-0000-0000-0000-000000000004', 'Comercial',      'Acesso a clientes e propostas'),
  ('f5000000-0000-0000-0000-000000000005', 'Suporte',        'Acesso a chamados e clientes')
on conflict (id) do nothing;

-- Usuários (user_id null — vincular após criar o auth user no Supabase Dashboard)
insert into public.usuarios (id, perfil_id, nome_completo, email, cargo, departamento) values
  ('e1000000-0000-0000-0000-000000000001', 'f1000000-0000-0000-0000-000000000001', 'Rafael Bernardino',   'rafael@hyperolimpo.com.br',   'CEO',                   'Diretoria'),
  ('e2000000-0000-0000-0000-000000000002', 'f2000000-0000-0000-0000-000000000002', 'Lucas Mendes',        'lucas@hyperolimpo.com.br',    'Desenvolvedor Sênior',  'Tecnologia'),
  ('e3000000-0000-0000-0000-000000000003', 'f2000000-0000-0000-0000-000000000002', 'Ana Paula Ferreira',  'ana@hyperolimpo.com.br',      'Desenvolvedora Full Stack', 'Tecnologia'),
  ('e4000000-0000-0000-0000-000000000004', 'f3000000-0000-0000-0000-000000000003', 'Carlos Oliveira',     'carlos@hyperolimpo.com.br',   'Analista Financeiro',   'Financeiro'),
  ('e5000000-0000-0000-0000-000000000005', 'f4000000-0000-0000-0000-000000000004', 'Fernanda Costa',      'fernanda@hyperolimpo.com.br', 'Executiva de Contas',   'Comercial')
on conflict (id) do nothing;

-- Clientes de exemplo
insert into public.clientes (id, tipo_pessoa, nome_completo, razao_social, cnpj, email, celular, cidade, estado_uf, status, servicos) values
  ('d1000000-0000-0000-0000-000000000001', 'PJ', 'Marcos Dutra',         'TechBr Soluções Ltda',    '12.345.678/0001-90', 'contato@techbr.com.br',       '(11) 91234-5678', 'São Paulo',       'SP', 'ativo',    '{"web","sistemas"}'),
  ('d2000000-0000-0000-0000-000000000002', 'PF', 'Carlos Eduardo Silva', null,                       null,                 'carlos.silva@email.com',      '(21) 98765-4321', 'Rio de Janeiro',  'RJ', 'ativo',    '{"mobile"}'),
  ('d3000000-0000-0000-0000-000000000003', 'PJ', 'Patricia Nunes',       'Agro Norte Grãos S.A.',   '98.765.432/0001-10', 'financeiro@agronorte.com',    '(65) 93456-7890', 'Cuiabá',          'MT', 'ativo',    '{"bi","automacao"}'),
  ('d4000000-0000-0000-0000-000000000004', 'PF', 'Marina Souza Ferreira',null,                       null,                 'marina.sf@gmail.com',         '(31) 99876-5432', 'Belo Horizonte',  'MG', 'pendente', '{"web"}'),
  ('d5000000-0000-0000-0000-000000000005', 'PJ', 'Roberto Alves',        'Rede Saúde & Vida Ltda',  '11.222.333/0001-44', 'ti@redesaudeavida.com.br',    '(41) 94567-8901', 'Curitiba',        'PR', 'ativo',    '{"sistemas","api"}')
on conflict (id) do nothing;

-- Projetos
insert into public.projetos (id, nome, descricao, cliente_id, responsavel_id, status, prioridade, valor, data_inicio, data_previsao) values
  ('c1000000-0000-0000-0000-000000000001', 'Portal Corporativo TechBr',         'Desenvolvimento do portal web institucional com área do cliente', 'd1000000-0000-0000-0000-000000000001', 'e2000000-0000-0000-0000-000000000002', 'em_andamento', 'alta',    48000.00, '2026-03-01', '2026-06-30'),
  ('c2000000-0000-0000-0000-000000000002', 'App Mobile Carlos Silva',            'Aplicativo de gestão pessoal para iOS e Android',                  'd2000000-0000-0000-0000-000000000002', 'e3000000-0000-0000-0000-000000000003', 'solicitado',   'media',   32000.00, null,         '2026-08-01'),
  ('c3000000-0000-0000-0000-000000000003', 'Dashboard BI Agro Norte',            'Painel de Business Intelligence com dados de produção agrícola',   'd3000000-0000-0000-0000-000000000003', 'e2000000-0000-0000-0000-000000000002', 'em_andamento', 'alta',    75000.00, '2026-02-15', '2026-07-15'),
  ('c4000000-0000-0000-0000-000000000004', 'Site Portfólio Marina Ferreira',     'Site portfólio responsivo com blog integrado',                     'd4000000-0000-0000-0000-000000000004', 'e3000000-0000-0000-0000-000000000003', 'finalizado',   'baixa',    8500.00, '2026-01-10', '2026-02-28'),
  ('c5000000-0000-0000-0000-000000000005', 'Sistema de Agendamentos Rede Saúde', 'Sistema de agendamento médico com integração de prontuário',       'd5000000-0000-0000-0000-000000000005', 'e2000000-0000-0000-0000-000000000002', 'em_andamento', 'urgente', 120000.00, '2026-01-20', '2026-09-30')
on conflict (id) do nothing;

-- Serviços contratados por cliente
insert into public.cliente_servicos (cliente_id, nome_servico, descricao, status, valor_mensal, data_inicio) values
  ('d1000000-0000-0000-0000-000000000001', 'Hospedagem e Infraestrutura', 'Servidor dedicado + CDN + SSL',        'ativo',    890.00,  '2026-03-01'),
  ('d1000000-0000-0000-0000-000000000001', 'Manutenção Mensal',           'Suporte técnico e atualizações',        'ativo',   1200.00,  '2026-04-01'),
  ('d3000000-0000-0000-0000-000000000003', 'BI — Licença e Suporte',      'Acesso ao painel BI + suporte mensal',  'ativo',   2500.00,  '2026-02-15'),
  ('d5000000-0000-0000-0000-000000000005', 'Hospedagem Premium',          'Alta disponibilidade 99.9%',            'ativo',   1500.00,  '2026-01-20'),
  ('d5000000-0000-0000-0000-000000000005', 'Suporte Técnico Prioritário', 'SLA 4h, atendimento 24x7',              'ativo',   3200.00,  '2026-01-20')
on conflict do nothing;

-- Gastos operacionais
insert into public.financeiro_gastos (descricao, categoria, valor, data, status) values
  ('Servidores AWS — Abril/2026',          'Infraestrutura',        3200.00, '2026-04-01', 'pago'),
  ('Licença GitHub Teams',                 'Software / Licenças',    480.00, '2026-04-05', 'pago'),
  ('Material de escritório',               'Outros',                 210.50, '2026-04-10', 'pago'),
  ('Campanha LinkedIn Ads',                'Marketing',             1800.00, '2026-04-15', 'pago'),
  ('Consultoria jurídica — contratos',     'Serviços Terceiros',    2500.00, '2026-04-20', 'pendente')
on conflict do nothing;

-- Contas a pagar
insert into public.financeiro_contas_pagar (descricao, fornecedor, categoria, valor, data_vencimento, status) values
  ('Aluguel sala comercial — Maio/2026',  'Imobiliária Pinheiro',  'Aluguel',   3500.00, '2026-05-05', 'pendente'),
  ('Internet fibra 1Gbps — Maio/2026',   'Vivo Empresas',         'Internet',    380.00, '2026-05-10', 'pendente'),
  ('Energia elétrica — Abril/2026',      'CPFL',                  'Energia',     620.00, '2026-04-25', 'pago'),
  ('Licença Adobe Creative — Anual',     'Adobe Inc.',            'Software',   3600.00, '2026-04-30', 'pendente'),
  ('DARF — Simples Nacional Março',      'Receita Federal',       'Impostos',   1850.00, '2026-04-20', 'pago')
on conflict do nothing;

-- Contas a receber
insert into public.financeiro_contas_receber (descricao, cliente_id, projeto_id, valor, data_vencimento, status) values
  ('Parcela 1/3 — Portal TechBr',          'd1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 16000.00, '2026-04-15', 'recebido'),
  ('Parcela 2/3 — Portal TechBr',          'd1000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001', 16000.00, '2026-05-15', 'pendente'),
  ('Mensalidade BI — Agro Norte Maio',     'd3000000-0000-0000-0000-000000000003', null,                                    2500.00,  '2026-05-01', 'pendente'),
  ('Parcela 2/3 — Sistema Rede Saúde',     'd5000000-0000-0000-0000-000000000005', 'c5000000-0000-0000-0000-000000000005', 40000.00, '2026-04-30', 'vencido'),
  ('Parcela final — Site Marina',          'd4000000-0000-0000-0000-000000000004', 'c4000000-0000-0000-0000-000000000004',  2833.34, '2026-03-15', 'recebido')
on conflict do nothing;


-- ═══════════════════════════════════════════════════════════════════════════
-- COMO VINCULAR UM FUNCIONÁRIO REAL AO PAINEL:
--
-- 1. Supabase → Authentication → Users → Invite user
--    (informe o e-mail do funcionário, ex: rafael@hyperolimpo.com.br)
--
-- 2. Copie o UUID gerado na coluna "UID" da lista de usuários.
--
-- 3. Execute no SQL Editor:
--    UPDATE public.usuarios
--    SET user_id = 'UUID-COPIADO-AQUI'
--    WHERE email = 'rafael@hyperolimpo.com.br';
--
-- 4. O funcionário recebe o e-mail de convite, define a senha
--    e já consegue acessar o painel em /painel.html.
-- ═══════════════════════════════════════════════════════════════════════════
