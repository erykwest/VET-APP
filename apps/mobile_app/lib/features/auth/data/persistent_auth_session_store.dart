import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/auth/auth.dart';
import 'auth_session_store.dart';

class PersistentAuthSessionStore implements AuthSessionStore {
  PersistentAuthSessionStore({
    SharedPreferences? preferences,
  })  : _preferences = preferences,
        _controller = StreamController<AuthContext>.broadcast();

  static const _storageKey = 'vet_app.auth_context';

  SharedPreferences? _preferences;
  final StreamController<AuthContext> _controller;

  AuthContext _context = const AuthContext();

  Future<SharedPreferences> _preferencesInstance() async {
    final preferences = _preferences;
    if (preferences != null) {
      return preferences;
    }

    final created = await SharedPreferences.getInstance();
    _preferences = created;
    return created;
  }

  @override
  Stream<AuthContext> watch() => _controller.stream;

  @override
  AuthContext read() => _context;

  @override
  Future<AuthContext> restore() async {
    final preferences = await _preferencesInstance();
    final raw = preferences.getString(_storageKey);
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

    if (!_controller.isClosed) {
      _controller.add(_context);
    }
    return _context;
  }

  @override
  Future<void> write(AuthContext context) async {
    _context = context;
    final preferences = await _preferencesInstance();

    if (context.user == null || context.session == null) {
      await preferences.remove(_storageKey);
      return;
    }

    final payload = <String, dynamic>{
      'user': context.user!.toMap(),
      'session': context.session!.toMap(),
      'onboarding_completed': context.onboardingCompleted,
    };
    await preferences.setString(_storageKey, jsonEncode(payload));
    if (!_controller.isClosed) {
      _controller.add(_context);
    }
  }

  @override
  Future<void> clear() async {
    _context = const AuthContext();
    final preferences = await _preferencesInstance();
    await preferences.remove(_storageKey);
    if (!_controller.isClosed) {
      _controller.add(_context);
    }
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}
