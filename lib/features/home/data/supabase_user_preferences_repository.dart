import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/user_preferences.dart';

class SupabaseUserPreferencesRepository implements UserPreferencesRepository {
  const SupabaseUserPreferencesRepository(this._client);

  final SupabaseClient _client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null)
      throw StateError('Entre com sua conta para salvar as preferências.');
    return id;
  }

  @override
  Future<UserPreferences> load() async {
    final id = _userId;
    final row = await _client
        .from('user_preferences')
        .select('dark, font_scale, font_family')
        .eq('user_id', id)
        .maybeSingle();
    if (row == null) {
      final created = await _client
          .from('user_preferences')
          .upsert({'user_id': id}, onConflict: 'user_id')
          .select('dark, font_scale, font_family')
          .single();
      return _read(created);
    }
    return _read(row);
  }

  UserPreferences _read(Map<String, dynamic> row) => UserPreferences(
    dark: row['dark'] as bool? ?? false,
    fontScale: (row['font_scale'] as num? ?? 1).toDouble(),
    fontFamily: row['font_family'] as String? ?? 'Padrão',
  );

  @override
  Future<void> save(UserPreferences preferences) async {
    final scale = ((preferences.fontScale * 10).round() / 10).clamp(0.8, 1.5);
    await _client.from('user_preferences').upsert({
      'user_id': _userId,
      'dark': preferences.dark,
      'font_scale': scale,
      'font_family': preferences.fontFamily,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }
}
