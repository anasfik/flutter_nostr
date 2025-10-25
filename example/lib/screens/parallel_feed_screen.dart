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

    final followingsFetchRequestId = ParallelRequestId<UserFollowings>(
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
          NostrFilter(
            limit: 25,
            kinds: [1], // posts kinds
          ),
        ],
        parallelRequestRequestsHandler: (_, List<NostrEvent> postEvents) {
          return ParallelRequest(
            id: profileFetchRequestId,
            filters: [
              NostrFilter(
                kinds: [0], // user details kind
                authors: postEvents.map((e) => e.pubkey).toList(),
              ),
            ],
            adapter: (event) {
              return UserInfo.fromEvent(event);
            },
          ).then<UserFollowings>((List<UserInfo> users) {
            return ParallelRequest(
              id: followingsFetchRequestId,
              filters: [
                NostrFilter(
                  kinds: [3], // user followings kind
                  authors: users.map((u) => u.event.pubkey).toList(),
                ),
              ],
              adapter: (event) {
                return UserFollowings.fromEvent(event);
              },
            );
          });
        },
        builder: (context, data, options) {
          return FlutterNostrFeedList(
            data: data,
            options: options,
            itemBuilder: (context, NostrEvent postEvent, index, data, options) {
              final postContent = postEvent.content != null
                  ? postEvent.content!
                  : "";

              final profileFetchResults = data.parallelRequestResultsFor(
                profileFetchRequestId,
              );

              final followingsFetchResults = data.parallelRequestResultsFor(
                followingsFetchRequestId,
              );

              List<UserInfo> userResults =
                  profileFetchResults?.adaptedResults ?? [];

              List<UserFollowings> followingsResults =
                  followingsFetchResults?.adaptedResults ?? [];

              UserInfo? user = userResults
                  .where((element) => element.event.pubkey == postEvent.pubkey)
                  .firstOrNull;

              UserFollowings? userFollowings = followingsResults
                  .where((element) => element.pubkey == postEvent.pubkey)
                  .firstOrNull;

              final postOwnerName = user?.name.isEmpty ?? true
                  ? "Loading Or Unknown"
                  : user!.name;
              final postOwnerFollowingsCount =
                  userFollowings?.followings.length ?? 0;
              return ListTile(
                title: Text(postOwnerName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(postContent),
                    SizedBox(height: 4),
                    Text(
                      'Followings: $postOwnerFollowingsCount',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
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
