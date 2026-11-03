# Arquitetura

Esta versão conserva os fluxos do projeto inicial e separa a interface extensa em arquivos menores. Os arquivos em `lib/features/home/parts/` usam a diretiva `part of` para compartilhar os componentes privados da mesma biblioteca Dart. Assim, a divisão de código não muda a navegação nem o estado do aplicativo.

| Área | Arquivo |
| --- | --- |
| Estrutura e navegação principal | `main_scaffold.dart`, `bottom_nav_item.dart` |
| Painel inicial | `home_dashboard.dart`, `dashboard_cards.dart` |
| Jogos | `game_views.dart` |
| Lembretes | `reminder_views.dart` |
| Álbum e pessoas | `album_views.dart` |
| Registros de saúde e visitas | `health_forms.dart` |
| Configurações | `settings_sheet.dart` |

`app_state.dart` reúne os `ValueNotifier` e os dados de demonstração. `models.dart` contém os tipos usados pelo estado. Ainda não há armazenamento persistente ou backend; criar uma camada de repositório é o próximo passo caso esses dados devam sobreviver ao encerramento do app.

Os testes cobrem a abertura, a seleção da pessoa assistida e o acesso do cuidador aos lembretes. O workflow também executa a análise estática e o build web.
