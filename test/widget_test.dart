import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mente_viva/main.dart';
import 'package:mente_viva/core/app_state.dart';

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
    expect(find.text('Acesso de Pessoa Assistida'), findsOneWidget);
    expect(find.text('Continuar com Google'), findsOneWidget);
    expect(find.text('Continuar com Apple'), findsOneWidget);
    expect(find.text('Continuar com e-mail'), findsOneWidget);
    expect(find.text('Hoje'), findsNothing);

    await tester.tap(find.text('Continuar com Google'));
    await tester.pumpAndSettle();
    expect(find.text('Acesso com Google em preparação'), findsOneWidget);
    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entrar sem conta (demonstração)'));
    await tester.pumpAndSettle();
    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Já fiz'), findsOneWidget);
    expect(find.text('Ver todos os lembretes'), findsOneWidget);
    expect(find.text('Registrar horas de sono'), findsNothing);
    expect(find.byTooltip('Registrar visita'), findsNothing);

    final pendingBefore = lembretes.value
        .where((item) => !item.concluido)
        .length;
    await tester.tap(find.text('Já fiz'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      lembretes.value.where((item) => !item.concluido).length,
      pendingBefore - 1,
    );
    await tester.tap(find.text('Desfazer'));
    await tester.pump();
    expect(
      lembretes.value.where((item) => !item.concluido).length,
      pendingBefore,
    );
  });

  testWidgets('Cuidador pode abrir a área de lembretes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cuidador'));
    await tester.pumpAndSettle();
    expect(find.text('Acesso de Cuidador'), findsOneWidget);
    await tester.tap(find.text('Entrar sem conta (demonstração)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lembretes').last);
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Opções de acesso são alcançáveis em celular compacto', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cuidador'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cuidador'));
    await tester.pumpAndSettle();

    expect(find.text('Entrar sem conta (demonstração)'), findsOneWidget);
    await tester.ensureVisible(find.text('Continuar com e-mail'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar com e-mail'));
    await tester.pumpAndSettle();
    expect(find.text('Acesso com e-mail em preparação'), findsOneWidget);
  });

  testWidgets(
    'Pessoa assistida acessa lembretes e configurações com quatro abas',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pessoa Assistida'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entrar sem conta (demonstração)'));
      await tester.pumpAndSettle();

      expect(find.text('Hoje'), findsOneWidget);
      expect(find.text('Agora'), findsOneWidget);
      expect(find.text('Config.'), findsNothing);
      await tester.tap(find.text('Lembretes').last);
      await tester.pumpAndSettle();
      expect(find.text('Pendentes'), findsOneWidget);
      expect(find.text('Lembretes'), findsWidgets);

      await tester.tap(find.text('Jogos').last);
      await tester.pumpAndSettle();
      expect(find.text('Jogos interativos'), findsOneWidget);

      await tester.tap(find.text('Álbum').last);
      await tester.pumpAndSettle();
      expect(find.text('Álbum de memórias'), findsOneWidget);

      await tester.tap(find.byTooltip('Configurações'));
      await tester.pumpAndSettle();
      expect(find.text('Configurações'), findsOneWidget);
    },
  );

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
    await tester.tap(find.text('Entrar sem conta (demonstração)'));
    await tester.pumpAndSettle();
    expect(find.text('Seu dia, no seu ritmo.'), findsOneWidget);
    expect(find.text('Progresso de hoje'), findsNothing);

    await tester.tap(find.text('Jogos').last);
    await tester.pumpAndSettle();
    expect(find.text('Sequência de cores'), findsOneWidget);

    await tester.tap(find.text('Álbum').last);
    await tester.pumpAndSettle();
    expect(find.text('Álbum de memórias'), findsOneWidget);
  });

  testWidgets('Pessoa assistida usa a navegação com texto ampliado', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() => escalaFonte.value = 1.0);

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pessoa Assistida'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar sem conta (demonstração)'));
    await tester.pumpAndSettle();

    escalaFonte.value = 2.0;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Lembretes').last);
    await tester.pumpAndSettle();
    expect(find.text('Lembretes'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cuidador vê o painel de registros em celular compacto', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() => escalaFonte.value = 1.0);

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cuidador'));
    await tester.tap(find.text('Cuidador'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar sem conta (demonstração)'));
    await tester.pumpAndSettle();

    expect(find.text('Acompanhamento'), findsOneWidget);
    expect(find.text('Concluídos'), findsOneWidget);
    escalaFonte.value = 1.5;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('Sono registrado'), 200);
    expect(find.text('Sono registrado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

