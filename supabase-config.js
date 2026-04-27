// ── Configuração Supabase ─────────────────────────────────────────────────
// 1. Crie conta em https://supabase.com (gratuito)
// 2. Crie um novo projeto
// 3. Vá em Settings → API e copie os valores abaixo:
const SUPABASE_URL      = 'https://SEU_PROJECT_REF.supabase.co';
const SUPABASE_ANON_KEY = 'SUA_ANON_KEY_AQUI';

// Cria o cliente global — disponível em todas as páginas que carregam este arquivo
const db = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
