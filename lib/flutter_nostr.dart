// export all.

import 'package:flutter/material.dart';
import 'package:flutter_nostr/data_source/nostr_service.dart';
import 'package:flutter_nostr/models/models.dart';
import 'package:flutter_nostr/utils/logger.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

export 'components/components.dart';
export 'models/models.dart';
export 'data_source/parallel_request_executor.dart';

export 'package:dart_nostr/dart_nostr.dart';

abstract class FlutterNostr {
  static bool isConnected = false;

  static late NostrService instance;
  static late Isar _isar;

  static Isar get isar => _isar;

  static Future<void> init({required List<String> relays}) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      await _connect(relays: relays);
      await _initLocalDatabase();
    } catch (e) {
      FlutterNostrLogger.log("Error initializing FlutterNostr: $e");
      isConnected = false;
    }
  }

  static Future<void> _connect({required List<String> relays}) async {
    instance = NostrService.instance;

    if (isConnected) {
      await instance.reconnect();
    } else {
      await instance.connect(relays: relays);
    }

    isConnected = true;
  }

  static Future<void> _initLocalDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    print('Database directory: ${dir.path}');

    _isar = await Isar.open([AuthSessionSchema], directory: dir.path);
  }
}
