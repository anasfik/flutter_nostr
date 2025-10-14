import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nostr/components/feed/widgets/feed_widget.dart';
import 'package:flutter_nostr/cubit/nostr_feed_cubit/nostr_feed_cubit.dart';

class FlutterNostrFeed extends StatelessWidget {
  const FlutterNostrFeed({super.key, required this.filters});

  final List<NostrFilter> filters;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NostrFeedCubit(filters: filters),
      child: const FlutterNostrFeedWidget(),
    );
  }
}
