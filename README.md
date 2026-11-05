# Mente Viva

Aplicativo Flutter para acompanhar rotina, lembretes, jogos e memórias. Este repositório é uma versão independente e reorganizada do [projeto inicial](https://github.com/Aislannnn/flutter_application_PI2026).

## Executar

Requer Flutter 3.47.2 ou versão compatível com Dart 3.12 ou superior.

```sh
flutter pub get
flutter run
```

Para habilitar o acesso com e-mail e senha, crie um projeto Supabase e execute com as opções públicas do projeto:

```sh
flutter run --dart-define=SUPABASE_URL=https://SEU-PROJETO.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=SUA_CHAVE_PUBLICA
```

Sem essas opções, o aplicativo mantém o modo demonstração. A chave publicável pode ir para o aplicativo; nunca use `service_role` ou outra chave secreta nele. Google e Apple continuam como prévia até que os provedores sejam configurados. O tipo de perfil gravado no cadastro serve somente para a interface. Antes de persistir dados de saúde e rotina, o papel e os vínculos entre cuidador e pessoa assistida precisarão de autorização no servidor e políticas RLS.

Para conferir a versão web:

```sh
flutter test
flutter analyze
flutter build web --release --base-href /mente-viva-v2/
```

## Organização

- `lib/features/home/domain/entities.dart`: modelos de rotina e pessoas sem Flutter.
- `lib/core/app_state.dart`: estado de demonstração da interface antiga, ainda em memória.
- `lib/core/design_tokens.dart` e `theme.dart`: paleta e tema.
- `lib/features/auth/`: seleção de perfil e prévia de acesso separada para Pessoa Assistida e Cuidador.
- `lib/features/home/parts/`: navegação, painel, lembretes, álbum, formulários e configurações.
- `lib/features/games/domain/`: regras puras dos jogos e caso de uso de conclusão.
- `lib/features/games/data/`: repositório e estatísticas em memória.
- `lib/features/games/presentation/`: catálogo e telas jogáveis para celular.
- `lib/app/`: montagem das dependências.
- `test/`: testes de regras, jogos completos, navegação e limites de arquitetura.

Com o Supabase configurado, e-mail e senha autenticam contas e exigem confirmação do e-mail quando habilitada no projeto. Google e Apple são opções de interface em preparação. O botão de demonstração abre o perfil escolhido. Os dados atuais são mantidos em memória e reiniciam quando o aplicativo fecha. A estrutura e as decisões de design estão documentadas em [docs/architecture.md](docs/architecture.md) e [docs/design.md](docs/design.md).

## Publicação web

O workflow em `.github/workflows/deploy-pages.yml` testa, analisa, compila e publica no GitHub Pages a cada push em `main`. O Pages deve estar configurado com a origem **GitHub Actions**.

Para habilitar o login no Pages, defina as variáveis de repositório `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY` no GitHub. No Supabase Auth, configure a URL do site como `https://aislannnn.github.io/mente-viva-v2/` e inclua essa URL nos redirecionamentos permitidos.
