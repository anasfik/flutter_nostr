// export all.

import 'package:flutter_nostr/data_source/nostr_service.dart';
import 'package:flutter_nostr/utils/logger.dart';

export 'components/components.dart';
export 'models/models.dart';
export 'data_source/parallel_request_executor.dart';

export 'package:dart_nostr/dart_nostr.dart';

abstract class FlutterNostr {
  static bool isConnected = false;

  static late NostrService instance;

  static Future<void> init({required List<String> relays}) async {
    try {
      instance = NostrService(relays: relays);

      if (isConnected) {
        await instance.reconnect();
      } else {
        await instance.connect();
      }

      isConnected = true;
    } catch (e) {
      FlutterNostrLogger.log("Error initializing FlutterNostr: $e");
      isConnected = false;
    }
  }
}
