class GameStat {
  final String title;
  final int completions;
  final int minutesPlayed;
  final DateTime? lastCompletedAt;

  const GameStat({
    required this.title,
    this.completions = 0,
    this.minutesPlayed = 0,
    this.lastCompletedAt,
  });
}
