# Interface Mente Viva

A interface toma como referência o [arquivo Mente Viva no Figma](https://www.figma.com/design/3PwBb0qy4xvybbn3QH3ctG/Mente-Viva?node-id=0-1). Foram considerados os exemplos em azul e a paleta azul/ciano/laranja da prancha. As telas roxas e a tela branca foram deixadas de lado, conforme solicitado. Como parte das cores da prancha está em imagens e não em variáveis de design, os códigos abaixo são aproximações visuais editáveis em `lib/core/design_tokens.dart`.

| Uso | Cor |
| --- | --- |
| Azul profundo | `#102D72` |
| Azul principal | `#225AC4` |
| Ciano do gradiente | `#168BC5` |
| Azul dos elementos de apoio | `#4084BE` |
| Verde azulado | `#087E8B` |
| Acento quente | `#E5A044` |
| Fundo claro azulado | `#EDF4FC` |
| Texto principal | `#173054` |
| Fundo escuro | `#0D1A30` |

O protótipo serve como referência de cor, não como molde de composição. A página inicial reúne saudação, data e progresso em um painel diário com indicador circular; os quatro atalhos formam um conjunto compacto. Jogos e Álbum usam listas com elementos gráficos laterais e espaço para leitura. Os cabeçalhos dessas áreas e de Lembretes são tipográficos, com uma marca ciano lateral, sem as antigas faixas em gradiente. A dica dos jogos usa o acento quente da paleta. A navegação inferior mantém as cinco ações e distribui seu espaço de forma responsiva. Em telas largas, o conteúdo fica centralizado até 620 px. A seleção de perfil usa o azul do produto como superfície principal.

Foram preservados os textos, os dados de demonstração, as ações, os dois perfis, a escala de texto, a escolha de fonte e o modo escuro. Os dados ainda são mantidos somente em memória.

As decisões de hierarquia, ritmo e acessibilidade também foram informadas pelas recomendações de [layout da Apple](https://developer.apple.com/design/human-interface-guidelines/layout), pelo reconhecimento de [Gentler Streak nos Apple Design Awards 2024](https://developer.apple.com/design/awards/2024/) e pela pesquisa de [Material Design Expressive](https://design.google/library/expressive-material-design-google-research?pubDate=20250521). Nenhuma tela desses projetos foi reproduzida.
