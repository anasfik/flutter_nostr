import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nostr/components/identity_manager/current_session_builder.dart';
import 'package:flutter_nostr/components/identity_manager/sessions_list_builder.dart';
import 'package:flutter_nostr/flutter_nostr.dart';
import 'package:flutter_nostr/models/auth_session.dart';
import 'package:flutter_nostr/models/nostr_auth_options.dart';
import 'package:flutter_nostr/components/identity_manager/nostr_auth_builder.dart';
import 'screen.dart';

class AuthScreen extends AppScreen {
  AuthScreen({
    super.key,
    super.title = "Authentication Demo",
    super.routeName = '/auth',
  });

  @override
  Widget build(BuildContext context) {
    return NostrAuthBuilder(
      builder: (context, options) {
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
                      title: Text('Authentication System'),
                      content: Text(
                        'This screen demonstrates the authentication system:\n\n'
                        '• Private Key: Sign events locally\n'
                        '• Bunker: Sign events remotely (coming soon)\n'
                        '• Pubkey: Read-only sessions\n\n'
                        'Sessions are managed by SessionManager.',
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
          body: _AuthContent(options: options),
        );
      },
    );
  }
}

class _AuthContent extends StatelessWidget {
  final NostrAuthOptions options;

  const _AuthContent({required this.options});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentSessionCard(context),
          SizedBox(height: 24),
          _buildCreateSessionSection(context),
          SizedBox(height: 24),
          _buildSessionsList(context),
        ],
      ),
    );
  }

  Widget _buildCurrentSessionCard(BuildContext context) {
    return CurrentSessionBuilder(
      sessionManager: options.sessionManager,
      builder: (context, currentSession) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: currentSession != null
                    ? [Colors.blue[400]!, Colors.purple[400]!]
                    : [Colors.grey[400]!, Colors.grey[600]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_circle, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Session',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            currentSession?.pubkey ?? 'No active session',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (currentSession != null)
                      Chip(
                        label: Text(currentSession.type.name.toUpperCase()),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                if (currentSession != null) ...[
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        currentSession.canSign
                            ? 'Can sign events'
                            : 'Read-only',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateSessionSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New Session',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSessionTypeButton(
                  context,
                  icon: Icons.key,
                  label: 'Private Key',
                  color: Colors.green,
                  onPressed: () => _showPrivateKeyDialog(context),
                ),
                _buildSessionTypeButton(
                  context,
                  icon: Icons.cloud,
                  label: 'Bunker',
                  color: Colors.orange,
                  onPressed: () => _showBunkerDialog(context),
                ),
                _buildSessionTypeButton(
                  context,
                  icon: Icons.person,
                  label: 'Pubkey Only',
                  color: Colors.blue,
                  onPressed: () => _showPubkeyDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTypeButton(
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

  Widget _buildSessionsList(BuildContext context) {
    return SessionsListBuilder(
      sessionManager: options.sessionManager,
      builder: (context, sessions) {
        return CurrentSessionBuilder(
          sessionManager: options.sessionManager,
          builder: (context, currentSession) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Sessions (${sessions.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    if (sessions.isEmpty) ...[
                      SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_circle_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No sessions yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      SizedBox(height: 12),
                      ...sessions.map(
                        (session) => _buildSessionItem(
                          context,
                          session,
                          currentSession?.id != null &&
                              session.id == currentSession?.id,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSessionItem(
    BuildContext context,
    BaseAuthSession session,
    bool isCurrent,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor(session.type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(session.type),
              color: _getTypeColor(session.type),
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.type.name.substring(0, 1).toUpperCase()}${session.type.name.substring(1)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  session.pubkey.substring(0, 16) + '...',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isCurrent)
            Chip(
              label: Text('Active'),
              backgroundColor: Colors.green.withOpacity(0.2),
              labelStyle: TextStyle(
                color: Colors.green[800],
                fontWeight: FontWeight.bold,
              ),
            )
          else ...[
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteSession(context, session),
            ),
            IconButton(
              icon: Icon(Icons.remove_red_eye, color: Colors.purpleAccent),
              onPressed: () => _userDetailsScreen(context, session),
            ),

            IconButton(
              icon: Icon(Icons.login, color: Colors.blue),
              onPressed: () => _switchSession(context, session),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTypeColor(AuthType type) {
    switch (type) {
      case AuthType.privateKey:
        return Colors.green;
      case AuthType.bunker:
        return Colors.orange;
      case AuthType.pubkey:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(AuthType type) {
    switch (type) {
      case AuthType.privateKey:
        return Icons.key;
      case AuthType.bunker:
        return Icons.cloud;
      case AuthType.pubkey:
        return Icons.person;
    }
  }

  void _showPrivateKeyDialog(BuildContext context) {
    final privateKeyController = TextEditingController();
    final generatedKeyController = TextEditingController();
    bool useGeneratedKey = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Create Private Key Session'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Generate new key option
                  Card(
                    color: Colors.blue[50],
                    child: InkWell(
                      onTap: () {
                        final newKeys = options.keysManager
                            .generateNewKeysPair();
                        generatedKeyController.text = newKeys.privateKey;
                        setState(() {
                          useGeneratedKey = true;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.refresh, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Generate New Key',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                  Text(
                                    'Create a new key pair',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Or enter existing key
                  Row(
                    children: [
                      Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Generated key display
                  if (useGeneratedKey &&
                      generatedKeyController.text.isNotEmpty) ...[
                    Text(
                      'Generated Private Key:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              generatedKeyController.text,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy, size: 18),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: generatedKeyController.text,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Save this key securely. You won\'t be able to recover it!',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  // Manual entry
                  Text(
                    useGeneratedKey
                        ? 'Use generated key'
                        : 'Enter existing private key',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: privateKeyController,
                    enabled: !useGeneratedKey,
                    decoration: InputDecoration(
                      labelText: 'Enter private key',
                      hintText: 'nsec... or hex key',
                      border: OutlineInputBorder(),
                      helperText: useGeneratedKey
                          ? 'Using generated key'
                          : 'Enter your existing private key',
                    ),
                    obscureText: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final keyToUse = useGeneratedKey
                      ? generatedKeyController.text
                      : privateKeyController.text;
                  if (keyToUse.isNotEmpty) {
                    _createPrivateKeySession(context, keyToUse);

                    Navigator.of(context).pop();
                  }
                },
                icon: Icon(Icons.check),
                label: Text('Create Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: useGeneratedKey ? Colors.green : Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBunkerDialog(BuildContext context) {
    final bunkerUrlController = TextEditingController();
    final tokenController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Bunker Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: bunkerUrlController,
              decoration: InputDecoration(
                labelText: 'Bunker URL',
                hintText: 'https://bunker.example.com',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: tokenController,
              decoration: InputDecoration(
                labelText: 'Token (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _createBunkerSession(
              context,
              bunkerUrlController.text,
              tokenController.text,
            ),
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showPubkeyDialog(BuildContext context) {
    final pubkeyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Pubkey Session'),
        content: TextField(
          controller: pubkeyController,
          decoration: InputDecoration(
            labelText: 'Enter pubkey',
            hintText: 'npub... or hex key',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                _createPubkeySession(context, pubkeyController.text),
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _createPrivateKeySession(
    BuildContext context,
    String privateKey,
  ) async {
    if (privateKey.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a private key')));
      return;
    }

    try {
      final pubkey = options.keysManager.getPublicKeyFromPrivateKey(privateKey);
      final session = PrivateKeyAuthSession(
        createdAt: DateTime.now(),

        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pubkey: pubkey,
        privateKey: privateKey,
      );

      await options.sessionManager.addSession(session);
      await options.sessionManager.switchSession(session);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Private key session created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _createBunkerSession(
    BuildContext context,
    String bunkerUrl,
    String token,
  ) async {
    if (bunkerUrl.isEmpty) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a bunker URL')));
      return;
    }

    try {
      final session = BunkerAuthSession(
        createdAt: DateTime.now(),

        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pubkey: '', // Would be set by bunker service
        bunkerUrl: bunkerUrl,
        token: token.isEmpty ? null : token,
      );

      await options.sessionManager.addSession(session);
      await options.sessionManager.switchSession(session);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bunker session created successfully')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _createPubkeySession(
    BuildContext context,
    String pubkeyInput,
  ) async {
    if (pubkeyInput.isEmpty) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a pubkey')));
      return;
    }

    try {
      String pubkey;
      if (pubkeyInput.startsWith('npub')) {
        pubkey = options.keysTransformer.npubToPubkey(pubkeyInput);
      } else {
        pubkey = pubkeyInput;
      }

      final session = PubkeyAuthSession(
        createdAt: DateTime.now(),

        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pubkey: pubkey,
      );

      await options.sessionManager.addSession(session);
      await options.sessionManager.switchSession(session);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pubkey session created successfully')),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _deleteSession(
    BuildContext context,
    BaseAuthSession session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Session'),
        content: Text('Are you sure you want to delete this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await options.sessionManager.removeSession(session);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Session deleted')));
    }
  }

  Future<void> _switchSession(
    BuildContext context,
    BaseAuthSession session,
  ) async {
    await options.sessionManager.switchSession(session);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Switched to ${session.type.name} session')),
    );
  }

  Future<void> _userDetailsScreen(
    BuildContext context,
    BaseAuthSession session,
  ) async {
    await Navigator.pushNamed(context, '/user', arguments: session.pubkey);
  }
}
