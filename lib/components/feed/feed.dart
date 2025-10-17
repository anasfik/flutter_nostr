import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nostr/components/feed/widgets/feed_widget.dart';
import 'package:flutter_nostr/cubit/nostr_feed_cubit/nostr_feed_cubit.dart';
import 'package:flutter_nostr/flutter_nostr.dart';
import 'package:flutter_nostr/models/feed_builder_data.dart';
import 'package:flutter_nostr/models/feed_builder_options.dart';

class FlutterNostrFeed extends StatelessWidget {
  const FlutterNostrFeed({
    super.key,
    required this.filters,
    this.parallelRequestRequestsHandler,
    required this.builder,
  });

  final List<NostrFilter> filters;
  final ParallelRequest Function(
    Map<String, List<ParallelEventsRequestResponse>> parallelRequestResults,
    List<NostrEvent> events,
  )?
  parallelRequestRequestsHandler;

  final Widget Function(
    BuildContext context,

    FlutterNostrFeedBuilderData data,
    FlutterNostrFeedBuilderOptions options,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NostrFeedCubit(
        filters: filters,
        service: FlutterNostr.instance,
        parallelRequestRequestsHandler: parallelRequestRequestsHandler,
      ),
      child: FlutterNostrFeedWidget(builder: builder),
    );
  }
}
