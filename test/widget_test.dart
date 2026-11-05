import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mente_viva/main.dart';

void main() {
  testWidgets('Mente Viva app starts on the loading screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Mente Viva'), findsOneWidget);
    expect(find.text('CARREGANDO...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Quem está usando o aplicativo?'), findsOneWidget);

    await tester.tap(find.text('Pessoa Assistida'));
    await tester.pumpAndSettle();
    expect(find.text('Início'), findsWidgets);
    expect(find.text('Lembretes'), findsWidgets);
  });

  testWidgets('Cuidador pode abrir a área de lembretes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cuidador'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lembretes').last);
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('As quatro áreas e configurações permanecem acessíveis', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pessoa Assistida'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Jogos').last);
    await tester.pumpAndSettle();
    expect(find.text('Jogos interativos'), findsOneWidget);

    await tester.tap(find.text('Álbum').last);
    await tester.pumpAndSettle();
    expect(find.text('Álbum de memórias'), findsOneWidget);

    await tester.tap(find.text('Config.'));
    await tester.pumpAndSettle();
    expect(find.text('Configurações'), findsOneWidget);
  });

  testWidgets('O painel e as listas cabem em uma tela de celular', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    final profileBackground = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).gradient != null,
    );
    expect(tester.getSize(profileBackground.first).height, 844);
    await tester.tap(find.text('Pessoa Assistida'));
    await tester.pumpAndSettle();
    expect(find.text('Progresso de hoje'), findsOneWidget);

    await tester.tap(find.text('Jogos').last);
    await tester.pumpAndSettle();
    expect(find.text('Sequência de cores'), findsOneWidget);

    await tester.tap(find.text('Álbum').last);
    await tester.pumpAndSettle();
    expect(find.text('Álbum de memórias'), findsOneWidget);
  });
}
