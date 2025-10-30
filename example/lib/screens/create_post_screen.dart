import 'package:flutter/material.dart';
import 'package:flutter_nostr/flutter_nostr.dart';
import 'package:flutter_nostr/models/auth_session.dart';
import 'package:flutter_nostr/models/nostr_auth_options.dart';
import 'package:flutter_nostr/components/identity_manager/nostr_auth_builder.dart';
import 'screen.dart';

class CreatePostScreen extends AppScreen {
  CreatePostScreen({
    super.key,
    super.title = "Create Post",
    super.routeName = '/create_post',
  });

  @override
  Widget build(BuildContext context) {
    return NostrAuthBuilder(
      builder: (context, options) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(title: Text(title)),
          body: _CreatePostContent(options: options),
        );
      },
    );
  }
}

class _CreatePostContent extends StatefulWidget {
  final NostrAuthOptions options;

  const _CreatePostContent({required this.options});

  @override
  State<_CreatePostContent> createState() => _CreatePostContentState();
}

class _CreatePostContentState extends State<_CreatePostContent> {
  final _controller = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BaseAuthSession?>(
      stream: widget.options.sessionManager.currentSessionStream,
      builder: (context, snapshot) {
        final currentSession = snapshot.data;
        final canPost = currentSession?.canSign ?? false;

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current session info
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        currentSession == null
                            ? Icons.account_circle_outlined
                            : Icons.account_circle,
                        size: 48,
                        color: canPost ? Colors.green : Colors.grey,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Session',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              currentSession?.pubkey ?? 'No active session',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              currentSession == null
                                  ? 'No session active'
                                  : canPost
                                  ? 'Can create posts'
                                  : 'Read-only (cannot post)',
                              style: TextStyle(
                                fontSize: 12,
                                color: canPost ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (currentSession != null)
                        Chip(
                          label: Text(currentSession.type.name),
                          backgroundColor: canPost
                              ? Colors.green[100]
                              : Colors.blue[100],
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Text input
              TextField(
                controller: _controller,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'What\'s on your mind?',
                  hintText: 'Enter your post here...',
                  border: OutlineInputBorder(),
                ),
                enabled: canPost && !_isPosting,
              ),
              SizedBox(height: 16),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: canPost && !_isPosting
                          ? _createAndPostEvent
                          : null,
                      icon: Icon(Icons.send),
                      label: Text('Post'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  if (!canPost && currentSession != null)
                    Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Tooltip(
                        message:
                            'This is a read-only session. Go to Auth Demo to create a writable session.',
                        child: Icon(Icons.info, color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
              if (!canPost && currentSession == null) ...[
                SizedBox(height: 16),
                Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No Active Session',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Go to Authentication Demo to create a session',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/auth'),
                          child: Text('Go to Auth'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (canPost) ...[
                SizedBox(height: 24),
                Divider(),
                SizedBox(height: 8),
                Text(
                  'Post Options',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Note: Your post will be signed with your ${currentSession?.type.name ?? 'private key'} and sent to the Nostr relay.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _createAndPostEvent() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter some content')));
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final currentSession = widget.options.sessionManager.currentSession;

      if (currentSession == null || !currentSession.canSign) {
        throw Exception('No active session that can sign');
      }

      // Create event using the session
      final event = await currentSession.createEvent(
        kind: 1, // Text note
        content: _controller.text.trim(),
        tags: [],
      );

      // Send event to relay
      await FlutterNostr.instance.sendEvent(event);

      // Clear input
      _controller.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Post created successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }
}
