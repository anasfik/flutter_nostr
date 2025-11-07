import 'package:flutter/widgets.dart';
import 'package:flutter_nostr/flutter_nostr.dart';

class SessionsListBuilder extends StatelessWidget {
  const SessionsListBuilder({
    super.key,
    required this.builder,
    required this.sessionManager,
  });

  final Widget Function(BuildContext context, List<AuthSession> sessions)
  builder;
  final SessionManager sessionManager;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: sessionManager.allSessions(),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? sessionManager.allSessionsSync();

        return builder(context, sessions);
      },
    );
  }
}
