import 'package:dart_nostr/dart_nostr.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_nostr/flutter_nostr.dart';

class FlutterNostrFeedBuilderData<T> extends Equatable {
  List<NostrEvent>? _eventsListToBeCalculatedOnce;

  final bool isLoading;
  final List<EventsRequestResponse> eventRequestResponseEntries;
  final Map<String, List<ParallelEventsRequestResponse>>?
  parallelRequestResults;
  final int iterativeRequestCount;
  final String? error;

  FlutterNostrFeedBuilderData({
    required this.isLoading,
    required this.iterativeRequestCount,
    required this.error,
    this.parallelRequestResults = const {},
    this.eventRequestResponseEntries = const [],
  });

  List<ParallelEventsRequestResponse<T>>? locateParallelRequestResultsById<T>(
    ParallelRequestId<T> requestId,
  ) {
    final parralelRequests = parallelRequestResults?[requestId.id];

    final casted = parralelRequests?.map((prr) {
      return ParallelEventsRequestResponse.casted<T>(prr);
    }).toList();

    return casted;
  }

  List<NostrEvent> get events {
    if (_eventsListToBeCalculatedOnce != null) {
      return _eventsListToBeCalculatedOnce!;
    }

    _eventsListToBeCalculatedOnce = eventRequestResponseEntries
        .expand((e) => e.events)
        .toList();

    _eventsListToBeCalculatedOnce!.sort(
      (a, b) => b.createdAt?.compareTo(a.createdAt ?? DateTime.now()) ?? 0,
    );

    return _eventsListToBeCalculatedOnce!;
  }

  @override
  List<Object?> get props => [
    isLoading,
    iterativeRequestCount,
    error,
    eventRequestResponseEntries,
    parallelRequestResults,
  ];
}

class EventsRequestResponse extends Equatable {
  final DateTime requestTime;
  final List<NostrEvent> events;

  final String subscriptionId;
  final List<NostrFilter> filters;

  const EventsRequestResponse({
    required this.subscriptionId,
    required this.filters,
    required this.events,
    required this.requestTime,
  });

  @override
  List<Object?> get props => [subscriptionId, filters, events, requestTime];
}

class ParallelEventsRequestResponse<T> extends EventsRequestResponse {
  final List<T> adaptedResults;
  final Object? error;

  const ParallelEventsRequestResponse({
    required super.subscriptionId,
    required super.filters,
    required super.events,
    required super.requestTime,
    required this.adaptedResults,
    this.error,
  });

  factory ParallelEventsRequestResponse.error({required Object error}) {
    return ParallelEventsRequestResponse(
      subscriptionId: "",
      filters: [],
      events: [],
      requestTime: DateTime.now(),
      adaptedResults: [],
      error: error,
    );
  }
  @override
  List<Object?> get props => super.props..addAll([adaptedResults, error]);

  static ParallelEventsRequestResponse<T> casted<T>(
    ParallelEventsRequestResponse prr,
  ) {
    return ParallelEventsRequestResponse(
      subscriptionId: prr.subscriptionId,
      filters: prr.filters,
      events: prr.events,
      requestTime: prr.requestTime,
      adaptedResults: [...prr.adaptedResults.whereType<T>()],
      error: prr.error,
    );
  }
}

extension A<T> on List<ParallelEventsRequestResponse<T>> {
  List<T>? get adaptedResults {
    return map((e) => e.adaptedResults).expand((e) => e).toList();
  }
}
