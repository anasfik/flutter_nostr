import 'dart:async';
import 'package:flutter_nostr/flutter_nostr.dart';
import 'package:flutter_nostr/models/auth_session.dart';
import 'package:flutter_nostr/models/nostr_auth_options.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manager for handling authentication sessions
class SessionManager {
  SessionManager._() {
    unawaited(_syncWithStoredLastSession());
  }

  static SessionManager instance = SessionManager._();

  final lastSessionId = "last_session_id";

  AuthSession? _currentSession;

  final StreamController<AuthSession?> _sessionController =
      StreamController<AuthSession?>.broadcast();

  /// Stream of current session changes
  Stream<AuthSession?> get currentSessionStream {
    return _sessionController.stream;
  }

  /// Get the current active session
  AuthSession? get currentSession => _currentSession;

  Isar get _isar => FlutterNostr.isar;

  /// Add a new session to the manager
  Future<AuthSession> addSession(AuthSession session) async {
    await _isar.writeTxn(() async {
      await _isar.authSessions.put(session);
    });

    return session;
  }

  /// Remove a session from the manager
  Future<void> removeSession(AuthSession session) async {
    await _isar.writeTxn(() async {
      await _isar.authSessions.delete(session.isarId);
    });

    // If the removed session was the current session, clear it
    if (_currentSession?.id == session.id) {
      await switchSession(null);
    }
  }

  /// Switch to a different session
  Future<AuthSession?> switchSession(AuthSession? session) async {
    _currentSession = session;
    _sessionController.add(_currentSession);

    final prefs = await SharedPreferences.getInstance();

    if (session != null) {
      await prefs.setString(lastSessionId, session.id);
    } else {
      await prefs.remove(lastSessionId);
    }
    return _currentSession;
  }

  /// Get all sessions
  Stream<List<AuthSession>> allSessions() {
    return _isar.authSessions.where().watch(fireImmediately: true);
  }

  /// Get all sessions
  List<AuthSession> allSessionsSync() {
    return _isar.authSessions.where().findAllSync();
  }

  /// Get a session by ID
  AuthSession? getSessionById(String id) {
    return _isar.authSessions.filter().idEqualTo(id).findFirstSync();
  }

  /// Check if a session exists
  bool hasSession(String id) {
    return getSessionById(id) != null;
  }

  /// Get sessions by type
  List<AuthSession> getSessionsByType(AuthType type) {
    return _isar.authSessions.filter().typeEqualTo(type).findAllSync();
  }

  /// Clear all sessions
  Future<void> clearAllSessions() async {
    _isar.writeTxn(() async {
      await _isar.authSessions.clear();
    });

    await switchSession(null);
  }

  /// Get sessions count
  int get sessionCount => _isar.authSessions.countSync();

  /// Dispose of resources
  void dispose() {
    _sessionController.close();
  }

  /// Sync with the stored last session
  Future<void> _syncWithStoredLastSession() async {
    final prefs = await SharedPreferences.getInstance();

    final lastSession = prefs.getString(lastSessionId);

    if (lastSession != null) {
      final session = getSessionById(lastSession);
      if (session != null) {
        _currentSession = session;
        _sessionController.add(_currentSession);
      }
    }
  }
}
