import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/access_role.dart';
import '../domain/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  bool get hasSession => _client.auth.currentSession != null;

  @override
  AccessRole? get currentDisplayRole {
    if (!hasSession) return null;
    final role = _client.auth.currentUser?.userMetadata?['display_role'];
    for (final value in AccessRole.values) {
      if (value.profileId == role) return value;
    }
    return null;
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
    required AccessRole role,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session == null || response.user == null) {
        throw const AuthFailure('Não foi possível entrar. Tente novamente.');
      }
      // User metadata only chooses this prototype's interface. It must never
      // authorize database access or be used in an RLS policy.
      final savedRole = response.user!.userMetadata?['display_role'];
      if (savedRole != role.profileId) {
        await _client.auth.signOut();
        throw const AuthFailure(
          'Esta conta pertence ao outro perfil. Volte e escolha o acesso correto.',
        );
      }
      return AuthResult.signedIn;
    } on AuthFailure {
      rethrow;
    } on AuthException {
      throw const AuthFailure(
        'Não foi possível entrar. Verifique e-mail e senha.',
      );
    } catch (_) {
      throw const AuthFailure('Não foi possível conectar. Tente novamente.');
    }
  }

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required AccessRole role,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'https://aislannnn.github.io/mente-viva-v2/',
        data: {'display_role': role.profileId},
      );
      return response.session == null
          ? AuthResult.confirmationRequired
          : AuthResult.signedIn;
    } on AuthException {
      throw const AuthFailure(
        'Não foi possível criar a conta. Confira os dados e tente novamente.',
      );
    } catch (_) {
      throw const AuthFailure('Não foi possível conectar. Tente novamente.');
    }
  }

  @override
  Future<void> signOut() async {
    if (hasSession) await _client.auth.signOut();
  }
}
