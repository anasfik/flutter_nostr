import 'dart:convert';
import 'package:example/screens/screen.dart';
import 'package:example/widgets/parsed_content_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nostr/flutter_nostr.dart';

class OneTimeEventScreen extends AppScreen {
  OneTimeEventScreen({
    super.key,
    super.title = "One-Time Event Builder",
    super.routeName = '/one_time_event',
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
                  title: Text('One-Time Event Builder'),
                  content: Text(
                    'This screen demonstrates the OneTimeEventBuilder and OneTimeEventsBuilder widgets.\n\n'
                    'Features:\n'
                    '• Fetches events once without continuous updates\n'
                    '• Perfect for profile data, single notes, or static content\n'
                    '• Shows loading, error, and success states\n'
                    '• More efficient than reactive feeds when updates aren\'t needed\n\n'
                    'Use this for scenarios where you want to fetch data once when the screen loads, '
                    'unlike FlutterNostrFeed which continuously updates.',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: One-Time Events (Multiple)
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'One-Time Events (Multiple)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Fetches multiple events once using OneTimeEventsBuilder',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            OneTimeEventsBuilder(
              filters: [
                NostrFilter(
                  kinds: [1], // Text notes
                  limit: 5,
                ),
              ],
              builder: (context, isLoading, error, subscriptionId, events) {
                if (isLoading) {
                  return Container(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Loading events...',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (error != null) {
                  return Container(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error loading events',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (events == null || events.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No events found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: events.map((event) {
                    return _buildEventCard(context, event);
                  }).toList(),
                );
              },
            ),

            Divider(height: 40),

            // Section 2: One-Time Event (Single)
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'One-Time Event (Single)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Fetches a single event using OneTimeEventBuilder',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            OneTimeEventBuilder(
              filter: NostrFilter(
                kinds: [1], // Text note
                limit: 1,
              ),
              builder: (context, isLoading, error, subscriptionId, event) {
                if (isLoading) {
                  return Container(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Loading event...',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (error != null) {
                  return Container(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error loading event',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (event == null) {
                  return Container(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No event found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return _buildEventCard(context, event);
              },
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, NostrEvent event) {
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
                          colors: [Colors.blue[400]!, Colors.purple[400]!],
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
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  maxLength: 200,
                  showMedia: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  void _showEventDetails(BuildContext context, NostrEvent event) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.purple[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.info_outline, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Event Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Kind ${event.kind}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Content preview
                      if (event.content?.isNotEmpty ?? false) ...[
                        _buildSection(
                          'Content',
                          ParsedContentRenderer(
                            text: event.content ?? '',
                            showMedia: true,
                          ),
                          context,
                        ),
                        Divider(height: 32),
                      ],
                      // Quick Actions
                      _buildSection(
                        'Quick Actions',
                        _buildQuickActions(context, event),
                        context,
                      ),
                      Divider(height: 32),
                      // Event Metadata
                      _buildSection('Metadata', _buildMetadata(event), context),
                      // Tags
                      if ((event.tags?.isNotEmpty ?? false)) ...[
                        Divider(height: 32),
                        _buildSection(
                          'Tags (${event.tags?.length ?? 0})',
                          _buildTags(event.tags!),
                          context,
                        ),
                      ],
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, NostrEvent event) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildActionButton(
          context,
          icon: Icons.content_copy,
          label: 'Copy Event ID',
          color: Colors.blue,
          onPressed: () => _copyEventId(context, event),
        ),
        _buildActionButton(
          context,
          icon: Icons.person,
          label: 'Copy Author',
          color: Colors.green,
          onPressed: () => _copyAuthor(context, event),
        ),
        _buildActionButton(
          context,
          icon: Icons.code,
          label: 'Copy as JSON',
          color: Colors.orange,
          onPressed: () => _copyAsJson(context, event),
        ),
        _buildActionButton(
          context,
          icon: Icons.link,
          label: 'Copy Note Link',
          color: Colors.purple,
          onPressed: () => _copyNoteLink(context, event),
        ),
        _buildActionButton(
          context,
          icon: Icons.share,
          label: 'Share Event',
          color: Colors.indigo,
          onPressed: () => _shareEvent(context, event),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildMetadata(NostrEvent event) {
    return Column(
      children: [
        _buildMetadataRow(Icons.tag, 'Event ID', event.id ?? 'N/A'),
        SizedBox(height: 12),
        _buildMetadataRow(Icons.person, 'Author (pubkey)', event.pubkey),
        SizedBox(height: 12),
        _buildMetadataRow(Icons.category, 'Kind', event.kind.toString()),
        SizedBox(height: 12),
        _buildMetadataRow(
          Icons.access_time,
          'Created At',
          DateTime.fromMillisecondsSinceEpoch(
            (event.createdAt?.millisecondsSinceEpoch ?? 0),
          ).toLocal().toString().substring(0, 19),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.blue[700]),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                SelectableText(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(List<List<String>> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        final tagType = tag.isNotEmpty ? tag[0] : 'unknown';
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.purple[50]!],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tagType,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  tag.skip(1).join(' '),
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _copyEventId(BuildContext context, NostrEvent event) async {
    if (event.id == null) return;
    await Clipboard.setData(ClipboardData(text: event.id!));
    _showSnackBar(context, 'Event ID copied to clipboard');
  }

  void _copyAuthor(BuildContext context, NostrEvent event) async {
    await Clipboard.setData(ClipboardData(text: event.pubkey));
    _showSnackBar(context, 'Author pubkey copied to clipboard');
  }

  void _copyAsJson(BuildContext context, NostrEvent event) async {
    final json = jsonEncode({
      'id': event.id,
      'pubkey': event.pubkey,
      'created_at': event.createdAt?.millisecondsSinceEpoch,
      'kind': event.kind,
      'tags': event.tags,
      'content': event.content,
      'sig': event.sig,
    });
    await Clipboard.setData(ClipboardData(text: json));
    _showSnackBar(context, 'Event copied as JSON to clipboard');
  }

  void _copyNoteLink(BuildContext context, NostrEvent event) async {
    final noteLink = 'nostr:${event.id}';
    await Clipboard.setData(ClipboardData(text: noteLink));
    _showSnackBar(context, 'Note link copied to clipboard');
  }

  void _shareEvent(BuildContext context, NostrEvent event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Share functionality can be implemented with share_plus package',
        ),
        duration: Duration(seconds: 2),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
