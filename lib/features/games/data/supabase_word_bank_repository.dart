import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/daily_words.dart';

class SupabaseWordBankRepository implements WordBankRepository {
  const SupabaseWordBankRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<List<WordEntry>> activeWords() async {
    final rows = await _client
        .from('word_bank')
        .select('id, hint, answer')
        .order('id');
    return [
      for (final row in rows)
        WordEntry(
          id: (row['id'] as num).toInt(),
          hint: row['hint'] as String,
          answer: row['answer'] as String,
        ),
    ];
  }
}
