import 'dart:async';
import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter_nostr/models/feed_builder_data.dart';
import 'package:flutter_nostr/models/parallel_request.dart';
import 'package:flutter_nostr/data_source/nostr_service.dart';

/// Executes parallel request chains with dynamic type handling.
///
/// This executor processes ParallelRequest chains by:
/// 1. Executing the current step's filters against the Nostr service
/// 2. Adapting the results using the provided adapter function
/// 3. If a next step exists, recursively executing it with the adapted results
/// 4. All types are handled dynamically to avoid type inference issues
class ParallelRequestExecutor {
  final NostrService _service;

  ParallelRequestExecutor({required NostrService service}) : _service = service;

  /// Executes a parallel request chain starting from the given root request.
  ///
  /// [rootRequest] - The first step in the parallel request chain
  /// [initialEvents] - Optional initial events to pass to the first step
  ///
  /// Returns a map containing all results from each step in the chain.
  Future<Map<String, ParallelEventsRequestResponse>> executeChain({
    required ParallelRequest rootRequest,
    List<NostrEvent>? initialEvents,
  }) async {
    final results = <String, ParallelEventsRequestResponse>{};

    await _executeStep(
      request: rootRequest,

      previousResults: initialEvents ?? [],
      results: results,
    );

    return results;
  }

  /// Recursively executes a single step in the parallel request chain.
  Future<void> _executeStep({
    required ParallelRequest request,

    required List<dynamic> previousResults,
    required Map<String, EventsRequestResponse> results,
  }) async {
    try {
      // Execute the current step's filters
      final (subId, events) = await _service.getEvents(
        filters: request.filters,
      );

      // Adapt the events using the provided adapter function
      final adaptedResults = <dynamic>[];
      for (final event in events) {
        try {
          final adapted = request.adapter(event);
          adaptedResults.add(adapted);
        } catch (e) {
          // Log adapter error but continue processing other events
          print('Adapter error for event ${event.id}: $e');
          rethrow;
        }
      }

      // Store results for this step
      results[request.id] = ParallelEventsRequestResponse(
        events: events,
        filters: request.filters,
        requestTime: DateTime.now(),
        subscriptionId: subId ?? '',
        adaptedResults: adaptedResults,
      );

      // If there's a next step, execute it with the adapted results
      if (request.next != null) {
        final nextRequest = request.next!(adaptedResults);
        await _executeStep(
          request: nextRequest,

          previousResults: adaptedResults,
          results: results,
        );
      }
    } catch (e) {
      // Store error for this step
      results[request.id] = ParallelEventsRequestResponse.error(error: e);
      rethrow;
    }
  }

  /// Executes multiple parallel request chains concurrently.
  ///
  /// [requests] - List of parallel request chains to execute
  /// [initialEvents] - Optional initial events to pass to all chains
  ///
  /// Returns a map where keys are request indices and values are the results.
  Future<Map<int, Map<String, dynamic>>> executeMultipleChains({
    required List<ParallelRequest> requests,
    List<NostrEvent>? initialEvents,
  }) async {
    final futures = <Future<Map<String, dynamic>>>[];

    for (int i = 0; i < requests.length; i++) {
      futures.add(
        executeChain(
          rootRequest: requests[i],
          initialEvents: initialEvents,
        ).then((result) => result),
      );
    }

    final results = await Future.wait(futures);
    final indexedResults = <int, Map<String, dynamic>>{};

    for (int i = 0; i < results.length; i++) {
      indexedResults[i] = results[i];
    }

    return indexedResults;
  }

  /// Executes a single parallel request step without chaining.
  ///
  /// [request] - The parallel request to execute
  /// [initialEvents] - Optional initial events to pass to the request
  ///
  /// Returns the adapted results from this single step.
  Future<List<dynamic>> executeSingleStep({
    required ParallelRequest request,
    List<NostrEvent>? initialEvents,
  }) async {
    try {
      // Execute the request's filters
      final (subId, events) = await _service.getEvents(
        filters: request.filters,
      );

      // Adapt the events using the provided adapter function
      final adaptedResults = <dynamic>[];
      for (final event in events) {
        try {
          final adapted = request.adapter(event);
          adaptedResults.add(adapted);
        } catch (e) {
          print('Adapter error for event ${event.id}: $e');
          rethrow;
        }
      }

      return adaptedResults;
    } catch (e) {
      print('Error executing single step: $e');
      rethrow;
    }
  }
}
