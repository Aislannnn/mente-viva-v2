import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/data/supabase_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
);
const enableSupabaseAuth = bool.fromEnvironment('ENABLE_SUPABASE_AUTH');

bool get authConfigured =>
    enableSupabaseAuth &&
    supabaseUrl.isNotEmpty &&
    supabasePublishableKey.isNotEmpty;

Future<void> initializeAuth() async {
  if (!authConfigured) return;
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
}

AuthRepository get authRepository =>
    SupabaseAuthRepository(Supabase.instance.client);
