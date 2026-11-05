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

## Acesso de demonstração

`features/auth/domain/access_role.dart` define os dois perfis sem depender de Flutter. A apresentação separa a escolha de perfil da tela de acesso. Os botões Google, Apple e e-mail apenas explicam a futura integração; não solicitam credenciais, não conectam contas e não concedem permissões reais. “Entrar sem conta (demonstração)” usa o perfil escolhido no estado temporário existente. O controle de acesso real dependerá da futura integração com Supabase, incluindo autorização do lado do serviço.
