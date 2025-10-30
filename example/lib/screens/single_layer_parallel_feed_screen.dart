import 'dart:convert';

import 'package:example/screens/screen.dart';
import 'package:example/widgets/parsed_content_renderer.dart';
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
              final timestamp = DateTime.fromMillisecondsSinceEpoch(
                (event.createdAt?.millisecondsSinceEpoch ?? 0),
              );
              final timeAgo = _getTimeAgo(timestamp);

              // Use fetched profile results (single layer)
              final profileFetchResults = data.parallelRequestResultsFor(
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

              final displayName = user.name.isNotEmpty
                  ? user.name
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
                    onTap: () => _showEventWithProfile(context, event, user),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with profile info
                          Row(
                            children: [
                              // Profile avatar
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.blue[200]!,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundImage: image,
                                  backgroundColor: Colors.blue[100],
                                  child: image == null
                                      ? Text(
                                          displayName
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        )
                                      : null,
                                ),
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
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.green[200]!,
                                            ),
                                          ),
                                          child: Text(
                                            'Profile Loaded',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.green[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'nostr:${event.pubkey.substring(0, 8)}... • $timeAgo',
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
                                  'Kind ${event.kind}',
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
                          // Content with parsing
                          ParsedContentRenderer(
                            text: text,
                            maxLength: 250,
                            showMedia: false,
                          ),
                          SizedBox(height: 12),
                          // Footer with profile status and actions
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 12,
                                color: Colors.green[400],
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Profile enriched',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              // Action buttons
                              Row(
                                children: [
                                  _buildActionButton(
                                    icon: Icons.visibility,
                                    onTap: () => _showEventWithProfile(
                                      context,
                                      event,
                                      user,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  _buildActionButton(
                                    icon: Icons.copy,
                                    onTap: () => _copyToClipboard(
                                      context,
                                      event.id ?? '',
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

  void _showEventWithProfile(
    BuildContext context,
    NostrEvent event,
    UserInfo user,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Event with Profile'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile section
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: user.picture.isNotEmpty
                          ? NetworkImage(user.picture)
                          : null,
                      backgroundColor: Colors.blue[100],
                      child: user.picture.isEmpty
                          ? Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
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
                            user.name.isNotEmpty ? user.name : 'Anonymous User',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'nostr:${user.pubkey.substring(0, 16)}...',
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
              // Event details
              _buildDetailRow('Event ID', event.id ?? 'No ID'),
              _buildDetailRow('Kind', event.kind.toString()),
              _buildDetailRow(
                'Created',
                DateTime.fromMillisecondsSinceEpoch(
                  (event.createdAt?.millisecondsSinceEpoch ?? 0),
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
