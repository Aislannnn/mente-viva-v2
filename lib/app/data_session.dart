import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_state.dart';
import '../features/games/data/game_stats_store.dart';
import '../features/games/domain/game_stat.dart';
import '../features/home/data/supabase_workspace_repository.dart';
import '../features/home/data/supabase_user_preferences_repository.dart';
import '../features/home/domain/user_preferences.dart';
import '../features/home/domain/workspace_merge.dart';
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
  final ValueNotifier<String?> preferencesMessage = ValueNotifier(null);
  WorkspaceData? _workspace;
  Map<String, dynamic>? _baselineData;
  RealtimeChannel? _liveChannel;
  Timer? _refreshTimer;
  bool _listening = false;
  bool _refreshing = false;
  bool _saving = false;
  bool _pending = false;
  bool _savingPreferences = false;
  bool _pendingPreferences = false;
  bool _checkingLink = false;
  bool needsReload = false;
  int _generation = 0;

  WorkspaceRepository get _repository =>
      SupabaseWorkspaceRepository(Supabase.instance.client);
  UserPreferencesRepository get _preferencesRepository =>
      SupabaseUserPreferencesRepository(Supabase.instance.client);

  bool get isAccount => mode == SessionMode.account && _workspace != null;

  void chooseMode(SessionMode next) {
    mode = next;
    if (next != SessionMode.account) {
      _stopLiveSync();
      unawaited(reminderNotifications.sync(const [], assistedAccount: false));
    }
  }

  Future<void> start(String role) async {
    final generation = ++_generation;
    unawaited(reminderNotifications.sync(const [], assistedAccount: false));
    _stopLiveSync();
    _detach();
    _workspace = null;
    _baselineData = null;
    _pending = false;
    _savingPreferences = false;
    _pendingPreferences = false;
    needsReload = false;
    message.value = null;
    preferencesMessage.value = null;
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
      final preferences = await _preferencesRepository.load();
      if (generation != _generation) return;
      _workspace = workspace;
      _restore(workspace.data);
      _applyPreferences(preferences);
      _baselineData = _capture();
      _attach();
      unawaited(
        reminderNotifications.sync(
          lembretes.value,
          assistedAccount: role == 'assistida',
        ),
      );
      phase.value = SessionPhase.ready;
      _startLiveSync(workspace);
    } catch (_) {
      if (generation != _generation) return;
      message.value = 'Não foi possível carregar seus dados. Tente novamente.';
      phase.value = SessionPhase.error;
    }
  }

  Future<String> createCaregiverInvite() async {
    if (mode != SessionMode.account ||
        perfilAtivo.value != 'cuidador' ||
        Supabase.instance.client.auth.currentUser == null) {
      throw StateError('Entre como cuidador para gerar um convite.');
    }
    return _repository.createCaregiverInvite();
  }

  Future<void> checkCaregiverLink() async {
    if (_checkingLink ||
        mode != SessionMode.account ||
        phase.value != SessionPhase.needsLink)
      return;
    _checkingLink = true;
    try {
      final workspace = await _repository.load('cuidador');
      if (workspace != null && phase.value == SessionPhase.needsLink) {
        await start('cuidador');
      }
    } catch (_) {
      // A later poll or manual refresh can retry.
    } finally {
      _checkingLink = false;
    }
  }

  Future<void> acceptCaregiverInvite(String code) async {
    if (mode != SessionMode.account || perfilAtivo.value != 'assistida') {
      throw StateError('Entre como Pessoa Assistida para aceitar o convite.');
    }
    await _repository.acceptCaregiverInvite(code);
    await start('assistida');
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

  void _startLiveSync(WorkspaceData workspace) {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => unawaited(refreshFromServer()),
    );
    try {
      final client = Supabase.instance.client;
      final channel = client.channel(
        'workspace-${workspace.assistedId}-$_generation',
      );
      _liveChannel = channel;
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'app_records',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'assisted_id',
              value: workspace.assistedId,
            ),
            select: const ['assisted_id', 'version'],
            callback: (payload) {
              final version = (payload.newRecord['version'] as num?)?.toInt();
              if (version != null && version > (_workspace?.version ?? -1)) {
                unawaited(refreshFromServer());
              }
            },
          )
          .subscribe((status, _) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              unawaited(refreshFromServer());
            }
          });
    } catch (_) {
      final channel = _liveChannel;
      _liveChannel = null;
      if (channel != null) unawaited(_removeChannel(channel));
    }
  }

  void _stopLiveSync() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    final channel = _liveChannel;
    _liveChannel = null;
    if (channel != null) unawaited(_removeChannel(channel));
  }

  Future<void> _removeChannel(RealtimeChannel channel) async {
    try {
      await Supabase.instance.client.removeChannel(channel);
    } catch (_) {
      // An interrupted connection must not block account switching.
    }
  }

  Future<void> refreshFromServer() async {
    if (!isAccount ||
        phase.value != SessionPhase.ready ||
        _refreshing ||
        _saving ||
        _pending ||
        needsReload ||
        message.value != null) {
      return;
    }
    final generation = _generation;
    final current = _workspace!;
    _refreshing = true;
    try {
      final latest = await _repository.load(perfilAtivo.value);
      if (generation != _generation ||
          !isAccount ||
          _saving ||
          _pending ||
          needsReload ||
          message.value != null) {
        return;
      }
      if (latest == null || latest.assistedId != current.assistedId) {
        _stopLiveSync();
        _detach();
        _workspace = null;
        _baselineData = null;
        _clear();
        unawaited(reminderNotifications.sync(const [], assistedAccount: false));
        phase.value = SessionPhase.needsLink;
        return;
      }
      if (latest.version <= (_workspace?.version ?? -1)) return;
      _detach();
      _workspace = latest;
      _restore(latest.data);
      _baselineData = _capture();
      _attach();
      unawaited(
        reminderNotifications.sync(
          lembretes.value,
          assistedAccount:
              Supabase.instance.client.auth.currentUser?.id ==
              latest.assistedId,
        ),
      );
    } catch (_) {
      // Realtime may be temporarily unavailable. The next poll or resume retries.
    } finally {
      _refreshing = false;
    }
  }

  void retrySave() {
    if (!isAccount || _saving || needsReload) return;
    message.value = null;
    _pending = true;
    unawaited(_saveLoop());
  }

  void retryPreferencesSave() {
    if (!isAccount || _savingPreferences) return;
    preferencesMessage.value = null;
    _pendingPreferences = true;
    unawaited(_savePreferencesLoop());
  }

  void _attach() {
    if (_listening) return;
    for (final notifier in _sharedNotifiers) {
      notifier.addListener(_changed);
    }
    for (final notifier in _preferenceNotifiers) {
      notifier.addListener(_preferencesChanged);
    }
    _listening = true;
  }

  void _detach() {
    if (!_listening) return;
    for (final notifier in _sharedNotifiers) {
      notifier.removeListener(_changed);
    }
    for (final notifier in _preferenceNotifiers) {
      notifier.removeListener(_preferencesChanged);
    }
    _listening = false;
  }

  List<Listenable> get _sharedNotifiers => [
    lembretes,
    compromissos,
    pessoas,
    registrosSono,
    esquecimentos,
    visitas,
    gameStats,
  ];

  List<Listenable> get _preferenceNotifiers => [
    modoEscuro,
    escalaFonte,
    tipoFonte,
  ];

  void _preferencesChanged() {
    if (!isAccount) return;
    _pendingPreferences = true;
    unawaited(_savePreferencesLoop());
  }

  UserPreferences _capturePreferences() => UserPreferences(
    dark: modoEscuro.value,
    fontScale: escalaFonte.value,
    fontFamily: tipoFonte.value,
  );

  void _applyPreferences(UserPreferences preferences) {
    modoEscuro.value = preferences.dark;
    escalaFonte.value = preferences.fontScale;
    tipoFonte.value = preferences.fontFamily;
  }

  Future<void> _savePreferencesLoop() async {
    if (_savingPreferences) return;
    _savingPreferences = true;
    final generation = _generation;
    try {
      while (_pendingPreferences && generation == _generation) {
        _pendingPreferences = false;
        try {
          await _preferencesRepository.save(_capturePreferences());
          if (generation != _generation) return;
          preferencesMessage.value = null;
        } catch (_) {
          if (generation != _generation) return;
          preferencesMessage.value =
              'Não foi possível salvar as configurações desta conta. Toque em Tentar novamente.';
          return;
        }
      }
    } finally {
      if (generation == _generation) {
        _savingPreferences = false;
        if (_pendingPreferences && isAccount) {
          unawaited(_savePreferencesLoop());
        }
      }
    }
  }

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
    var conflictRetries = 0;
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
          _baselineData = data;
          conflictRetries = 0;
          message.value = null;
        } on WorkspaceConflict {
          if (++conflictRetries <= 3) {
            WorkspaceData? latest;
            try {
              latest = await _repository.load(perfilAtivo.value);
            } catch (_) {
              message.value =
                  'Não foi possível conferir a versão mais recente. Toque em Tentar novamente.';
              _pending = false;
              return;
            }
            if (generation != _generation) return;
            final baseline = _baselineData;
            if (latest != null &&
                latest.assistedId == current.assistedId &&
                baseline != null) {
              final merged = mergeWorkspaceChanges(
                baseRaw: current.data,
                baseLocal: baseline,
                local: _capture(),
                remote: latest.data,
              );
              if (merged != null) {
                _workspace = latest;
                _detach();
                _restore(merged);
                _attach();
                unawaited(
                  reminderNotifications.sync(
                    lembretes.value,
                    assistedAccount:
                        Supabase.instance.client.auth.currentUser?.id ==
                        latest.assistedId,
                  ),
                );
                _pending = true;
                message.value = null;
                continue;
              }
            }
          }
          needsReload = true;
          message.value =
              'Os mesmos dados mudaram em outro aparelho. Recarregue antes de editar novamente.';
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
