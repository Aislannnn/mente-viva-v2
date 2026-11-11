import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mente_viva/app/data_session.dart';
import 'package:mente_viva/core/app_state.dart';

void main() {
  test('completed reminder becomes pending on the next day', () {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final today = DateTime.now();
    lembretes.value = [
      Lembrete(
        titulo: 'Ontem',
        descricao: '',
        horario: '09:00',
        iconCodePoint: Icons.alarm.codePoint,
        concluido: true,
        concluidoEm: yesterday,
      ),
      Lembrete(
        titulo: 'Hoje',
        descricao: '',
        horario: '10:00',
        iconCodePoint: Icons.alarm.codePoint,
        concluido: true,
        concluidoEm: today,
      ),
    ];

    appDataSession.refreshDailyCompletions();

    expect(lembretes.value.first.concluido, isFalse);
    expect(lembretes.value.first.concluidoEm, isNull);
    expect(lembretes.value.last.concluido, isTrue);
    expect(lembretes.value.last.concluidoEm, today);
    lembretes.value = <Lembrete>[];
  });
}
