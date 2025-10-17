import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nostr/cubit/nostr_feed_cubit/nostr_feed_cubit.dart';
import 'package:flutter_nostr/models/feed_builder_data.dart';
import 'package:flutter_nostr/models/feed_builder_options.dart';

class FlutterNostrFeedWidget extends StatelessWidget {
  const FlutterNostrFeedWidget({super.key, required this.builder});

  final Widget Function(
    BuildContext context,

    FlutterNostrFeedBuilderData data,
    FlutterNostrFeedBuilderOptions options,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NostrFeedCubit>();

    return BlocBuilder<NostrFeedCubit, NostrFeedState>(
      builder: (context, state) {
        final data = FlutterNostrFeedBuilderData(
          error: state.error,
          eventRequestResponseEntries: state.eventsRequestResponseEntries,
          iterativeRequestCount: state.iterativeRequestCount,
          isLoading: state.isLoading,
          parallelRequestResults: state.parallelRequestResults,
        );

        final options = FlutterNostrFeedBuilderOptions(
          loadMore: cubit.loadMore,
          refresh: cubit.refresh,
          onRegisterEntityForNextParallelRequest: (NostrEvent event) {
            cubit.registerEntityForNextParallelRequest(event);
          },
          onRunParallelRequest: () {
            cubit.executeParallelRequestIfNeeded();
          },
        );

        return builder(context, data, options);
      },
    );
  }
}
