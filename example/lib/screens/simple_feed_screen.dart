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
              final timestamp = DateTime.fromMillisecondsSinceEpoch(
                (event.createdAt?.millisecondsSinceEpoch ?? 0),
              );
              final timeAgo = _getTimeAgo(timestamp);
              final authorShort = event.pubkey.substring(0, 8);

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
                    onTap: () {
                      // Show event details
                      _showEventDetails(context, event);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with author and timestamp
                          Row(
                            children: [
                              // Author avatar placeholder
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue[400]!,
                                      Colors.purple[400]!,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    authorShort.substring(0, 2).toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              // Author info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'nostr:${authorShort}...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    Text(
                                      timeAgo,
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
                          // Content
                          if (text.isNotEmpty)
                            Linkify(
                              text: text.summarize(200),
                              linkifiers: [UrlLinkifier()],
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Colors.grey[800],
                              ),
                              linkStyle: TextStyle(
                                color: Colors.blue[600],
                                decoration: TextDecoration.underline,
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
                          // Footer with event ID
                          Row(
                            children: [
                              Icon(
                                Icons.fingerprint,
                                size: 12,
                                color: Colors.grey[400],
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${(event.id ?? '').substring(0, 16)}...',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[400],
                                    fontFamily: 'monospace',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Interaction buttons
                              Row(
                                children: [
                                  _buildActionButton(
                                    icon: Icons.copy,
                                    onTap: () => _copyToClipboard(
                                      context,
                                      event.id ?? '',
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  _buildActionButton(
                                    icon: Icons.share,
                                    onTap: () => _shareEvent(context, event),
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

  void _showEventDetails(BuildContext context, NostrEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Event Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', event.id ?? 'No ID'),
              _buildDetailRow('Author', event.pubkey),
              _buildDetailRow('Kind', event.kind.toString()),
              _buildDetailRow(
                'Created',
                DateTime.fromMillisecondsSinceEpoch(
                  (event.createdAt?.millisecondsSinceEpoch ?? 0),
                ).toString(),
              ),
              _buildDetailRow('Content', event.content ?? 'No content'),
              if ((event.tags?.isNotEmpty ?? false)) ...[
                SizedBox(height: 8),
                Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(event.tags ?? []).map((tag) => Text('• ${tag.join(' ')}')),
              ],
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
    // Note: You'll need to add flutter/services to imports for Clipboard
    // Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareEvent(BuildContext context, NostrEvent event) {
    // Note: You'll need to add share_plus package for actual sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality would be implemented here'),
        duration: Duration(seconds: 2),
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
