# Mente Viva

Aplicativo Flutter para acompanhar rotina, lembretes, jogos e memórias. Este repositório é uma versão independente e reorganizada do [projeto inicial](https://github.com/Aislannnn/flutter_application_PI2026).

## Executar

Requer Flutter 3.47.2 ou versão compatível com Dart 3.12 ou superior.

```sh
flutter pub get
flutter run
```

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

Google, Apple e e-mail são opções de interface em preparação: não autenticam contas. O botão de demonstração abre o perfil escolhido. Os dados atuais são mantidos em memória e reiniciam quando o aplicativo fecha. A estrutura e as decisões de design estão documentadas em [docs/architecture.md](docs/architecture.md) e [docs/design.md](docs/design.md).

## Publicação web

O workflow em `.github/workflows/deploy-pages.yml` testa, analisa, compila e publica no GitHub Pages a cada push em `main`. O Pages deve estar configurado com a origem **GitHub Actions**.
