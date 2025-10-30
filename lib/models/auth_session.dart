import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter_nostr/data_source/nostr_service.dart';
import 'package:flutter_nostr/models/nostr_auth_options.dart';

/// Base class for all authentication sessions
abstract class BaseAuthSession {
  final String id;
  final String pubkey;
  final AuthType type;
  final DateTime createdAt;
  final Map<String, dynamic>? userDetails;

  BaseAuthSession({
    required this.id,
    required this.pubkey,
    required this.type,
    Map<String, dynamic>? userDetails,
    DateTime? createdAt,
  }) : userDetails = userDetails,
       createdAt = createdAt ?? DateTime.now();

  /// Check if this session can sign events
  bool get canSign => type.canSign;

  /// Create and sign an event (implemented by subclasses)
  Future<NostrEvent> createEvent({
    required int kind,
    required String content,
    List<List<String>>? tags,
    DateTime? createdAt,
  });

  /// Convert session to JSON for storage
  Map<String, dynamic> toJson();

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
    this.token,
    super.userDetails,
    super.createdAt,
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
      'userDetails': userDetails,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BunkerAuthSession.fromJson(Map<String, dynamic> json) {
    return BunkerAuthSession(
      id: json['id'] as String,
      pubkey: json['pubkey'] as String,
      bunkerUrl: json['bunkerUrl'] as String,
      token: json['token'] as String?,
      userDetails: json['userDetails'] as Map<String, dynamic>?,
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
    super.userDetails,
    super.createdAt,
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
      'userDetails': userDetails,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PrivateKeyAuthSession.fromJson(Map<String, dynamic> json) {
    return PrivateKeyAuthSession(
      id: json['id'] as String,
      pubkey: json['pubkey'] as String,
      privateKey: json['privateKey'] as String,
      userDetails: json['userDetails'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Public key only authentication session (read-only)
class PubkeyAuthSession extends BaseAuthSession {
  PubkeyAuthSession({
    required super.id,
    required super.pubkey,
    super.userDetails,
    super.createdAt,
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
      'userDetails': userDetails,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PubkeyAuthSession.fromJson(Map<String, dynamic> json) {
    return PubkeyAuthSession(
      id: json['id'] as String,
      pubkey: json['pubkey'] as String,
      userDetails: json['userDetails'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
