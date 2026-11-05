import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/access_role.dart';
import '../domain/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(
    this._client, {
    required this.apiUrl,
    required this.publishableKey,
  });

  final SupabaseClient _client;
  final String apiUrl;
  final String publishableKey;

  @override
  bool get hasSession => _client.auth.currentSession != null;

  @override
  Future<AccessRole?> loadRole() async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return null;
    final profile = await _client
        .from('profiles')
        .select('role')
        .eq('id', id)
        .single();
    final role = profile['role'];
    for (final value in AccessRole.values) {
      if (value.profileId == role) return value;
    }
    return null;
  }

  @override
  Future<AccessRole> completeRole(AccessRole role) async {
    if (!hasSession) throw const AuthFailure('Entre na sua conta primeiro.');
    try {
      final saved = await _client.rpc(
        'complete_profile_role',
        params: {'requested_role': role.profileId},
      );
      return AccessRole.values.firstWhere((value) => value.profileId == saved);
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure(
        'Não foi possível concluir o perfil. Tente novamente.',
      );
    }
  }

  @override
  Future<void> signInWithProvider(SocialProvider provider) async {
    try {
      final providerName = provider == SocialProvider.google
          ? 'Google'
          : 'Apple';
      // Auth settings expose enabled providers publicly. Avoid sending users
      // to a dead OAuth page while a provider is awaiting dashboard setup.
      try {
        final response = await http
            .get(
              Uri.parse('$apiUrl/auth/v1/settings'),
              headers: {'apikey': publishableKey},
            )
            .timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final settings = jsonDecode(response.body) as Map<String, dynamic>;
          final external = settings['external'] as Map<String, dynamic>?;
          final enabled = external?[provider.name];
          if (enabled == false) {
            throw AuthFailure(
              'Acesso com $providerName ainda precisa ser ativado. Use e-mail ou a demonstração por enquanto.',
            );
          }
        }
      } on AuthFailure {
        rethrow;
      } catch (_) {
        // A settings request failure must not prevent an otherwise valid login.
      }
      final started = await _client.auth.signInWithOAuth(
        provider == SocialProvider.google
            ? OAuthProvider.google
            : OAuthProvider.apple,
        redirectTo: kIsWeb
            ? 'https://aislannnn.github.io/mente-viva-v2/'
            : 'menteviva://login-callback/',
      );
      if (!started)
        throw const AuthFailure('Não foi possível iniciar o acesso.');
    } on AuthFailure {
      rethrow;
    } on AuthException catch (error) {
      throw AuthFailure(error.message);
    } catch (_) {
      throw const AuthFailure(
        'Não foi possível conectar ao provedor. Tente novamente.',
      );
    }
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
      final savedRole = await loadRole();
      if (savedRole != role) {
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
