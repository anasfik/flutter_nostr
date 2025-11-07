import 'package:flutter/widgets.dart';
import 'package:flutter_nostr/flutter_nostr.dart';

class CurrentSessionBuilder extends StatelessWidget {
  const CurrentSessionBuilder({
    super.key,
    required this.builder,
    required this.sessionManager,
  });

  final Widget Function(BuildContext context, AuthSession? session) builder;
  final SessionManager sessionManager;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: sessionManager.currentSessionStream,
      builder: (context, snapshot) {
        final currentSession = snapshot.data ?? sessionManager.currentSession;

        return builder(context, currentSession);
      },
    );
  }
}
