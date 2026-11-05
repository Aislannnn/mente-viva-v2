import '../domain/game_completion.dart';
import '../domain/game_stat.dart';
import 'game_stats_store.dart';

/// Adaptador temporário para o estado em memória existente.
class GameStatsRepository implements GameCompletionRepository {
  @override
  void recordCompletion(String title, DateTime completedAt, Duration elapsed) {
    final updated = gameStats.value.map((stat) {
      if (stat.title != title) return stat;
      return GameStat(
        title: stat.title,
        completions: stat.completions + 1,
        minutesPlayed: stat.minutesPlayed + elapsed.inMinutes,
        lastCompletedAt: completedAt,
      );
    }).toList();
    gameStats.value = updated;
  }
}
