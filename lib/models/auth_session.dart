import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter_nostr/data_source/nostr_service.dart';
import 'package:flutter_nostr/flutter_nostr.dart';
import 'package:flutter_nostr/models/nostr_auth_options.dart';
import 'package:isar/isar.dart';

part 'auth_session.g.dart';

@Collection()
class AuthSession {
  Id get isarId => fastHash(id);

  final String id;
  final String pubkey;

  @Index()
  @enumerated
  final AuthType type;

  final DateTime createdAt;

  // Optional fields depending on the auth type
  final String? privateKey;
  final String? bunkerUrl;
  final String? token;

  AuthSession({
    required this.id,
    required this.pubkey,
    required this.type,
    required this.createdAt,
    this.privateKey,
    this.bunkerUrl,
    this.token,
  });

  bool get canSign => type.canSign;

  // Unified event creation logic
  Future<NostrEvent> createEvent({
    required int kind,
    required String content,
    List<List<String>>? tags,
    DateTime? createdAt,
  }) async {
    switch (type) {
      case AuthType.privateKey:
        return NostrService.instance.createSignedEvent(
          privateKey: privateKey!,
          kind: kind,
          content: content,
          tags: tags ?? [],
          createdAt: createdAt ?? DateTime.now(),
        );

      case AuthType.bunker:
        // TODO: implement bunker signing (remote)
        throw UnimplementedError('Bunker signing not implemented');

      case AuthType.pubkey:
        throw UnsupportedError('Pubkey sessions cannot create signed events');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pubkey': pubkey,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'privateKey': privateKey,
      'bunkerUrl': bunkerUrl,
      'token': token,
    };
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      id: json['id'] as String,
      pubkey: json['pubkey'] as String,
      type: AuthType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AuthType.pubkey,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      privateKey: json['privateKey'] as String?,
      bunkerUrl: json['bunkerUrl'] as String?,
      token: json['token'] as String?,
    );
  }

  /// Simple string-based unique hashing for Isar
  int fastHash(String string) {
    var hash = 0xcbf29ce484222325;
    for (var i = 0; i < string.length; i++) {
      final codeUnit = string.codeUnitAt(i);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xFF;
      hash *= 0x100000001b3;
    }
    return hash;
  }
}
