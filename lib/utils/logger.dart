 import 'dart:developer' as developer;
 
sealed class FlutterNostrLogger {
  static void log(String message) {
    // You can customize this method to log messages in a specific way
    developer.log("[FlutterNostr] $message");
  }
}