import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_state.dart';
import '../features/games/data/game_stats_store.dart';
import '../features/games/domain/game_stat.dart';
import '../features/home/data/supabase_workspace_repository.dart';
import '../features/home/domain/workspace_repository.dart';
import 'auth_dependencies.dart';
import 'reminder_notifications.dart';

enum SessionMode { guest, preview, account }

enum SessionPhase { loading, ready, needsLink, error }

final AppDataSession appDataSession = AppDataSession();

class AppDataSession {
  SessionMode mode = SessionMode.guest;
  final ValueNotifier<SessionPhase> phase = ValueNotifier(SessionPhase.loading);
  final ValueNotifier<String?> message = ValueNotifier(null);
  WorkspaceData? _workspace;
  bool _listening = false;
  bool _saving = false;
  bool _pending = false;
  bool needsReload = false;
  int _generation = 0;

  WorkspaceRepository get _repository =>
      SupabaseWorkspaceRepository(Supabase.instance.client);

  bool get isAccount => mode == SessionMode.account && _workspace != null;

  void chooseMode(SessionMode next) {
    mode = next;
    if (next != SessionMode.account) {
      unawaited(reminderNotifications.sync(const [], assistedAccount: false));
    }
  }

  Future<void> start(String role) async {
    final generation = ++_generation;
    unawaited(reminderNotifications.sync(const [], assistedAccount: false));
    _detach();
    _workspace = null;
    _pending = false;
    needsReload = false;
    message.value = null;
    phase.value = SessionPhase.loading;
    _clear();
    if (mode == SessionMode.preview) {
      _loadPreview();
      unawaited(reminderNotifications.sync(const [], assistedAccount: false));
      phase.value = SessionPhase.ready;
      return;
    }
    if (mode == SessionMode.guest) {
      unawaited(reminderNotifications.sync(const [], assistedAccount: false));
      phase.value = SessionPhase.ready;
      return;
    }
    if (!authConfigured || Supabase.instance.client.auth.currentUser == null) {
      phase.value = SessionPhase.error;
      message.value = 'Sua sessão terminou. Entre novamente.';
      return;
    }
    try {
      final workspace = await _repository.load(role);
      if (generation != _generation) return;
      if (workspace == null) {
        phase.value = SessionPhase.needsLink;
        return;
      }
      _workspace = workspace;
      _restore(workspace.data);
      _attach();
      unawaited(
        reminderNotifications.sync(
          lembretes.value,
          assistedAccount: role == 'assistida',
        ),
      );
      phase.value = SessionPhase.ready;
    } catch (_) {
      if (generation != _generation) return;
      message.value = 'Não foi possível carregar seus dados. Tente novamente.';
      phase.value = SessionPhase.error;
    }
  }

  Future<String> createInvite() async {
    if (!isAccount)
      throw StateError('Entre com sua conta para gerar um convite.');
    return _repository.createInvite();
  }

  Future<void> redeemInvite(String code) async {
    if (mode != SessionMode.account) {
      throw StateError('Entre com sua conta para usar um convite.');
    }
    await _repository.redeemInvite(code);
    await start('cuidador');
  }

  Future<List<String>> caregiverIds() async {
    if (!isAccount || mode != SessionMode.account)
      throw StateError('Entre com sua conta.');
    return _repository.caregiverIds();
  }

  Future<void> unlinkCaregiver(String caregiverId) async {
    if (mode != SessionMode.account) throw StateError('Entre com sua conta.');
    await _repository.unlinkCaregiver(caregiverId);
    if (Supabase.instance.client.auth.currentUser?.id == caregiverId) {
      await start('cuidador');
    }
  }

