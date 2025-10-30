import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter_nostr/models/session_manager.dart';

class NostrAuthOptions {
  final NostrAuthKeysManager keysManager;
  final NostrAuthKeysTransformer keysTransformer;
  final SessionManager sessionManager;

  NostrAuthOptions({
    required this.keysManager,
    required this.keysTransformer,
    required this.sessionManager,
  });
}

class NostrAuthKeysManager {
  final NostrAuthKeys Function() generateNewKeysPair;
  final String Function(String privateKey) getPublicKeyFromPrivateKey;
  final String Function(NostrAuthKeys keysPair) getPublicKeyFromKeysPair;

  NostrAuthKeysManager({
    required this.generateNewKeysPair,
    required this.getPublicKeyFromPrivateKey,
    required this.getPublicKeyFromKeysPair,
  });
}

class NostrAuthKeys {
  final String privateKey;
  late final String _publicKey;

  String get publicKey => _publicKey;

  NostrAuthKeys({required this.privateKey}) {
    _publicKey = Nostr.instance.services.keys.derivePublicKey(
      privateKey: privateKey,
    );
  }
}

class NostrAuthKeysTransformer {
  final String Function(String npub) npubToPubkey;
  final String Function(String nsec) nsecToPrivateKey;
  final String Function(String pubkey) pubkeyToNpub;
  final String Function(String privateKey) privateKeyToNsec;

  NostrAuthKeysTransformer({
    required this.npubToPubkey,
    required this.pubkeyToNpub,
    required this.privateKeyToNsec,
    required this.nsecToPrivateKey,
  });
}

enum AuthType {
  bunker(canSign: true),
  privateKey(canSign: true),
  pubkey(canSign: false);

  final bool canSign;

  const AuthType({required this.canSign});
}
