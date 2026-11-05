import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_viva/features/games/presentation/color_sequence_page.dart';
import 'package:mente_viva/features/games/presentation/word_puzzle_page.dart';

void main() {
  testWidgets('sequência de cores termina três rodadas no celular', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var completions = 0;
    await tester.pumpWidget(
      MaterialApp(home: ColorSequencePage(onCompleted: (_) => completions++)),
    );

    for (var round = 0; round < 3; round++) {
      final names = tester
          .widgetList<Chip>(find.byType(Chip))
          .map((chip) => (chip.label as Text).data!)
          .toList();
      await tester.tap(find.text('Já memorizei'));
      await tester.pumpAndSettle();
      for (final name in names) {
        await tester.tap(find.widgetWithText(OutlinedButton, name));
        await tester.pumpAndSettle();
      }
    }

    expect(find.text('Atividade concluída'), findsOneWidget);
    expect(completions, 1);
  });

  testWidgets('complete a palavra registra somente ao concluir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var completions = 0;
    await tester.pumpWidget(
      MaterialApp(home: WordPuzzlePage(onCompleted: (_) => completions++)),
    );
    expect(completions, 0);

    for (final indexes in <List<int>>[
      [2, 0, 1, 3],
      [2, 3, 1, 0],
      [4, 3, 0, 2, 1],
    ]) {
      for (final index in indexes) {
        await tester.tap(find.byType(OutlinedButton).at(index));
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(find.text('Conferir palavra'));
      await tester.tap(find.text('Conferir palavra'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Atividade concluída'), findsOneWidget);
    expect(completions, 1);
  });
}