  Future<void> unlinkOwnCaregiver() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) throw StateError('Entre com sua conta.');
    await unlinkCaregiver(uid);
  }

  void refreshDailyCompletions() {
    final today = DateTime.now();
    final expired = lembretes.value.where((item) {
      final at = item.concluidoEm?.toLocal();
      return item.concluido &&
          (at == null ||
              at.year != today.year ||
              at.month != today.month ||
              at.day != today.day);
    }).toList();
    if (expired.isEmpty) return;
    for (final item in expired) {
      item.concluido = false;
      item.concluidoEm = null;
    }
    lembretes.value = List<Lembrete>.from(lembretes.value);
  }

  void retrySave() {
    if (!isAccount || _saving || needsReload) return;
    message.value = null;
    _pending = true;
    unawaited(_saveLoop());
  }

  void _attach() {
    if (_listening) return;
    for (final notifier in _notifiers) {
      notifier.addListener(_changed);
    }
    _listening = true;
  }

  void _detach() {
    if (!_listening) return;
    for (final notifier in _notifiers) {
      notifier.removeListener(_changed);
    }
    _listening = false;
  }

  List<Listenable> get _notifiers => [
    lembretes,
    compromissos,
    pessoas,
    registrosSono,
    esquecimentos,
    visitas,
    gameStats,
    modoEscuro,
    escalaFonte,
    tipoFonte,
  ];

  void _changed() {
    if (!isAccount) return;
    if (needsReload) return;
    unawaited(
      reminderNotifications.sync(
        lembretes.value,
        assistedAccount:
            Supabase.instance.client.auth.currentUser?.id ==
            _workspace?.assistedId,
      ),
    );
    _pending = true;
    unawaited(_saveLoop());
  }

  Future<void> _saveLoop() async {
    if (_saving) return;
    _saving = true;
    final generation = _generation;
    try {
      while (_pending && generation == _generation) {
        _pending = false;
        final current = _workspace;
        if (current == null) return;
        final data = _capture();
        try {
          final version = await _repository.save(current, data);
          if (generation != _generation) return;
          _workspace = WorkspaceData(
            assistedId: current.assistedId,
            version: version,
            data: data,
          );
          message.value = null;
        } on WorkspaceConflict {
          needsReload = true;
          message.value =
              'Os dados mudaram em outro aparelho. Reabra o app antes de editar novamente.';
          _pending = false;
          return;
        } catch (_) {
          message.value = 'Não foi possível salvar. Toque em Tentar novamente.';
          _pending = false;
          return;
        }
      }
    } finally {
      _saving = false;
      if (_pending && isAccount) unawaited(_saveLoop());
    }
  }

  void _clear() {
    lembretes.value = <Lembrete>[];
    compromissos.value = <Compromisso>[];
    pessoas.value = <Pessoa>[];
    registrosSono.value = <RegistroSono>[];
    esquecimentos.value = <EsquecimentoRegistro>[];
    visitas.value = <VisitaRegistro>[];
    modoEscuro.value = false;
    escalaFonte.value = 1.0;
    tipoFonte.value = 'Padrão';
    gameStats.value = [
      for (final stat in gameStats.value) GameStat(title: stat.title),
    ];
  }

  Map<String, dynamic> _capture() => {
    'preferences': {
      'dark': modoEscuro.value,
      'font_scale': escalaFonte.value,
      'font_family': tipoFonte.value,
    },
    'reminders': [
      for (final item in lembretes.value)
        {
          'title': item.titulo,
          'description': item.descricao,
          'time': item.horario,
          'icon': item.iconCodePoint,
          'completed': item.concluido,
          'completed_at': item.concluidoEm?.toUtc().toIso8601String(),
        },
    ],
    'appointments': [
      for (final item in compromissos.value)
        {
          'title': item.titulo,
          'description': item.descricao,
          'time': item.horario,
          'date': item.data.toUtc().toIso8601String(),
          'done': item.realizado,
        },
    ],
    'people': [
      for (final item in pessoas.value)
        {
          'name': item.nome,
          'relation': item.relacao,
          'description': item.descricao,
          'icon': item.iconCodePoint,
          'color': item.colorArgb,
        },
    ],
    'sleep': [
      for (final item in registrosSono.value)
        {'date': item.data.toUtc().toIso8601String(), 'hours': item.horas},
    ],
    'forgetfulness': [
      for (final item in esquecimentos.value)
        {
          'date': item.data.toUtc().toIso8601String(),
          'description': item.descricao,
        },
    ],
    'visits': [
      for (final item in visitas.value)
        {'date': item.data.toUtc().toIso8601String(), 'name': item.nomePessoa},
    ],
    'game_stats': [
      for (final stat in gameStats.value)
        {
          'title': stat.title,
          'completions': stat.completions,
          'minutes': stat.minutesPlayed,
          'last_completed': stat.lastCompletedAt?.toUtc().toIso8601String(),
        },
    ],
  };

  List<Map<String, dynamic>> _rows(Map<String, dynamic> data, String key) =>
      (data[key] as List? ?? const [])
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();

  Lembrete _readReminder(Map<String, dynamic> row) {
    final completedAt = row['completed_at'] == null
        ? null
        : DateTime.tryParse(row['completed_at'] as String)?.toLocal();
    final today = DateTime.now();
    final doneToday =
        (row['completed'] as bool? ?? false) &&
        completedAt != null &&
        completedAt.year == today.year &&
        completedAt.month == today.month &&
        completedAt.day == today.day;
    return Lembrete(
      titulo: row['title'] as String,
      descricao: row['description'] as String,
      horario: row['time'] as String,
      iconCodePoint: (row['icon'] as num).toInt(),
      concluido: doneToday,
      concluidoEm: doneToday ? completedAt : null,
    );
  }

  void _restore(Map<String, dynamic> data) {
    final preferences = Map<String, dynamic>.from(
      data['preferences'] as Map? ?? {},
    );
    modoEscuro.value = preferences['dark'] as bool? ?? false;
    escalaFonte.value = (preferences['font_scale'] as num? ?? 1.0).toDouble();
    tipoFonte.value = preferences['font_family'] as String? ?? 'Padrão';
    lembretes.value = [
      for (final row in _rows(data, 'reminders')) _readReminder(row),
    ];
    compromissos.value = [
      for (final row in _rows(data, 'appointments'))
        Compromisso(
          titulo: row['title'] as String,
          descricao: row['description'] as String,
          horario: row['time'] as String,
          data: DateTime.parse(row['date'] as String).toLocal(),
          realizado: row['done'] as bool? ?? false,
        ),
    ];
    pessoas.value = [
      for (final row in _rows(data, 'people'))
        Pessoa(
          nome: row['name'] as String,
          relacao: row['relation'] as String,
          descricao: row['description'] as String,
          iconCodePoint: (row['icon'] as num).toInt(),
          colorArgb: (row['color'] as num).toInt(),
        ),
    ];
    registrosSono.value = [
      for (final row in _rows(data, 'sleep'))
        RegistroSono(
          data: DateTime.parse(row['date'] as String).toLocal(),
          horas: (row['hours'] as num).toDouble(),
        ),
    ];
    esquecimentos.value = [
      for (final row in _rows(data, 'forgetfulness'))
        EsquecimentoRegistro(
          data: DateTime.parse(row['date'] as String).toLocal(),
          descricao: row['description'] as String,
        ),
    ];
    visitas.value = [
      for (final row in _rows(data, 'visits'))
        VisitaRegistro(
          data: DateTime.parse(row['date'] as String).toLocal(),
          nomePessoa: row['name'] as String,
        ),
    ];
    final savedStats = {
      for (final row in _rows(data, 'game_stats')) row['title'] as String: row,
    };
    gameStats.value = [
      for (final stat in gameStats.value)
        if (savedStats[stat.title] case final row?)
          GameStat(
            title: stat.title,
            completions: (row['completions'] as num? ?? 0).toInt(),
            minutesPlayed: (row['minutes'] as num? ?? 0).toInt(),
            lastCompletedAt: row['last_completed'] == null
                ? null
                : DateTime.parse(row['last_completed'] as String).toLocal(),
          )
        else
          GameStat(title: stat.title),
    ];
  }

  void _loadPreview() {
    final now = DateTime.now();
    lembretes.value = [
      Lembrete(
        titulo: 'Beber água',
        descricao: 'Exemplo para conhecer a tela',
        horario: '10:00',
        iconCodePoint: Icons.local_drink_outlined.codePoint,
      ),
      Lembrete(
        titulo: 'Fazer uma caminhada',
        descricao: 'Exemplo para conhecer a tela',
        horario: '16:00',
        iconCodePoint: Icons.directions_walk_outlined.codePoint,
      ),
    ];
    compromissos.value = [
      Compromisso(
        titulo: 'Consulta de exemplo',
        descricao: 'Compromisso simulado',
        horario: '15:00',
        data: now,
      ),
    ];
    pessoas.value = [
      Pessoa(
        nome: 'Pessoa de exemplo',
        relacao: 'Familiar',
        descricao: 'Este registro é apenas uma simulação.',
        iconCodePoint: Icons.person.codePoint,
        colorArgb: 0xFF4084BE,
      ),
    ];
    registrosSono.value = [
      RegistroSono(data: now.subtract(const Duration(days: 1)), horas: 7),
    ];
    visitas.value = [
      VisitaRegistro(data: now, nomePessoa: 'Visita de exemplo'),
    ];
  }
}
