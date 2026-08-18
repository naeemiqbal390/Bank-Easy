import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';

/// Reads and writes the Profile to on-device storage only.
/// There is no network call anywhere in this class, by design —
/// see the "local-only, no silent backup" decision in the audit checklist.
class ProfileStore {
  static const _key = 'bankeasy_profile_v1';

  static Future<Profile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return Profile();
    try {
      return Profile.fromJson(jsonDecode(raw));
    } catch (_) {
      // Corrupt/old data — fail safe to an empty profile rather than crash.
      return Profile();
    }
  }

  static Future<void> save(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  /// Permanently erases the profile from this device. There is no
  /// server copy to restore from — the caller's confirmation dialog
  /// must make that clear before calling this.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
