import 'package:dart_nostr/dart_nostr.dart';

class NostrService {
  late final Nostr instance;
  final List<String> relays;

  NostrService({required this.relays}) {
    instance = Nostr();
  }

  Future<void> connect() async {
    try {
      await instance.services.relays.init(
        relaysUrl: relays,
        connectionTimeout: Duration(seconds: 15),
        shouldReconnectToRelayOnNotice: true,
        ignoreConnectionException: false,
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
