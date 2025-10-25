import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nostr/cubit/nostr_feed_cubit/nostr_feed_cubit.dart';
import 'package:flutter_nostr/flutter_nostr.dart';

class OneTimeEventsBuilder extends StatelessWidget {
  const OneTimeEventsBuilder({
    super.key,
    required this.filters,
    required this.builder,
  });

  final List<NostrFilter> filters;
  final Widget Function(
    BuildContext context,
    bool isLoading,
    Object? error,
    String? subscriptionId,
    List<NostrEvent>? events,
  )
  builder;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FlutterNostr.instance.getEvents(filters: filters),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final error = hasError ? snapshot.error : null;

        return builder(
          context,
          isLoading,
          error,
          snapshot.data?.$1,
          snapshot.data?.$2,
        );
      },
    );
  }
}

class OneTimeEventBuilder extends StatelessWidget {
  const OneTimeEventBuilder({
    super.key,
    required this.filter,
    required this.builder,
  });

  final NostrFilter filter;

  final Widget Function(
    BuildContext context,
    bool isLoading,
    Object? error,
    String? subscriptionId,
    NostrEvent? event,
  )
  builder;
  @override
  Widget build(BuildContext context) {
    return OneTimeEventsBuilder(
      filters: [filter],
      builder: (context, isLoading, error, subscriptionId, events) {
        final onlyFirstEventIfAny = events?.firstOrNull;

        return builder(
          context,
          isLoading,
          error,
          subscriptionId,
          onlyFirstEventIfAny,
        );
      },
    );
  }
}
