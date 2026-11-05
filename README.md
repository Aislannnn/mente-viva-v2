# Mente Viva

Aplicativo Flutter para acompanhar rotina, lembretes, jogos e memórias. Este repositório é uma versão independente e reorganizada do [projeto inicial](https://github.com/Aislannnn/flutter_application_PI2026).

## Executar

Requer Flutter 3.47.2 ou versão compatível com Dart 3.13 ou superior.

```sh
flutter pub get
flutter run
```

Para habilitar o acesso com e-mail e senha, crie um projeto Supabase e execute com as opções públicas do projeto:

```sh
flutter run --dart-define=ENABLE_SUPABASE_AUTH=true --dart-define=SUPABASE_URL=https://hdgxxdaedzidkpfmsvra.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=SUA_CHAVE_PUBLICA
```

Sem essas opções, o aplicativo permite entrar sem conta e usar a prévia com dados simulados. Esses dois modos não acessam o banco. A chave publicável pode ir para o aplicativo; nunca use `service_role` ou outra chave secreta nele. Os botões de Google e Apple já iniciam OAuth, mas os provedores ainda precisam ser configurados no Supabase para concluir o acesso.

Para conferir a versão web:

```sh
flutter test
flutter analyze
flutter build web --release --base-href /mente-viva-v2/
```

## Organização

- `lib/features/home/domain/entities.dart`: modelos de rotina e pessoas sem Flutter.
- `lib/core/app_state.dart`: estado reativo da interface, carregado e sincronizado pela sessão quando há conta.
- `lib/core/design_tokens.dart` e `theme.dart`: paleta e tema.
- `lib/features/auth/`: seleção de perfil, login por e-mail e demonstração separados para Pessoa Assistida e Cuidador.
- `lib/features/home/parts/`: navegação, painel, lembretes, álbum, formulários e configurações.
- `lib/features/games/domain/`: regras puras dos jogos e caso de uso de conclusão.
- `lib/features/games/data/`: repositório e estatísticas em memória.
- `lib/features/games/presentation/`: catálogo e telas jogáveis para celular.
- `lib/app/`: montagem das dependências.
- `test/`: testes de regras, jogos completos, navegação e limites de arquitetura.

Com o Supabase configurado, e-mail e senha autenticam contas e exigem confirmação do e-mail quando habilitada no projeto. A Pessoa Assistida pode gerar um convite de 24 horas e uso único; o cuidador digita o código para ver e editar os mesmos registros. A conta sincroniza lembretes, compromissos, pessoas, sono, esquecimentos, visitas e estatísticas dos jogos. O jogo de palavras recebe 3 palavras do banco a cada dia. No acesso sem conta, os dados ficam somente na memória; a prévia exibe exemplos identificados como simulação. A estrutura e as decisões estão documentadas em [docs/architecture.md](docs/architecture.md) e [docs/design.md](docs/design.md).

## Publicação web

O workflow em `.github/workflows/deploy-pages.yml` testa, analisa, compila e publica no GitHub Pages a cada push em `main`. O Pages deve estar configurado com a origem **GitHub Actions**.

O Pages compila com a URL e a chave publicável do projeto Supabase `mente-viva-v2`. No Supabase Auth, a URL do site e o redirecionamento permitido são `https://aislannnn.github.io/mente-viva-v2/`. As migrações estão em `supabase/migrations/`. O escopo e o estado do banco estão em [docs/supabase-spec.md](docs/supabase-spec.md).
