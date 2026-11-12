# Próxima versão local — ainda não publicada

Esta versão está somente no diretório de trabalho. Não foi enviada ao GitHub nem aplicada ao Supabase.

## Convite do cuidador

O cuidador autenticado, ainda sem vínculo, gera um código de uso único válido por 24 horas e copia um link para a Pessoa Assistida. O link conserva o código durante a navegação de login, inclusive no retorno do Google. A Pessoa Assistida vê claramente quais dados serão compartilhados e aceita o convite em sua própria conta. O vínculo continua sendo removível nas configurações. A migração `20261112013714_caregiver_invites_assisted_acceptance.sql` cria a tabela privada e as duas funções necessárias; ela ainda **precisa ser aplicada** antes que o novo fluxo funcione com contas reais. Os RPCs antigos ficam no servidor para versões já publicadas.

## Biometria

Android e iOS poderão ativar impressão digital ou reconhecimento facial nas configurações, após uma autenticação de teste no próprio aparelho. Na abertura seguinte, a sessão existente pede biometria. Se falhar, a pessoa pode sair e entrar com sua conta. O app não coleta nem armazena imagens, digitais ou senhas biométricas. O recurso depende de um aparelho com biometria cadastrada e ainda requer teste físico em Android e iOS.

## Google

O botão e o fluxo OAuth já estão no cliente. Para entrar de verdade, criar um cliente OAuth no Google Auth Platform e configurar Client ID e Client Secret em **Supabase → Authentication → Sign In / Providers → Google**. O URI autorizado no Google é `https://hdgxxdaedzidkpfmsvra.supabase.co/auth/v1/callback`. Confirmar o retorno web `https://aislannnn.github.io/mente-viva-v2/` e adicionar `menteviva://login-callback/` aos redirects do Supabase antes do teste nativo. Guardar o segredo somente nos painéis do Google e Supabase.

## E-mail de confirmação

O modelo em `supabase/templates/confirmation.html` usa português claro, a logo existente e o link de confirmação do Supabase. Assunto sugerido: **Confirme seu e-mail para usar o Mente Viva**. Para ativá-lo no projeto hospedado, copiar o HTML para **Supabase → Authentication → Email Templates → Confirm sign up** e definir esse assunto. O campo `{{ .ConfirmationURL }}` deve permanecer intacto.

A logo aparece no corpo do e-mail a partir do arquivo público `assets/images/logo.png` da branch `main` no GitHub. O site publica versões em endereços temporários, por isso não deve ser usado como origem da imagem. O modelo padrão de e-mail do Supabase não adiciona arquivos anexos. Antes da ativação, confirmar que a imagem abre no endereço indicado e enviar um e-mail de teste. Se o cliente de e-mail bloquear imagens externas, o texto alternativo e o nome Mente Viva continuam visíveis. Nada foi alterado no painel do Supabase nesta versão local.

## Validação antes de publicar

1. Aplicar a migração no projeto certo e conferir RLS e permissões das funções.
2. Testar convite, link, aceitação e desvínculo com duas contas reais de perfis distintos.
3. Configurar Google e testar ida, retorno e escolha do perfil em web e celular.
4. Testar biometria em aparelho Android e iPhone, inclusive cancelamento e ausência de biometria cadastrada.
5. Conferir a logo, aplicar e testar o modelo de e-mail de confirmação no Supabase.
6. Executar análise, testes, builds e então publicar somente com autorização.
