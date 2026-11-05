import '../features/games/data/game_stats_repository.dart';
import '../features/games/domain/game_completion.dart';

/// Montagem de dependências feita fora das telas.
final CompleteGame completeGame = CompleteGame(GameStatsRepository());
