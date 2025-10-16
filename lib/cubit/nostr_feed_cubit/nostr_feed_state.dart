part of 'nostr_feed_cubit.dart';

class NostrFeedState extends Equatable {
  final List<EventsRequestResponse> eventsRequestResponseEntries;
  final (List<EventsRequestResponse>, List<dynamic>)
  parallelRequestResponseEntries;
  final Map<String, List<ParallelEventsRequestResponse>>?
  parallelRequestResults;
  final String? error;
  final int iterativeRequestCount;
  final bool isLoading;

  const NostrFeedState({
    required this.eventsRequestResponseEntries,
    this.parallelRequestResponseEntries = (const [], const []),
    this.parallelRequestResults,
    this.error,
    this.isLoading = false,
    this.iterativeRequestCount = 0,
  });

  NostrFeedState copyWith({
    List<EventsRequestResponse>? eventsRequestResponseEntries,
    (List<EventsRequestResponse>, List<dynamic>)?
    parallelRequestResponseEntries,
    Map<String, List<ParallelEventsRequestResponse>>? parallelRequestResults,
    String? error,
    bool? isLoading,
    int? iterativeRequestCount = 0,
  }) {
    return NostrFeedState(
      parallelRequestResponseEntries:
          parallelRequestResponseEntries ?? this.parallelRequestResponseEntries,
      parallelRequestResults:
          parallelRequestResults ?? this.parallelRequestResults,
      eventsRequestResponseEntries:
          eventsRequestResponseEntries ?? this.eventsRequestResponseEntries,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      iterativeRequestCount:
          iterativeRequestCount ?? this.iterativeRequestCount,
    );
  }

  @override
  List<Object?> get props => [
    eventsRequestResponseEntries,
    error,
    isLoading,
    iterativeRequestCount,
    parallelRequestResponseEntries,
    parallelRequestResults,
  ];
}

final class NostrFeedInitial extends NostrFeedState {
  const NostrFeedInitial({required super.eventsRequestResponseEntries});
}
