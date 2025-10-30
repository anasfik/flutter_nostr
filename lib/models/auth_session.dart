import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter_nostr/data_source/nostr_service.dart';
import 'package:flutter_nostr/flutter_nostr.dart';
import 'package:flutter_nostr/models/nostr_auth_options.dart';
import 'package:isar/isar.dart';

part 'auth_session.g.dart';

@Collection()
/// Base class for all authentication sessions
class BaseAuthSession {
  Id get isarId => fastHash(id);

  final String id;
  final String pubkey;

  @Index()
  @enumerated
  final AuthType type;

  final DateTime createdAt;

  BaseAuthSession({
    required this.id,
    required this.pubkey,
    required this.type,
    required this.createdAt,
  });

  /// Check if this session can sign events
  bool get canSign => type.canSign;

  /// FNV-1a 64bit hash algorithm optimized for Dart Strings
  int fastHash(String string) {
    var hash = 0xcbf29ce484222325;

    var i = 0;
    while (i < string.length) {
      final codeUnit = string.codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xFF;
      hash *= 0x100000001b3;
    }

    return hash;
  }

  /// Create and sign an event (implemented by subclasses)
  Future<NostrEvent> createEvent({
    required int kind,
    required String content,
    List<List<String>>? tags,
    DateTime? createdAt,
  }) async {
    switch (type) {
      case AuthType.bunker:
        return (this as BunkerAuthSession).createEvent(
          kind: kind,
          content: content,
          tags: tags,
          createdAt: createdAt,
        );
      case AuthType.privateKey:
        return (this as PrivateKeyAuthSession).createEvent(
          kind: kind,
          content: content,
          tags: tags,
          createdAt: createdAt,
        );
      case AuthType.pubkey:
        return (this as PubkeyAuthSession).createEvent(
          kind: kind,
          content: content,
          tags: tags,
          createdAt: createdAt,
        );
    }
  }

  /// Convert session to JSON for storage
  Map<String, dynamic> toJson() {
    throw UnimplementedError('toJson must be implemented by subclasses');
  }

  /// Create session from JSON
  static BaseAuthSession fromJson(Map<String, dynamic> json) {
    final authType = AuthType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => AuthType.pubkey,
    );

    switch (authType) {
      case AuthType.bunker:
        return BunkerAuthSession.fromJson(json);
      case AuthType.privateKey:
        return PrivateKeyAuthSession.fromJson(json);
      case AuthType.pubkey:
        return PubkeyAuthSession.fromJson(json);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseAuthSession &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Bunker authentication session (signs with remote bunker service)
class BunkerAuthSession extends BaseAuthSession {
  final String bunkerUrl;
  final String? token;

  BunkerAuthSession({
    required super.id,
    required super.pubkey,
    required this.bunkerUrl,
    required super.createdAt,
    this.token,
  }) : super(type: AuthType.bunker);

  @override
  Future<NostrEvent> createEvent({
    required int kind,
    required String content,
    List<List<String>>? tags,
    DateTime? createdAt,
  }) async {
    // TODO: Implement bunker signing mechanism
    // This would typically involve:
    // 1. Create unsigned event
    // 2. Send to bunker service for signing
    // 3. Return signed event

    // For now, throw unimplemented error
    throw UnimplementedError('Bunker signing not yet implemented');

    // This would be the implementation:
    // final now = createdAt ?? DateTime.now();
    // final unsignedEvent = NostrEvent(...);
    // return await bunkerService.sign(unsignedEvent);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pubkey': pubkey,
      'type': type.name,
      'bunkerUrl': bunkerUrl,
      'token': token,

      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BunkerAuthSession.fromJson(Map<String, dynamic> json) {
    return BunkerAuthSession(
      id: json['id'] as String,
      pubkey: json['pubkey'] as String,
      bunkerUrl: json['bunkerUrl'] as String,
      token: json['token'] as String?,

      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Private key authentication session (local signing)
class PrivateKeyAuthSession extends BaseAuthSession {
  final String privateKey; // Should be encrypted in production

  PrivateKeyAuthSession({
    required super.id,
    required super.pubkey,
    required this.privateKey,

    required super.createdAt,
  }) : super(type: AuthType.privateKey);

  @override
  Future<NostrEvent> createEvent({
    required int kind,
    required String content,
    List<List<String>>? tags,
    DateTime? createdAt,
  }) async {
    // Create and sign an event locally using the private key
    final now = createdAt ?? DateTime.now();

    // Create unsigned event
    final event = NostrService.instance.createSignedEvent(
      privateKey: privateKey,
      kind: kind,
      content: content,
      tags: tags ?? [],
      createdAt: now,
    );

    return event;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pubkey': pubkey,
      'type': type.name,
      'privateKey': privateKey,

      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PrivateKeyAuthSession.fromJson(Map<String, dynamic> json) {
    return PrivateKeyAuthSession(
      id: json['id'] as String,
      pubkey: json['pubkey'] as String,
      privateKey: json['privateKey'] as String,

      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Public key only authentication session (read-only)
class PubkeyAuthSession extends BaseAuthSession {
  PubkeyAuthSession({
    required super.id,
    required super.pubkey,
    required super.createdAt,
  }) : super(type: AuthType.pubkey);

  @override
  Future<NostrEvent> createEvent({
    required int kind,
    required String content,
    List<List<String>>? tags,
    DateTime? createdAt,
  }) {
    throw UnsupportedError('Pubkey sessions cannot create signed events');
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pubkey': pubkey,
      'type': type.name,

      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PubkeyAuthSession.fromJson(Map<String, dynamic> json) {
    return PubkeyAuthSession(
      id: json['id'] as String,
      pubkey: json['pubkey'] as String,

      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
