import 'package:example/screens/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nostr/flutter_nostr.dart';
import 'screens/home_screen.dart';
import 'screens/simple_feed_screen.dart';
import 'screens/parallel_feed_screen.dart';
import 'screens/single_layer_parallel_feed_screen.dart';
import 'screens/one_time_event_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/create_post_screen.dart';

void main() async {
  
  await FlutterNostr.init(relays: ['wss://relay.nostr.band']);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final routes = [
    AuthScreen(),
    CreatePostScreen(),
    SimpleFeedScreen(),
    SingleLayerParallelFeedScreen(),
    MultiLayerParallelFeedScreen(),
    OneTimeEventScreen(),
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
        '/user': (context) => UserScreen(),
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
