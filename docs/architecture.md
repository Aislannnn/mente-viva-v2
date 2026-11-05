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

`core/app_state.dart` ainda é um estado global de demonstração com `ValueNotifier`, dados iniciais e ações de tela. Essa área é legada e ainda precisa migrar suas operações para casos de uso e repositórios próprios. Portanto, **a migração para Clean Architecture ainda não está completa em rotina, álbum e configurações**. A versão atual não tem persistência nem sincronização entre dispositivos.

O workflow executa testes, análise estática e build web. Os testes de jogos cobrem regras, partidas completas e largura de celular.

## Acesso e autenticação

`features/auth/domain/` define os perfis e o contrato de autenticação sem depender de Flutter. `features/auth/data/supabase_auth_repository.dart` adapta o Supabase Auth para esse contrato. `app/auth_dependencies.dart` inicializa o cliente somente quando URL e chave publicável forem fornecidas. A apresentação separa escolha de perfil, acesso por e-mail e demonstração.

O cadastro envia `display_role` como metadado editável do usuário. Ele seleciona a interface e impede entrada acidental no perfil errado, mas **não autoriza acesso a dados**. Antes de persistir informações de saúde e rotina, o servidor deverá manter os vínculos e papéis confiáveis e aplicar políticas RLS. Nesta etapa, nenhuma tabela de dados foi criada. Google e Apple continuam como prévia; o modo demonstração continua disponível e encerra eventual sessão autenticada.
