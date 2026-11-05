# JDTEC 2026 — Plataforma (deploy automático no Netlify)

Aplicação React + Vite + Supabase. O Netlify compila o código automaticamente quando o repositório GitHub é conectado e publicado.

## Publicação sem Visual Studio Code

### 1. Colocar o projeto no GitHub pelo navegador
1. Entre em https://github.com e crie um repositório novo, por exemplo `jdtec-2026-plataforma`.
2. Deixe o repositório **Private** (recomendado).
3. Extraia este ZIP no computador.
4. No repositório, use **Add file > Upload files** e arraste os arquivos e pastas que estão dentro da pasta `JDTEC-2026-Plataforma-v2` (não envie a pasta externa como um ZIP).
5. Clique em **Commit changes**.

### 2. Conectar ao Netlify
1. Entre em https://app.netlify.com.
2. Escolha **Add new project > Import an existing project**.
3. Selecione **GitHub**, autorize o acesso ao repositório e escolha `jdtec-2026-plataforma`.
4. O arquivo `netlify.toml` já define:
   - Build command: `npm run build`
   - Publish directory: `dist`
   - Node.js: `20`
5. Antes de publicar, abra **Environment variables** e adicione:
   - `VITE_SUPABASE_URL` = URL do projeto Supabase (Project URL)
   - `VITE_SUPABASE_ANON_KEY` = chave publicável/anon do Supabase
6. Clique em **Deploy**. O Netlify executará `npm run build` e publicará a pasta `dist` automaticamente.

### 3. Atualizações futuras
Quando os arquivos forem alterados no GitHub, o Netlify fará um novo build e deploy automaticamente.

## Configuração Supabase
Copie os valores em Supabase > Project Settings > API (ou API Keys): Project URL e chave publicável/anon. **Nunca** use `service_role`/secret key no navegador, no GitHub ou em variáveis `VITE_*`.

O app usa as RPCs e tabelas descritas no histórico de implementação. As variáveis são injetadas durante o build; depois de alterá-las no Netlify, faça um novo deploy.

## Importante: validação antes de produção
Este pacote prepara o processo de build e deploy, mas não significa que a aplicação já foi validada integralmente contra o banco real. Antes de divulgar o endereço:
- Faça deploy de teste e verifique se o build termina com sucesso.
- Teste login e saída com as três funções de usuário.
- Teste inscrição de avaliador, aprovação e recusa com contas de teste.
- Teste cadastro e edição de projeto e avaliação com avaliador atribuído.
- Revise as políticas RLS e as assinaturas das RPCs no Supabase.
- Não compartilhe chaves secretas.

Funcionalidades ainda não concluídas no app: distribuição/atribuição de projetos pela interface, edição/exclusão administrativa de projetos, configuração de pesos, cálculo/apresentação de classificação final, certificados e upload de arquivos para Storage. A tela de avaliação também precisa ser testada com a regra de rascunho/conclusão antes de uso real.
