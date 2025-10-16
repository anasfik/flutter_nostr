// export all.

import 'package:flutter_nostr/data_source/nostr_service.dart';

export 'components/components.dart';
export 'models/models.dart';
export 'data_source/parallel_request_executor.dart';

export 'package:dart_nostr/dart_nostr.dart';

abstract class FlutterNostr {
  static late NostrService instance;

  static Future<void> init({required List<String> relays}) async {
    instance = NostrService(relays: relays);

    await instance.connect();
  }
}
