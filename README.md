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

- `lib/core/models.dart`: modelos de lembretes, pessoas e registros.
- `lib/core/app_state.dart`: dados de demonstração e estado reativo em memória.
- `lib/core/design_tokens.dart` e `theme.dart`: paleta e tema.
- `lib/features/auth/`: abertura e seleção de perfil.
- `lib/features/home/parts/`: navegação, painel, jogos, lembretes, álbum, formulários e configurações.
- `test/`: testes de abertura e navegação dos perfis.

Os dados atuais são mantidos em memória e reiniciam quando o aplicativo fecha. A estrutura e as decisões de design estão documentadas em [docs/architecture.md](docs/architecture.md) e [docs/design.md](docs/design.md).

## Publicação web

O workflow em `.github/workflows/deploy-pages.yml` testa, analisa, compila e publica no GitHub Pages a cada push em `main`. O Pages deve estar configurado com a origem **GitHub Actions**.
