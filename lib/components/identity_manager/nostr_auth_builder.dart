import 'package:flutter/widgets.dart';
import 'package:flutter_nostr/data_source/nostr_service.dart';
import 'package:flutter_nostr/models/nostr_auth_options.dart';
import 'package:flutter_nostr/models/session_manager.dart';

typedef NostrAuthBuilderBuilder =
    Widget Function(BuildContext context, NostrAuthOptions options);

class NostrAuthBuilder extends StatefulWidget {
  const NostrAuthBuilder({super.key, required this.builder});

  final NostrAuthBuilderBuilder builder;

  @override
  State<NostrAuthBuilder> createState() => _NostrAuthBuilderState();
}

class _NostrAuthBuilderState extends State<NostrAuthBuilder> {
  // @override

  // void dispose() {
  //   _sessionManager.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final options = NostrAuthOptions(
          keysManager: NostrAuthKeysManager(
            generateNewKeysPair: () {
              return NostrService.instance.generateNewKeysPair();
            },
            getPublicKeyFromPrivateKey: (privateKey) {
              return NostrService.instance.getPublicKeyFromPrivateKey(
                privateKey,
              );
            },
            getPublicKeyFromKeysPair: (keysPair) {
              return NostrService.instance.getPublicKeyFromKeysPair(keysPair);
            },
          ),
          keysTransformer: NostrAuthKeysTransformer(
            npubToPubkey: (npub) {
              return NostrService.instance.npubToPubkey(npub);
            },
            nsecToPrivateKey: (nsec) {
              return NostrService.instance.nsecToPrivateKey(nsec);
            },
            privateKeyToNsec: (privateKey) {
              return NostrService.instance.privateKeyToNsec(privateKey);
            },
            pubkeyToNpub: (pubkey) {
              return NostrService.instance.pubkeyToNpub(pubkey);
            },
          ),
          sessionManager: SessionManager.instance,
        );

        return widget.builder(context, options);
      },
    );
  }
}
