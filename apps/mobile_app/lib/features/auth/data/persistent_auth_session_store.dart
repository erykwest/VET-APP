import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/auth/auth.dart';
import 'auth_session_store.dart';

class PersistentAuthSessionStore implements AuthSessionStore {
  PersistentAuthSessionStore({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _storageKey = 'vet_app.auth_context';

  final SharedPreferencesAsync _preferences;

  AuthContext _context = const AuthContext();

  @override
  Stream<AuthContext> watch() => const Stream<AuthContext>.empty();

  @override
  AuthContext read() => _context;

  @override
  Future<AuthContext> restore() async {
    final raw = await _preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      _context = const AuthContext();
      return _context;
    }

    try {
      final payload = jsonDecode(raw);
      if (payload is! Map<String, dynamic>) {
        _context = const AuthContext();
        return _context;
      }

      final userMap = payload['user'];
      final sessionMap = payload['session'];
      if (userMap is! Map || sessionMap is! Map) {
        _context = const AuthContext();
        return _context;
      }

      _context = AuthContext(
        user: AppUser.fromMap(Map<String, dynamic>.from(userMap)),
        session: AppSession.fromMap(Map<String, dynamic>.from(sessionMap)),
        onboardingCompleted: payload['onboarding_completed'] as bool? ?? false,
      );
    } catch (_) {
      _context = const AuthContext();
    }

    return _context;
  }

  @override
  Future<void> write(AuthContext context) async {
    _context = context;

    if (context.user == null || context.session == null) {
      await _preferences.remove(_storageKey);
      return;
    }

    final payload = <String, dynamic>{
      'user': context.user!.toMap(),
      'session': context.session!.toMap(),
      'onboarding_completed': context.onboardingCompleted,
    };
    await _preferences.setString(_storageKey, jsonEncode(payload));
  }

  @override
  Future<void> clear() async {
    _context = const AuthContext();
    await _preferences.remove(_storageKey);
  }
}
