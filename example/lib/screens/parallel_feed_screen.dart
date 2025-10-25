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
      backgroundColor: Colors.grey[50],
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
              final postContent = postEvent.content ?? '';
              final timestamp = DateTime.fromMillisecondsSinceEpoch(
                (postEvent.createdAt?.millisecondsSinceEpoch) ?? 0,
              );
              final timeAgo = _getTimeAgo(timestamp);

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

              final postOwnerFollowingsCount =
                  userFollowings?.followings.length ?? 0;

              final image = (user?.picture.isNotEmpty ?? false)
                  ? NetworkImage(user!.picture)
                  : null;

              final displayName = user?.name.isNotEmpty ?? false
                  ? user!.name
                  : 'Anonymous User';

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showEventWithProfileAndFollowings(
                      context,
                      postEvent,
                      user,
                      userFollowings,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with profile info
                          Row(
                            children: [
                              // Profile avatar with following count
                              Stack(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Colors.purple[200]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 22,
                                      backgroundImage: image,
                                      backgroundColor: Colors.purple[100],
                                      child: image == null
                                          ? Text(
                                              displayName
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.purple[700],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                  // Following count badge
                                  Positioned(
                                    bottom: -2,
                                    right: -2,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[500],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '${postOwnerFollowingsCount}',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 12),
                              // Profile info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          displayName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.purple[50],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.purple[200]!,
                                            ),
                                          ),
                                          child: Text(
                                            'Multi-Layer',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.purple[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'nostr:${postEvent.pubkey.substring(0, 8)}... • $timeAgo',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Event kind badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Text(
                                  'Kind ${postEvent.kind}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          // Content
                          if (postContent.isNotEmpty)
                            Text(
                              postContent.summarize(250),
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Colors.grey[800],
                              ),
                            )
                          else
                            Text(
                              'No content',
                              style: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[500],
                              ),
                            ),
                          SizedBox(height: 12),
                          // Footer with enriched data status
                          Row(
                            children: [
                              Icon(
                                Icons.layers,
                                size: 12,
                                color: Colors.purple[400],
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Profile + Followings enriched',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.purple[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              // Following count display
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange[200]!,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 12,
                                      color: Colors.orange[700],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '$postOwnerFollowingsCount following',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              // Action buttons
                              Row(
                                children: [
                                  _buildActionButton(
                                    icon: Icons.visibility,
                                    onTap: () =>
                                        _showEventWithProfileAndFollowings(
                                          context,
                                          postEvent,
                                          user,
                                          userFollowings,
                                        ),
                                  ),
                                  SizedBox(width: 8),
                                  _buildActionButton(
                                    icon: Icons.copy,
                                    onTap: () => _copyToClipboard(
                                      context,
                                      postEvent.id ?? '',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
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

  // Helper methods for the enhanced itemBuilder
  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 16, color: Colors.grey[600]),
      ),
    );
  }

  void _showEventWithProfileAndFollowings(
    BuildContext context,
    NostrEvent event,
    UserInfo? user,
    UserFollowings? followings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Event with Profile & Followings'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile section
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: (user?.picture.isNotEmpty ?? false)
                          ? NetworkImage(user!.picture)
                          : null,
                      backgroundColor: Colors.purple[100],
                      child: (user?.picture.isEmpty ?? true)
                          ? Text(
                              (user?.name.isNotEmpty ?? false)
                                  ? user!.name[0].toUpperCase()
                                  : 'A',
                            )
                          : null,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (user?.name.isNotEmpty ?? false)
                                ? user!.name
                                : 'Anonymous User',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'nostr:${event.pubkey.substring(0, 16)}...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Followings section
              if (followings != null) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: Colors.orange[700],
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Following ${followings.followings.length} users',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                      if (followings.followings.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          'Recent followings:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        ...followings.followings
                            .take(3)
                            .map(
                              (pubkey) => Text(
                                '• nostr:${pubkey.substring(0, 16)}...',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                        if (followings.followings.length > 3)
                          Text(
                            '... and ${followings.followings.length - 3} more',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
              // Event details
              _buildDetailRow('Event ID', event.id ?? 'No ID'),
              _buildDetailRow('Kind', event.kind.toString()),
              _buildDetailRow(
                'Created',
                DateTime.fromMillisecondsSinceEpoch(
                  (event.createdAt?.millisecondsSinceEpoch) ?? 0,
                ).toString(),
              ),
              _buildDetailRow('Content', event.content ?? 'No content'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(value, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
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

extension on String {
  String summarize(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}
