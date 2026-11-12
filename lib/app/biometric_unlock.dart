import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BiometricUnlock {
  final LocalAuthentication _auth = LocalAuthentication();

  bool get supportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  String? get _key {
    final id = Supabase.instance.client.auth.currentUser?.id;
    return id == null ? null : 'biometric_unlock_$id';
  }

  Future<bool> available() async {
    if (!supportedPlatform) return false;
    try {
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> enabled() async {
    final key = _key;
    if (key == null || !supportedPlatform) return false;
    return (await SharedPreferences.getInstance()).getBool(key) ?? false;
  }

  Future<bool> authenticate() async {
    if (!await available()) return false;
    try {
      return await _auth.authenticate(
        localizedReason: 'Confirme sua identidade para acessar o Mente Viva',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> setEnabled(bool value) async {
    final key = _key;
    if (key == null) return false;
    if (value && !await authenticate()) return false;
    return (await SharedPreferences.getInstance()).setBool(key, value);
  }
}

final biometricUnlock = BiometricUnlock();
