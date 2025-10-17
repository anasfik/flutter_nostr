import 'dart:convert';

import 'package:example/screens/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nostr/flutter_nostr.dart';

class MultiLayerParallelFeedScreen extends AppScreen {
  MultiLayerParallelFeedScreen({
    super.key,
    super.title = 'Multi-Layer Parallel Feed Screen',
    super.routeName = '/multi-layer-parallel',
  });

  @override
  Widget build(BuildContext context) {
    final profileFetchRequestId = ParallelRequestId<UserInfo>(
      id: 'profile-fetch',
    );

    final profileFollowings = ParallelRequestId<UserFollowings>(
      id: 'profile-followings',
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
                  title: Text('Multi-Layer Parallel Feed Screen'),
                  content: Text(
                    'This screen demonstrates multiple layers of parallel requests with chaining.\n\n'
                    'Features:\n'
                    '• Fetches main events (kind 30402)\n'
                    '• Layer 1: Fetches user profiles (kind 0) for all authors\n'
                    '• Layer 2: Fetches user followings (kind 3) based on Layer 1 results\n'
                    '• Displays events with profile info AND following counts\n'
                    '• Shows the power of chaining parallel requests\n\n'
                    'This demonstrates how to build complex data relationships using the parallel request system.',
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
          final req =
              ParallelRequest(
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
              ).then((users) {
                return ParallelRequest(
                  id: profileFollowings,
                  filters: [
                    NostrFilter(
                      kinds: [3],
                      authors: users.map((u) => u.pubkey).toList(),
                    ),
                  ],
                  adapter: (event) {
                    return UserFollowings.fromEvent(event);
                  },
                );
              });

          return req;
        },
        builder: (context, data, options) {
          return FlutterNostrFeedList(
            data: data,
            options: options,
            itemBuilder: (context, event, index, data, options) {
              final text = event.content ?? '';
              // Use fetched profile results
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

              final userFollowings =
                  data
                      .locateParallelRequestResultsById(profileFollowings)
                      ?.adaptedResults ??
                  [];

              final followings = userFollowings.firstWhere(
                (element) => element.pubkey == event.pubkey,
                orElse: () => UserFollowings(pubkey: '', followings: []),
              );

              return ListTile(
                tileColor: index.isEven ? Colors.grey[200] : Colors.transparent,
                key: ValueKey('item-$index'),
                leading: Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: image,
                      child: (image == null)
                          ? Text(name.substring(0, 1).toUpperCase())
                          : null,
                    ),
                    SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        '${followings.followings.length} followings'.substring(
                          0,
                          '${followings.followings.length} followings'.length >
                                  15
                              ? 15
                              : '${followings.followings.length} followings'
                                    .length,
                        ),
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                title: Text(name),
                subtitle: Text(
                  text.substring(0, text.length > 200 ? 200 : text.length),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UserFollowings {
  final String pubkey;
  final List<String> followings;

  UserFollowings({required this.pubkey, required this.followings});

  factory UserFollowings.fromEvent(NostrEvent event) {
    final tags = event.tags;
    final followings = tags
        ?.where((tag) => tag.isNotEmpty && tag[0] == 'p' && tag.length > 1)
        .map((tag) => tag[1])
        .toList();

    return UserFollowings(pubkey: event.pubkey, followings: followings ?? []);
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
