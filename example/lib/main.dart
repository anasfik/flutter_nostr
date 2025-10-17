import 'package:flutter/material.dart';
import 'package:flutter_nostr/flutter_nostr.dart';
import 'screens/home_screen.dart';
import 'screens/simple_feed_screen.dart';
import 'screens/parallel_feed_screen.dart';
import 'screens/single_layer_parallel_feed_screen.dart';

void main() async {
  await FlutterNostr.init(relays: ['wss://relay.nostr.band']);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final routes = [
    SimpleFeedScreen(),
    SingleLayerParallelFeedScreen(),
    MultiLayerParallelFeedScreen(),
  ];

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Nostr Examples',
      routes: {
        '/': (context) => const HomeScreen(),
        ...Map.fromEntries(
          MyApp.routes.map(
            (screen) => MapEntry(screen.routeName, (context) => screen),
          ),
        ),
      },
      initialRoute: '/',
    );
  }
}
