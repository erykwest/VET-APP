import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/auth/auth.dart';
import 'auth_session_store.dart';

class SupabaseAuthSessionStore implements AuthSessionStore {
  SupabaseAuthSessionStore({
    required Session? Function() currentSession,
    required Stream<AuthState> authStateChanges,
  })  : _currentSession = currentSession,
        _authStateChanges = authStateChanges,
        _controller = StreamController<AuthContext>.broadcast() {
    _context = _contextFromSession(_currentSession());
    _controller.add(_context);
    _subscription = _authStateChanges.listen(_handleAuthState);
  }

  final Session? Function() _currentSession;
  final Stream<AuthState> _authStateChanges;
  final StreamController<AuthContext> _controller;
  late final StreamSubscription<AuthState> _subscription;

  AuthContext _context = const AuthContext();

  @override
  Stream<AuthContext> watch() => _controller.stream;

  @override
  AuthContext read() => _context;

  @override
  Future<AuthContext> restore() async {
    _setContext(_contextFromSession(_currentSession()));
    return _context;
  }

  @override
  Future<void> write(AuthContext context) async {
    _setContext(context);
  }

  @override
  Future<void> clear() async {
    _setContext(const AuthContext());
  }

  void _handleAuthState(AuthState state) {
    switch (state.event) {
      case AuthChangeEvent.signedOut:
        _setContext(const AuthContext());
        break;
      default:
        _setContext(_contextFromSession(state.session ?? _currentSession()));
    }
  }

  void _setContext(AuthContext context) {
    _context = context;
    if (!_controller.isClosed) {
      _controller.add(context);
    }
  }

  AuthContext _contextFromSession(Session? session) {
    if (session == null || session.user.email == null) {
      return const AuthContext();
    }

    final user = AppUser(
      id: session.user.id,
      email: session.user.email!,
      displayName: session.user.userMetadata?['display_name'] as String?,
      createdAt:
          DateTime.tryParse(session.user.createdAt) ?? DateTime.now().toUtc(),
      onboardingCompleted:
          session.user.userMetadata?['onboarding_completed'] as bool? ?? false,
    );

    return AuthContext(
      user: user,
      session: AppSession(
        user: user,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
        createdAt:
            DateTime.tryParse(session.user.createdAt) ?? DateTime.now().toUtc(),
        expiresAt: session.expiresAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                session.expiresAt! * 1000,
                isUtc: true,
              ),
      ),
      onboardingCompleted: user.onboardingCompleted,
    );
  }

  @override
  Future<void> dispose() async {
    await _subscription.cancel();
    await _controller.close();
  }
}
