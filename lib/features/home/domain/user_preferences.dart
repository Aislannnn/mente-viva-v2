class UserPreferences {
  const UserPreferences({
    this.dark = false,
    this.fontScale = 1.0,
    this.fontFamily = 'Padrão',
  });

  final bool dark;
  final double fontScale;
  final String fontFamily;
}

abstract class UserPreferencesRepository {
  Future<UserPreferences> load();
  Future<void> save(UserPreferences preferences);
}
