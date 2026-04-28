// ── Configuração Supabase ─────────────────────────────────────────────────
// 1. Crie conta em https://supabase.com (gratuito)
// 2. Crie um novo projeto
// 3. Vá em Settings → API e copie os valores abaixo:
const SUPABASE_URL      = 'https://tlyeddabxlwbjwokpyri.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRseWVkZGFieGx3Ymp3b2tweXJpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzczODkwNDksImV4cCI6MjA5Mjk2NTA0OX0.pnma5JZhDOxT9dVeDOqvuj5FkvWTuvcpn1nXkD3ELvw';

// Cria o cliente global — disponível em todas as páginas que carregam este arquivo
const db = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
