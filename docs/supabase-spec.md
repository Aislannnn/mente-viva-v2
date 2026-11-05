# Supabase do Mente Viva v2 — especificação e escopo

Estado conferido em 05/11/2026 no projeto `mente-viva-v2` (`hdgxxdaedzidkpfmsvra`). Esta página descreve o que **existe**, o que **falta** e o que **não faz parte** da versão atual. O resumo do Projeto Integrador fornecido pela equipe fundamenta as funções de rotina, memória, jogos e acompanhamento; o banco não pretende registrar diagnóstico ou substituir cuidado profissional.

## 1. O que pode ser removido do painel

As entradas laterais **Authentication, Database, Storage, Edge Functions, Realtime, Observability** etc. são seções do Dashboard do Supabase, comuns ao projeto hospedado. Elas não são páginas criadas no Mente Viva nem objetos do banco. Não há operação de exclusão individual dessas seções no painel. Excluir o projeto inteiro apagaria Auth, banco, configurações e dados; isso **não** atende ao objetivo de simplificar a interface.

O escopo enxuto é manter um único projeto e **não criar recursos** nos serviços sem uso. A auditoria encontrou **zero buckets de Storage** e **zero Edge Functions**. Nenhuma tabela existente foi classificada como descartável: as cinco tabelas de aplicação têm uma função no fluxo atual. Nenhuma exclusão foi executada.

| Área do Dashboard | Uso no Mente Viva | Quando abrir |
| --- | --- | --- |
| **Authentication → Users** | Contas, confirmação e provedor de cada usuário | Verificar cadastros e problemas de login |
| **Authentication → Sign In / Providers** | E-mail ativo; Google e Apple aguardam credenciais | Configurar login social |
| **Authentication → URL Configuration** | URL do Pages e retornos de autenticação | Ajustar redirects web ou futuros builds nativos |
| **Database → Table Editor / Policies** | Cinco tabelas de aplicação e suas regras de acesso | Inspeção administrativa, sem editar dados pessoais manualmente |
| **SQL Editor / migrations** | Evolução controlada do esquema | Aplicar e revisar mudanças do banco |
| **Project Settings → API Keys** | URL e chave publicável do cliente | Configuração de um novo ambiente |
| **Advisors / Logs** | Auditoria e diagnóstico | Revisões periódicas ou falhas |
| **Storage, Edge Functions, Realtime, Vectors, Cron, Queues, OAuth Server, SAML, Phone, Web3** | Nenhum recurso necessário nesta versão | Não exigem configuração agora; permanecem visíveis no Dashboard |

## 2. Arquitetura de conexão

- **Cliente:** Flutter Web publicado no GitHub Pages; o código também contém configuração de callback para Android/iOS.
- **Servidor:** `https://hdgxxdaedzidkpfmsvra.supabase.co`, projeto Supabase ativo na região `us-east-1`.
- **Credencial no app:** somente a *publishable key*. Nunca inserir `service_role` ou outra chave secreta no Flutter, GitHub Pages ou repositório.
- **Serviços usados:** Supabase Auth, Postgres e Data API. O app consulta tabelas protegidas por RLS e chama três funções para vínculo e perfil.
- **Modos sem conta:** `guest` inicia vazio; `preview` carrega exemplos rotulados. Ambos ficam apenas na memória e não chamam o banco.
- **Modo com conta:** carrega o registro da Pessoa Assistida e sincroniza alterações. O cuidador só carrega esse registro após aceitar um convite.

## 3. Autenticação e perfis

1. **E-mail e senha:** o cadastro informa o perfil escolhido, exige confirmação de e-mail conforme a configuração atual do Supabase e cria `auth.users` + `public.profiles`. O gatilho cria também `app_records` se a conta for da Pessoa Assistida.
2. **Google e Apple:** os botões e o retorno OAuth estão implementados no cliente. **Os dois provedores estão desativados e sem Client ID/segredo no Supabase**, portanto ainda não é possível concluir um login real por eles. O app informa essa indisponibilidade ao tocar no botão.
3. **Primeiro acesso social:** depois de autenticar, a pessoa escolhe uma vez entre Pessoa Assistida e Cuidador. A função `complete_profile_role` grava o perfil somente se ainda estiver vazio; uma conta já classificada não pode trocar de perfil pela interface.
4. **Fonte de autorização:** as políticas de dados verificam `auth.uid()`, `profiles.role` e `care_links`. O metadado de usuário `display_role` é usado no cadastro inicial, mas **não** decide acesso nas políticas RLS.
5. **Retorno web:** `Site URL` e redirect permitido estão em `https://aislannnn.github.io/mente-viva-v2/`. O index do Pages preserva parâmetros e fragmento do callback ao encaminhar para a versão publicada.
6. **Builds nativos:** o código prevê `menteviva://login-callback/`, mas essa URL ainda precisaria entrar na lista de redirects do Supabase antes de testar OAuth em Android/iOS. O app nativo não foi validado com provedor social.

O callback a cadastrar nos consoles do Google e da Apple é `https://hdgxxdaedzidkpfmsvra.supabase.co/auth/v1/callback`. As credenciais de cada provedor pertencem ao painel do Supabase e aos respectivos consoles, nunca ao repositório.

## 4. Dados existentes

`auth.users` é gerenciada pelo Supabase Auth. As tabelas abaixo são do Mente Viva; os números são apenas o retrato de 05/11/2026 e mudarão com o uso.

