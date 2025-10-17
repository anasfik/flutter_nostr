import 'dart:async';

import 'package:dart_nostr/dart_nostr.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nostr/data_source/nostr_service.dart';

import 'package:flutter_nostr/flutter_nostr.dart';

part 'nostr_feed_state.dart';

class NostrFeedCubit extends Cubit<NostrFeedState> {
  final List<NostrFilter> filters;
  List<NostrEvent> eventsQueueList = [];

  // Queue of pending batches to process sequentially
  final List<List<NostrEvent>> _pendingParallelBatches = [];
  bool _isProcessingParallel = false;

  final NostrService service;

  final ParallelRequest Function(
    Map<String, List<ParallelEventsRequestResponse>> parallelRequestResults,
    List<NostrEvent> events,
  )?
  parallelRequestRequestsHandler;

  late final ParallelRequestExecutor _executor;

  NostrFeedCubit({
    required this.filters,
    required this.service,
    this.parallelRequestRequestsHandler,
  }) : super(NostrFeedInitial(eventsRequestResponseEntries: [])) {
    _executor = ParallelRequestExecutor(service: service);
    loadLayerOneFeedData();
  }

  Future<void> loadLayerOneFeedData({DateTime? since, DateTime? until}) async {
    try {
      emitIfNotClosed(state.copyWith(isLoading: true));

      final (subId, events) = await service.getEvents(
        filters: filters.map((filter) {
          return NostrFilter(
            ids: filter.ids,
            authors: filter.authors,
            kinds: filter.kinds,
            e: filter.e,
            p: filter.p,
            t: filter.t,
            since: since ?? filter.since,
            until: until ?? filter.until,
            limit: filter.limit,
            search: filter.search,
            a: filter.a,
            additionalFilters: filter.additionalFilters,
          );
        }).toList(),
      );

      emitIfNotClosed(
        state.copyWith(
          eventsRequestResponseEntries: [
            ...state.eventsRequestResponseEntries,
            EventsRequestResponse(
              events: events,
              filters: filters,
              subscriptionId: subId ?? '',
              requestTime: DateTime.now(),
            ),
          ],
          // important, because in future I will implement option to register failer requests, so this will be used to index successfully requests only.
          iterativeRequestCount: state.iterativeRequestCount + 1,
        ),
      );
    } catch (e) {
      emitIfNotClosed(state.copyWith(error: e.toString()));
    } finally {
      emitIfNotClosed(state.copyWith(isLoading: false));
    }
  }

  Future<void> loadMore() async {
    if (state.eventsRequestResponseEntries.isEmpty) {
      await loadLayerOneFeedData();
      return;
    }

    final lastEvent = state.eventsRequestResponseEntries.last.events.reduce((
      value,
      element,
    ) {
      if (value.createdAt?.isBefore(element.createdAt ?? DateTime.now()) ??
          false) {
        return value;
      }
      return element;
    });

    DateTime? until = lastEvent.createdAt;

    await loadLayerOneFeedData(
      until: until?.subtract(Duration(milliseconds: 400)),
    );
  }

  Future<void> refresh() async {
    _clearData();
    await loadLayerOneFeedData();
  }

  void _clearData() {
    emitIfNotClosed(NostrFeedInitial(eventsRequestResponseEntries: []));
  }

  Future<void> executeParallelRequestIfNeeded() async {
    final eventsToTriggerEventsFor = [...eventsQueueList];
    eventsQueueList.clear();

    if (eventsToTriggerEventsFor.isEmpty) {
      return;
    }

    // Enqueue this batch
    _pendingParallelBatches.add(eventsToTriggerEventsFor);

    // Start processor if not already running
    if (_isProcessingParallel) return;
    _isProcessingParallel = true;

    try {
      while (_pendingParallelBatches.isNotEmpty) {
        final events = _pendingParallelBatches.removeAt(0);

        final rootReq = parallelRequestRequestsHandler?.call(
          state.parallelRequestResults,
          events,
        );

        if (rootReq == null) {
          continue;
        }

        try {
          final results = await _executor.executeChain(
            rootRequest: rootReq,
            initialEvents: events,
          );

          final parallelRequestResults = {...state.parallelRequestResults};

          results.entries.forEach((entry) {
            parallelRequestResults[entry.key] = [
              ...?parallelRequestResults[entry.key],
              entry.value,
            ];
          });

          // Emit the parallel request results to the state
          emitIfNotClosed(
            state.copyWith(parallelRequestResults: parallelRequestResults),
          );
        } catch (e) {
          print('Error executing parallel request: $e');

          emitIfNotClosed(state.copyWith(error: 'Parallel request failed: $e'));
        }
      }
    } finally {
      _isProcessingParallel = false;
    }
  }

  void registerEntityForNextParallelRequest(NostrEvent event) {
    eventsQueueList.add(event);

    _debounceExecuteParallelRequest();
  }

  Timer? _debounceTimer;

  void _debounceExecuteParallelRequest() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      executeParallelRequestIfNeeded();
    });
  }

  void emitIfNotClosed(NostrFeedState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }
}
