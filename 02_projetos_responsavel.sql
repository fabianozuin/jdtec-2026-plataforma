-- JDTEC 2026 - Cadastro de projetos por conta/grupo
-- Execute SOMENTE após conferir os nomes/tipos atuais das colunas.
-- A migração é aditiva: não apaga projetos nem usuários existentes.

ALTER TABLE public.projetos
  ADD COLUMN IF NOT EXISTS responsavel_id uuid REFERENCES auth.users(id) ON DELETE RESTRICT;

-- Campos de cadastro já previstos no formulário, adicionados se ainda não existirem.
ALTER TABLE public.projetos
  ADD COLUMN IF NOT EXISTS orientador text,
  ADD COLUMN IF NOT EXISTS coorientador text,
  ADD COLUMN IF NOT EXISTS ods text[],
  ADD COLUMN IF NOT EXISTS palavras_chave text,
  ADD COLUMN IF NOT EXISTS arquivo_url text;

-- Cada projeto novo deve ter um responsável. Projetos antigos podem permanecer sem responsável.
CREATE INDEX IF NOT EXISTS projetos_responsavel_id_idx
  ON public.projetos(responsavel_id);

-- Restringe SELECT/INSERT/UPDATE/DELETE aos próprios projetos e ao ADM.
-- Antes de executar, revise e consolide políticas RLS preexistentes para evitar permissões mais amplas.
ALTER TABLE public.projetos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "projeto_responsavel_select" ON public.projetos;
CREATE POLICY "projeto_responsavel_select"
ON public.projetos FOR SELECT TO authenticated
USING (
  responsavel_id = auth.uid()
  OR public.eh_admin()
  OR EXISTS (
    SELECT 1 FROM public.atribuicoes a
    JOIN public.perfis p ON p.id = auth.uid()
    WHERE a.projeto_id = projetos.id
      AND a.avaliador_id = auth.uid()
      AND p.ativo = true
      AND p.papel = 'avaliador'
  )
);

DROP POLICY IF EXISTS "projeto_responsavel_insert" ON public.projetos;
CREATE POLICY "projeto_responsavel_insert"
ON public.projetos FOR INSERT TO authenticated
WITH CHECK (
  responsavel_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM public.perfis p
    WHERE p.id = auth.uid()
      AND p.ativo = true
      AND p.papel = 'projeto'
  )
);

DROP POLICY IF EXISTS "projeto_responsavel_update" ON public.projetos;
CREATE POLICY "projeto_responsavel_update"
ON public.projetos FOR UPDATE TO authenticated
USING (
  responsavel_id = auth.uid()
  OR public.eh_admin()
)
WITH CHECK (
  responsavel_id = auth.uid()
  OR public.eh_admin()
);

DROP POLICY IF EXISTS "projeto_responsavel_delete" ON public.projetos;
CREATE POLICY "projeto_responsavel_delete"
ON public.projetos FOR DELETE TO authenticated
USING (public.eh_admin());

-- IMPORTANTE:
-- 1) A conta só poderá inserir projetos se o perfil com papel='projeto' existir e estiver ativo.
-- 2) Configure trigger seguro em auth.users para criar perfil de projeto, ou use Edge Function.
-- 3) Não habilite autoaprovação de perfis em produção sem validar e-mail e proteger contra abuso.
-- 4) Revise políticas antigas: permissões permissivas combinam-se com OR no RLS.
-- 5) O responsável poderá editar apenas o projeto cujo responsavel_id seja seu UID.
