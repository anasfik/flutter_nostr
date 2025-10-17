import 'package:example/main.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = [
      ...MyApp.routes.map(
        (screen) => (title: screen.title, route: screen.routeName),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Nostr Examples')),
      body: ListView.separated(
        itemCount: demos.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = demos[index];
          return ListTile(
            title: Text(item.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed(item.route),
          );
        },
      ),
    );
  }
}
