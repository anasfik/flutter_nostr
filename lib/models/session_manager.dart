import 'dart:async';
import 'package:flutter_nostr/models/auth_session.dart';
import 'package:flutter_nostr/models/nostr_auth_options.dart';

/// Manager for handling authentication sessions
class SessionManager {
  SessionManager._();

  static SessionManager instance = SessionManager._();

  final Map<String, BaseAuthSession> _sessions = {};
  BaseAuthSession? _currentSession;
  final _sessionController = StreamController<BaseAuthSession?>.broadcast();

  /// Stream of current session changes
  Stream<BaseAuthSession?> get currentSessionStream =>
      _sessionController.stream;

  /// Get the current active session
  BaseAuthSession? get currentSession => _currentSession;

  /// Get all sessions
  List<BaseAuthSession> get allSessions => _sessions.values.toList();

  /// Add a new session to the manager
  Future<BaseAuthSession> addSession(BaseAuthSession session) async {
    _sessions[session.id] = session;
    return session;
  }

  /// Remove a session from the manager
  Future<void> removeSession(BaseAuthSession session) async {
    _sessions.remove(session.id);

    // If the removed session was the current session, clear it
    if (_currentSession?.id == session.id) {
      await switchSession(null);
    }
  }

  /// Switch to a different session
  Future<BaseAuthSession?> switchSession(BaseAuthSession? session) async {
    _currentSession = session;
    _sessionController.add(_currentSession);
    return _currentSession;
  }

  /// Get a session by ID
  BaseAuthSession? getSessionById(String id) {
    return _sessions[id];
  }

  /// Check if a session exists
  bool hasSession(String id) {
    return _sessions.containsKey(id);
  }

  /// Get sessions by type
  List<BaseAuthSession> getSessionsByType(AuthType type) {
    return _sessions.values.where((session) => session.type == type).toList();
  }

  /// Clear all sessions
  Future<void> clearAllSessions() async {
    _sessions.clear();
    await switchSession(null);
  }

  /// Get sessions count
  int get sessionCount => _sessions.length;

  /// Dispose of resources
  void dispose() {
    _sessionController.close();
  }
}
