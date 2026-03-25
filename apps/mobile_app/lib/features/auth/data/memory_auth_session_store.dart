import 'dart:async';

import '../../../shared/auth/auth.dart';
import 'auth_session_store.dart';

class MemoryAuthSessionStore implements AuthSessionStore {
  MemoryAuthSessionStore({
    AuthContext? initialContext,
  }) : _controller = StreamController<AuthContext>.broadcast() {
    _context = initialContext ?? const AuthContext();
    _controller.add(_context);
  }

  final StreamController<AuthContext> _controller;
  late AuthContext _context;

  @override
  Stream<AuthContext> watch() => _controller.stream;

  @override
  AuthContext read() => _context;

  @override
  Future<void> write(AuthContext context) async {
    _context = context;
    if (!_controller.isClosed) {
      _controller.add(context);
    }
  }

  @override
  Future<void> clear() async {
    await write(const AuthContext());
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
