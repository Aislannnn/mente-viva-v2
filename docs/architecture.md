# Arquitetura

O código novo segue a direção de dependências da Clean Architecture: apresentação → domínio ← dados. As regras dos jogos e os modelos de rotina são Dart puro e não importam Flutter. `test/architecture_test.dart` protege essa fronteira.

## Jogos

| Camada | Responsabilidade |
| --- | --- |
| `features/games/domain/` | Regras de sequência de cores e palavras, resultado e contrato do repositório |
| `features/games/data/` | Adaptador e estatísticas em memória |
| `features/games/presentation/` | Catálogo e telas de toque para celular |
| `app/game_dependencies.dart` | Montagem do caso de uso com o adaptador |

Uma conclusão só é registrada após as três rodadas ou palavras. Sair antes não soma uma partida. O tempo registrado é o tempo transcorrido, sem presumir a duração anunciada no catálogo.

## Rotina e pessoas

`features/home/domain/entities.dart` reúne entidades sem classes de interface. `features/home/presentation.dart` e seus `parts/` apresentam rotina, lembretes, álbum, visitas, formulários e configurações. As propriedades visuais de ícones e cores são convertidas na apresentação.

`core/app_state.dart` ainda usa `ValueNotifier` como estado global da interface. As listas começam vazias. Em uma conta autenticada, `app/data_session.dart` carrega e salva o estado por meio de `WorkspaceRepository`, implementado pelo adaptador Supabase na camada de dados. O banco mantém um documento JSON por Pessoa Assistida com versão para evitar sobrescrever alterações feitas em outro aparelho. Se houver conflito ou falha de rede, o app avisa que a mudança ainda não foi salva. No acesso sem conta e na prévia simulada, nenhuma operação de banco é feita. Essa área ainda precisa migrar suas ações de tela para casos de uso próprios. Portanto, **a migração para Clean Architecture ainda não está completa em rotina, álbum e configurações**.

Para contas autenticadas, a sessão acompanha atualizações de `app_records` pelo Supabase Realtime e busca novamente o documento sob RLS. Uma conferência periódica e outra ao retomar o app cobrem quedas de conexão e períodos em segundo plano. Enquanto uma edição local está pendente, a sessão não substitui a tela com dados remotos; o salvamento resolve versões diferentes antes de aplicar alterações.

## Palavras do dia

O jogo Complete a palavra usa um catálogo de 18 palavras do banco para contas autenticadas. O domínio seleciona 3 palavras por data local: o conjunto permanece igual no mesmo dia e muda no dia seguinte. O acesso sem conta e a prévia usam três palavras locais e não fazem consultas. Se o banco não responder em uma conta, a tela mostra erro e permite tentar novamente.

O workflow executa testes, análise estática e build web. Os testes de jogos cobrem regras, partidas completas e largura de celular.

## Acesso e autenticação

`features/auth/domain/` define os perfis e o contrato de autenticação sem depender de Flutter. `features/auth/data/supabase_auth_repository.dart` adapta o Supabase Auth para esse contrato. `app/auth_dependencies.dart` inicializa o cliente somente quando a opção de autenticação, a URL e a chave publicável forem fornecidas. A apresentação separa escolha de perfil, acesso por e-mail, entrada sem conta e prévia simulada.

O cadastro envia `display_role` como metadado editável do usuário para selecionar a interface. Um gatilho grava o perfil uma vez no servidor; as políticas de dados não consultam o metadado editável. O vínculo entre cuidador e Pessoa Assistida é feito por convite de uso único, com validade de 24 horas. O banco protege perfis, vínculos, registros e palavras com RLS; funções de convite validam o usuário autenticado. O cliente já inicia OAuth com Google e Apple, mas os provedores estão desativados no Supabase até receberem credenciais. O esquema está em `supabase/migrations/`, e seu estado está detalhado em [supabase-spec.md](supabase-spec.md).
