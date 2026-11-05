abstract interface class GameCompletionRepository {
  void recordCompletion(String title, DateTime completedAt, Duration elapsed);
}

class CompleteGame {
  const CompleteGame(this.repository);
  final GameCompletionRepository repository;

  void call(String title, Duration elapsed) =>
      repository.recordCompletion(title, DateTime.now(), elapsed);
}
