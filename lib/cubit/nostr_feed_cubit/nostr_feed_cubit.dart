import 'dart:async';

import 'package:dart_nostr/dart_nostr.dart';
import 'package:equatable/equatable.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nostr/data_source/nostr_service.dart';
import 'package:flutter_nostr/data_source/parallel_request_executor.dart';
import 'package:flutter_nostr/flutter_nostr.dart';
import 'package:flutter_nostr/models/feed_builder_data.dart';

part 'nostr_feed_state.dart';

class NostrFeedCubit extends Cubit<NostrFeedState> {
  final List<NostrFilter> filters;

  final NostrService service;
  final ParallelRequest Function(List<NostrEvent> events)?
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
      if (state.isLoading) {
        // request is already in progress
        return;
      }

      emit(state.copyWith(isLoading: true));

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

      emit(
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

      unawaited(_executeParallelRequestIfNeeded(events));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    } finally {
      emit(state.copyWith(isLoading: false));
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
    emit(NostrFeedInitial(eventsRequestResponseEntries: []));
  }

  Future<void> _executeParallelRequestIfNeeded(List<NostrEvent> events) async {
    final rootReq = parallelRequestRequestsHandler?.call(events);

    if (rootReq != null) {
      try {
        final results = await _executor.executeChain(
          rootRequest: rootReq,
          initialEvents: events,
        );

        final parallelRequestResults = state.parallelRequestResults;

        results.entries.forEach((entry) {
          parallelRequestResults?[entry.key] = [
            ...?parallelRequestResults[entry.key],
            entry.value,
          ];
        });

        // Emit the parallel request results to the state
        emit(state.copyWith(parallelRequestResults: parallelRequestResults));
      } catch (e) {
        print('Error executing parallel request: $e');
        emit(state.copyWith(error: 'Parallel request failed: $e'));
      }
    }
  }
}
