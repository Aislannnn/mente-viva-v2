# Estado da versão de 12/11/2026

## Convite do cuidador

O cuidador autenticado, ainda sem vínculo, gera um código de uso único válido por 24 horas e copia um link para a Pessoa Assistida. O link conserva o código durante a navegação de login, inclusive no retorno do Google. A Pessoa Assistida vê quais dados serão compartilhados e aceita o convite em sua própria conta. O vínculo continua removível nas configurações.

A migração `caregiver_invites_assisted_acceptance` foi aplicada ao projeto Supabase `hdgxxdaedzidkpfmsvra` em 12/11/2026. A tabela está em esquema privado com RLS, e só contas autenticadas podem executar as duas funções novas. Os RPCs anteriores permanecem para as versões antigas do app.

## Biometria

Android e iOS poderão ativar impressão digital ou reconhecimento facial nas configurações, após uma autenticação de teste no próprio aparelho. Na abertura seguinte, a sessão existente pede biometria. Se falhar, a pessoa pode sair e entrar com sua conta. O app não coleta nem armazena imagens, digitais ou senhas biométricas. O recurso ainda precisa de teste em aparelhos físicos.

## Google

O botão e o fluxo OAuth estão no cliente. Para entrar pelo Google, criar um cliente OAuth no Google Auth Platform e configurar Client ID e Client Secret em **Supabase → Authentication → Sign In / Providers → Google**. O URI autorizado no Google é `https://hdgxxdaedzidkpfmsvra.supabase.co/auth/v1/callback`. Confirmar o retorno web `https://aislannnn.github.io/mente-viva-v2/` e adicionar `menteviva://login-callback/` aos redirects do Supabase antes do teste nativo. Guardar o segredo somente nos painéis do Google e Supabase.

## E-mail de confirmação

O modelo em `supabase/templates/confirmation.html` usa português claro, a logo existente e `{{ .ConfirmationURL }}`. Assunto sugerido: **Confirme seu e-mail para usar o Mente Viva**. A logo aparece no corpo do e-mail pela URL pública do arquivo `assets/images/logo.png` da branch `main`; não é um anexo para download.

**Ainda não está ativo no Supabase.** O painel do projeto Free exige SMTP próprio para editar o assunto e o corpo do e-mail padrão. As outras opções exibidas são usar um hook de envio ou mudar para o plano Pro. Antes de ativar o modelo, configurar uma dessas opções, conferir que a imagem abre e enviar um e-mail de teste. Sem isso, o Supabase continuará enviando a mensagem padrão.

## Verificações

Os 22 testes Flutter, a análise estática e a compilação web passaram antes da publicação. Permanecem testes com duas contas reais para convite e isolamento de dados, em aparelhos Android e iOS para biometria, e em clientes de e-mail para o modelo personalizado.
