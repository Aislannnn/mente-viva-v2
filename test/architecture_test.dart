import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('camada de domínio não depende de Flutter nem de outras camadas', () {
    final directories = [
      Directory('lib/features/games/domain'),
      Directory('lib/features/home/domain'),
    ];
    for (final directory in directories) {
      for (final file in directory.listSync().whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;
        final source = file.readAsStringSync();
        expect(source, isNot(contains('package:flutter/')), reason: file.path);
        expect(source, isNot(contains('/data/')), reason: file.path);
        expect(source, isNot(contains('/presentation/')), reason: file.path);
      }
    }
  });
}
