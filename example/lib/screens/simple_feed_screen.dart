import 'package:example/screens/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_nostr/flutter_nostr.dart';
import 'package:linkify/linkify.dart';

class SimpleFeedScreen extends AppScreen {
  SimpleFeedScreen({
    super.key,
    super.title = "Simple Feed (no parallel requests)",
    super.routeName = '/simple_feed',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Simple Feed Screen'),
                  content: Text(
                    'This screen demonstrates a basic Nostr feed without any parallel requests.\n\n'
                    'Features:\n'
                    '• Fetches events using basic Nostr filters\n'
                    '• Displays events in a simple list format\n'
                    '• No additional data fetching or processing\n'
                    '• Shows raw event content with link detection\n\n'
                    'This is the simplest way to display a Nostr feed and is perfect for basic use cases.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FlutterNostrFeed(
        filters: [
          NostrFilter(limit: 10, kinds: [30402]),
        ],
        builder: (context, data, options) {
          return FlutterNostrFeedList(
            data: data,
            options: options,
            itemBuilder: (context, event, index, data, options) {
              final text = event.content ?? '';
              return ListTile(
                tileColor: index.isEven ? Colors.grey[200] : null,
                key: ValueKey('item-$index'),
                title: Linkify(
                  text: text.summarize(150),
                  linkifiers: [UrlLinkifier()],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

extension on String {
  String summarize(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}
