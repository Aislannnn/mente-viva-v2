import 'package:flutter/foundation.dart';
import '../domain/game_stat.dart';

/// Estado de demonstração. Pode ser trocado por armazenamento persistente.
final ValueNotifier<List<GameStat>> gameStats = ValueNotifier([
  const GameStat(title: 'Sequência de cores'),
  const GameStat(title: 'Complete a palavra'),
  const GameStat(title: 'Encontre o par'),
  const GameStat(title: 'Calendário da memória'),
  const GameStat(title: 'Respiração guiada'),
  const GameStat(title: 'Leitura em voz alta'),
]);
