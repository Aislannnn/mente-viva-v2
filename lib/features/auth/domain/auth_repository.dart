import 'access_role.dart';

enum AuthResult { signedIn, confirmationRequired }

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
}

abstract interface class AuthRepository {
  Future<AuthResult> signIn({
    required String email,
    required String password,
    required AccessRole role,
  });

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required AccessRole role,
  });

  Future<void> signOut();
  bool get hasSession;
  AccessRole? get currentDisplayRole;
}
