import 'access_role.dart';

enum AuthResult { signedIn, confirmationRequired }

enum SocialProvider { google, apple }

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
  Future<void> signInWithProvider(SocialProvider provider);
  Future<AccessRole?> loadRole();
  Future<AccessRole> completeRole(AccessRole role);
  bool get hasSession;
}
