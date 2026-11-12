import 'package:shared_preferences/shared_preferences.dart';

class PendingCareInvite {
  static const _pendingKey = 'pending_care_invite';
  static const _acceptedKey = 'accepted_care_invite';

  Future<void> rememberFromUrl() async {
    final code = Uri.base.queryParameters['care_invite']?.trim().toUpperCase();
    if (code == null || !RegExp(r'^[A-F0-9]{16}$').hasMatch(code)) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_acceptedKey) != code) {
      await prefs.setString(_pendingKey, code);
    }
  }

  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(_pendingKey);

  Future<void> accepted(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_acceptedKey, code);
    await prefs.remove(_pendingKey);
  }
}

final pendingCareInvite = PendingCareInvite();
