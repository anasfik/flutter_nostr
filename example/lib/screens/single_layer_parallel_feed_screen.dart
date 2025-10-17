import 'dart:convert';

import 'package:example/screens/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nostr/flutter_nostr.dart';

class SingleLayerParallelFeedScreen extends AppScreen {
  SingleLayerParallelFeedScreen({
    super.key,
    super.title = 'Single-Layer Parallel Feed Screen',
    super.routeName = '/single-layer-parallel',
  });

  @override
  Widget build(BuildContext context) {
    final profileFetchRequestId = ParallelRequestId<UserInfo>(
      id: 'profile-fetch',
    );

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
                  title: Text('Single-Layer Parallel Feed Screen'),
                  content: Text(
                    'This screen demonstrates a single layer of parallel requests.\n\n'
                    'Features:\n'
                    '• Fetches main events (kind 30402)\n'
                    '• Makes ONE parallel request to fetch user profiles (kind 0)\n'
                    '• Displays events with user profile information\n'
                    '• Shows profile pictures and names when available\n\n'
                    'This is perfect when you need to enrich your feed with additional data from a single source.',
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
        parallelRequestRequestsHandler: (parallelRequestResults, events) {
          // Single layer: only fetch user profiles, no followings
          final req = ParallelRequest<UserInfo>(
            id: profileFetchRequestId,
            filters: [
              NostrFilter(
                kinds: [0],
                authors: events.map((e) => e.pubkey).toList(),
              ),
            ],
            adapter: (event) {
              return UserInfo.fromEvent(event);
            },
          );

          return req;
        },
        builder: (context, data, options) {
          return FlutterNostrFeedList(
            data: data,
            options: options,
            itemBuilder: (context, event, index, data, options) {
              final text = event.content ?? '';

              // Use fetched profile results (single layer)
              final profileFetchResults = data.locateParallelRequestResultsById(
                profileFetchRequestId,
              );

              final userResults = profileFetchResults?.adaptedResults ?? [];

              final user = userResults.firstWhere(
                (element) => element.event.pubkey == event.pubkey,
                orElse: () => UserInfo.empty(),
              );

              final image = (user.picture.isNotEmpty)
                  ? NetworkImage(user.picture)
                  : null;

              final name = (user.name.isNotEmpty) ? user.name : event.pubkey;

              return ListTile(
                tileColor: index.isEven ? Colors.grey[200] : Colors.transparent,
                key: ValueKey('item-$index'),
                leading: CircleAvatar(
                  backgroundImage: image,
                  child: (image == null)
                      ? Text(name.substring(0, 1).toUpperCase())
                      : null,
                ),
                title: Text(name),
                subtitle: Text(
                  text.substring(0, text.length > 200 ? 200 : text.length),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Single Layer',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UserInfo {
  final String name;
  final String pubkey;
  final String picture;
  final NostrEvent event;

  UserInfo({
    required this.name,
    required this.pubkey,
    required this.picture,
    required this.event,
  });

  factory UserInfo.fromEvent(NostrEvent event) {
    final content = jsonDecode(event.content ?? '{}') as Map<String, dynamic>;

    return UserInfo(
      event: event,
      name: content['name'] as String? ?? '',
      pubkey: event.pubkey,
      picture:
          content['picture'] as String? ?? content['image'] as String? ?? '',
    );
  }

  factory UserInfo.empty() {
    return UserInfo(
      name: '',
      pubkey: '',
      picture: '',
      event: NostrEvent(
        id: '',
        pubkey: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        kind: 0,
        tags: [],
        content: '',
        sig: '',
      ),
    );
  }
}
