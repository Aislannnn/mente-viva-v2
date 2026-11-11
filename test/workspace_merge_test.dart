import 'package:flutter_test/flutter_test.dart';
import 'package:mente_viva/features/home/domain/workspace_merge.dart';

void main() {
  test('keeps a new reminder when another device changes preferences', () {
    final merged = mergeWorkspaceChanges(
      baseRaw: const {},
      baseLocal: const {
        'preferences': {'dark': false},
        'reminders': <Map<String, String>>[],
      },
      local: const {
        'preferences': {'dark': false},
        'reminders': [
          {'title': 'Beber água'},
        ],
      },
      remote: const {
        'preferences': {'dark': true},
        'reminders': <Map<String, String>>[],
      },
    );

    expect(merged?['preferences'], {'dark': true});
    expect(merged?['reminders'], [
      {'title': 'Beber água'},
    ]);
  });

  test('requires review when both devices change reminders', () {
    final merged = mergeWorkspaceChanges(
      baseRaw: const {'reminders': []},
      baseLocal: const {'reminders': []},
      local: const {
        'reminders': [
          {'title': 'Beber água'},
        ],
      },
      remote: const {
        'reminders': [
          {'title': 'Caminhar'},
        ],
      },
    );

    expect(merged, isNull);
  });
}