| Tabela | Conteúdo e regra principal | Linhas observadas |
| --- | --- | ---: |
| `public.profiles` | Uma linha por conta; papel `assistida` ou `cuidador`. Cada conta lê apenas o próprio perfil. | 1 |
| `public.care_links` | Liga um cuidador a uma Pessoa Assistida. Um cuidador pode ter um vínculo; uma Pessoa Assistida pode ter vários cuidadores. Apenas participantes leem o vínculo. | 0 |
| `app_private.care_invites` | Guarda hash do código, validade e resgate. Fica em esquema privado, sem leitura direta pelo cliente. | 0 |
| `public.app_records` | Um documento JSON por Pessoa Assistida; a própria pessoa e cuidadores vinculados podem ler/editar. Usa `version` para detectar edição concorrente. | 1 |
| `public.word_bank` | Dica, resposta e indicador `active`; contas autenticadas leem palavras ativas. Não há edição pelo cliente. | 18 |

Todas essas tabelas têm RLS ligado. `care_invites` deliberadamente não tem política de acesso direto: somente as funções controladas lidam com códigos. `profiles`, `care_links` e `word_bank` são somente leitura para o aplicativo; `app_records` aceita criação pela Pessoa Assistida e atualização pelo proprietário ou cuidador vinculado. Não há política de exclusão direta de registros pelo cliente.

### Documento `app_records.data`

Atualmente reúne `preferences`, `reminders`, `appointments`, `people`, `sleep`, `forgetfulness`, `visits` e `game_stats`. Isso evita muitas tabelas para a prova de conceito, mas implica salvar um documento inteiro por alteração. `version` impede sobrescrever silenciosamente uma edição feita em outro aparelho; em conflito o app pede para recarregar. Preferências de aparência hoje também ficam nesse documento compartilhado e merecem separação por usuário se cada cuidador precisar das próprias preferências.

O **álbum atual registra pessoas, relação e descrição com ícones**. Ainda não há upload de fotografias nem bucket de Storage. Se fotos reais forem acrescentadas, o desenho deverá prever bucket privado, autorização por vínculo e regras de download antes de criar o recurso.

### Palavras do jogo

O banco contém 18 palavras. O aplicativo escolhe **três por data local** de forma determinística: a seleção é estável ao longo do mesmo dia e muda no dia seguinte. Não há Cron nem geração automática de palavras novas. Para ampliar o vocabulário, alguém precisará cadastrar e revisar novas entradas em `word_bank` ou construir uma ferramenta administrativa depois.

## 5. Vínculo Pessoa Assistida ↔ Cuidador

1. A Pessoa Assistida autenticada chama `create_care_invite()`.
2. A função invalida convites anteriores ainda abertos dessa pessoa e produz um código aleatório de uso único, válido por **24 horas**. Só o hash é armazenado.
3. O cuidador autenticado informa o código; `redeem_care_invite(code)` confere prazo e resgate, cria `care_links` e marca o convite como usado.
4. Depois do vínculo, RLS permite ao cuidador ler e atualizar `app_records` da Pessoa Assistida associada. Sem vínculo, não há acesso aos dados dela.

Os endpoints `create_care_invite`, `redeem_care_invite` e `complete_profile_role` são funções `SECURITY DEFINER` expostas apenas a contas autenticadas e validam `auth.uid()` internamente. Esse desenho exige revisão de segurança sempre que as funções forem alteradas.

## 6. Segurança e verificações pendentes

| Item | Estado atual / ação prevista |
| --- | --- |
| RLS nas cinco tabelas | Ativo; políticas de proprietário e vínculo verificadas no esquema. Falta teste ponta a ponta com duas contas reais para confirmar isolamento. |
| Chaves | Chave publicável no build web; nenhuma chave secreta deve ir ao cliente. |
| Google e Apple | Criar credenciais nos consoles externos, habilitar provedores no Supabase e testar cadastro/retorno/sessão. |
| Redirect nativo | Adicionar e testar a URL do aplicativo antes de distribuir Android/iOS. |
| Conselheiro de segurança | Aponta as três funções `SECURITY DEFINER` acessíveis a autenticados (uso deliberado), `care_invites` sem política direta (deliberado) e proteção contra senhas vazadas desativada (avaliar ativação no painel). |
| Privacidade | Exportação/exclusão de dados, retenção, consentimento, backups e tratamento de fotografias/possíveis dados de saúde ainda precisam de decisão antes de uso real com pessoas. |
| Fotos e notificações | Não implementadas no Supabase. Os lembretes atuais são dados de rotina no app; não há push nem bucket de imagens. |
| Histórico de migrações | O servidor registra `20261105201031_initial_app_data_and_daily_words` e `20261105204315_complete_oauth_profile_role`; os arquivos locais usam os mesmos prefixos. |

## 7. Critério de suficiência para esta fase

Não criar mais tabelas ou serviços apenas para reduzir a sensação de complexidade do Dashboard. A fase atual precisa de **Auth + cinco tabelas + RLS + três funções**. O restante do painel pode continuar vazio. O próximo passo funcional do Supabase é configurar os provedores sociais e validar com duas contas de teste, uma de cada perfil, incluindo o convite e o isolamento de dados.

## Referências

- [Código e migrações do Mente Viva](../supabase/migrations/)
- [Supabase: serviços incluídos em cada projeto](https://supabase.com/docs/guides/getting-started/features)
- [Supabase: proteção da Data API com grants e RLS](https://supabase.com/docs/guides/api/securing-your-api)
- [Supabase: login com Google](https://supabase.com/docs/guides/auth/social-sign-in/auth-google)
- [Supabase: login com Apple](https://supabase.com/docs/guides/auth/social-sign-in/auth-apple)
- [Supabase: URLs de redirecionamento](https://supabase.com/docs/guides/auth/redirect-urls)
- [Supabase: consequências de excluir um projeto](https://supabase.com/docs/guides/platform/delete-project)
