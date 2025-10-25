import 'package:dart_nostr/dart_nostr.dart';

class NostrService {
  final connectionTimeout = Duration(seconds: 15);
  late final Nostr instance;
  final List<String> relays;

  NostrService({required this.relays}) {
    instance = Nostr();
  }

  Future<void> reconnect() async {
    try {
      await instance.services.relays.reconnectToRelays(
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

  Future<void> connect() async {
    try {
      await instance.services.relays.init(
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
      final events = await instance.services.relays
          .startEventsSubscriptionAsync(
            timeout: Duration(seconds: 15),
            request: req,
          );

      return (req.subscriptionId, events);
    } catch (e) {
      rethrow;
    }
  }
}
