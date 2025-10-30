import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter_nostr/models/nostr_auth_options.dart';

class NostrService {
  NostrService._() {
    nostrInstance = Nostr();
  }
  static final NostrService instance = NostrService._();

  final connectionTimeout = Duration(seconds: 15);
  final sendEventTimeout = Duration(seconds: 5);

  late final Nostr nostrInstance;

  Future<void> reconnect() async {
    try {
      await nostrInstance.services.relays.reconnectToRelays(
        onRelayListening: (_, __, ___) {},
        onRelayConnectionError: (_, __, ___) {},
        onRelayConnectionDone: (_, __) {},
        retryOnError: false,
        retryOnClose: false,
        shouldReconnectToRelayOnNotice: true,
        connectionTimeout: connectionTimeout,
        ignoreConnectionException: false,
        lazyListeningToRelays: false,
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> connect({required List<String> relays}) async {
    try {
      await nostrInstance.services.relays.init(
        relaysUrl: relays,
        connectionTimeout: connectionTimeout,
        shouldReconnectToRelayOnNotice: true,
        ignoreConnectionException: false,
        ensureToClearRegistriesBeforeStarting: true,
      );
    } catch (e) {
      //
      rethrow;
    }
  }

  Future<(String? subId, List<NostrEvent>)> getEvents({
    required List<NostrFilter> filters,
  }) async {
    try {
      final req = NostrRequest(filters: filters);
      final events = await nostrInstance.services.relays
          .startEventsSubscriptionAsync(
            timeout: Duration(seconds: 15),
            request: req,
          );

      return (req.subscriptionId, events);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEvent(NostrEvent event) async {
    try {
      await nostrInstance.services.relays.sendEventToRelaysAsync(
        event,
        timeout: sendEventTimeout,
      );
    } catch (e) {
      rethrow;
    }
  }

  NostrAuthKeys generateNewKeysPair() {
    return NostrAuthKeys(
      privateKey: nostrInstance.services.keys.generateKeyPair().private,
    );
  }

  String getPublicKeyFromPrivateKey(String privateKey) {
    return nostrInstance.services.keys.derivePublicKey(privateKey: privateKey);
  }

  String getPublicKeyFromKeysPair(NostrAuthKeys keysPair) {
    return keysPair.publicKey;
  }

  String npubToPubkey(String npub) {
    return nostrInstance.services.bech32.decodeNpubKeyToPublicKey(npub);
  }

  String nsecToPrivateKey(String nsec) {
    return nostrInstance.services.bech32.decodeNsecKeyToPrivateKey(nsec);
  }

  String privateKeyToNsec(String privateKey) {
    return nostrInstance.services.bech32.encodePrivateKeyToNsec(privateKey);
  }

  String pubkeyToNpub(String pubkey) {
    return nostrInstance.services.bech32.encodePublicKeyToNpub(pubkey);
  }

  NostrEvent createSignedEvent({
    required int kind,
    required String privateKey,
    String? content,
    List<List<String>>? tags,
    DateTime? createdAt,
  }) {
    return NostrEvent.fromPartialData(
      keyPairs: NostrKeyPairs(private: privateKey),
      kind: kind,
      content: content ?? '',
      createdAt: createdAt,
      tags: tags,
    );
  }
}
