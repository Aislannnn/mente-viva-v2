import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/workspace_repository.dart';

class SupabaseWorkspaceRepository implements WorkspaceRepository {
  const SupabaseWorkspaceRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<WorkspaceData?> load(String role) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('Entre com sua conta para sincronizar.');
    final profile = await _client
        .from('profiles')
        .select('role')
        .eq('id', uid)
        .single();
    if (profile['role'] != role) {
      throw StateError('O perfil escolhido não corresponde à conta.');
    }
    String assistedId = uid;
    if (role == 'cuidador') {
      final link = await _client
          .from('care_links')
          .select('assisted_id')
          .eq('caregiver_id', uid)
          .maybeSingle();
      if (link == null) return null;
      assistedId = link['assisted_id'] as String;
    }
    var record = await _client
        .from('app_records')
        .select('assisted_id, data, version')
        .eq('assisted_id', assistedId)
        .maybeSingle();
    if (record == null && role == 'assistida') {
      record = await _client
          .from('app_records')
          .insert({'assisted_id': assistedId})
          .select('assisted_id, data, version')
          .single();
    }
    if (record == null)
      throw StateError('Os dados vinculados não foram encontrados.');
    return WorkspaceData(
      assistedId: assistedId,
      version: (record['version'] as num).toInt(),
      data: Map<String, dynamic>.from(record['data'] as Map),
    );
  }

  @override
  Future<int> save(WorkspaceData current, Map<String, dynamic> data) async {
    final updated = await _client
        .from('app_records')
        .update({
          'data': data,
          'version': current.version + 1,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('assisted_id', current.assistedId)
        .eq('version', current.version)
        .select('version')
        .maybeSingle();
    if (updated == null) throw const WorkspaceConflict();
    return (updated['version'] as num).toInt();
  }

  @override
  Future<String> createInvite() async {
    final code = await _client.rpc('create_care_invite');
    return code as String;
  }

  @override
  Future<void> redeemInvite(String code) async {
    await _client.rpc('redeem_care_invite', params: {'code': code.trim()});
  }

  @override
  Future<List<String>> caregiverIds() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('Entre com sua conta.');
    final rows = await _client
        .from('care_links')
        .select('caregiver_id')
        .eq('assisted_id', uid);
    return [for (final row in rows) row['caregiver_id'] as String];
  }

  @override
  Future<void> unlinkCaregiver(String caregiverId) async {
    await _client.rpc(
      'unlink_caregiver',
      params: {'target_caregiver_id': caregiverId},
    );
  }
}
