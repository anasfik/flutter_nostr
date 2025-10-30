import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nostr/flutter_nostr.dart';

/// A widget that fetches events from Nostr relays once and provides them to a builder function.
///
/// This widget is useful for one-time data fetching where you don't need continuous updates.
/// It uses a [FutureBuilder] internally and calls [FlutterNostr.instance.getEvents] to fetch
/// events based on the provided filters.
///
/// Unlike [FlutterNostrFeed], this builder does not automatically update when new events arrive.
/// It fetches once and displays the results.
///
/// Example usage:
/// ```dart
/// OneTimeEventsBuilder(
///   filters: [
///     NostrFilter(kinds: [1], limit: 10),
///   ],
///   builder: (context, isLoading, error, subscriptionId, events) {
///     if (isLoading) return CircularProgressIndicator();
///     if (error != null) return Text('Error: $error');
///     if (events == null || events.isEmpty) return Text('No events found');
///
///     return ListView.builder(
///       itemCount: events.length,
///       itemBuilder: (context, index) {
///         final event = events[index];
///         return ListTile(title: Text(event.content ?? ''));
///       },
///     );
///   },
/// )
/// ```
///
/// See also:
/// - [OneTimeEventBuilder] for fetching a single event
/// - [FlutterNostrFeed] for reactive feeds that update automatically
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

/// A widget that fetches a single event from Nostr relays once and provides it to a builder function.
///
/// This widget is useful for fetching one specific event, such as a user's profile metadata
/// or a specific note by its ID. It uses [OneTimeEventsBuilder] internally and returns only
/// the first event from the result set.
///
/// Unlike [FlutterNostrFeed], this builder does not automatically update when new events arrive.
/// It fetches once and displays the result.
///
/// Example usage:
/// ```dart
/// OneTimeEventBuilder(
///   filter: NostrFilter(
///     kinds: [0], // User profile
///     authors: ['user_pubkey_here'],
///   ),
///   builder: (context, isLoading, error, subscriptionId, event) {
///     if (isLoading) return CircularProgressIndicator();
///     if (error != null) return Text('Error: $error');
///     if (event == null) return Text('No profile found');
///
///     final profile = event.content; // Parse JSON profile data
///     return ProfileWidget(profile: profile);
///   },
/// )
/// ```
///
/// See also:
/// - [OneTimeEventsBuilder] for fetching multiple events
/// - [FlutterNostrFeed] for reactive feeds that update automatically
class OneTimeEventBuilder extends StatelessWidget {
  const OneTimeEventBuilder({
    super.key,
    required this.filter,
    required this.builder,
  });

  /// The Nostr filter to use for fetching the event
  final NostrFilter filter;

  /// Builder function that receives the context, loading state, error, subscription ID, and the event
  ///
  /// - `isLoading`: true while the event is being fetched
  /// - `error`: any error that occurred during fetching, or null if successful
  /// - `subscriptionId`: the subscription ID returned by the relay
  /// - `event`: the fetched event, or null if no event was found or an error occurred
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
