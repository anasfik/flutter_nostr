import 'package:dart_nostr/dart_nostr.dart';
import 'package:equatable/equatable.dart';

/// A single step in a parallel request chain.
///
/// - T is the adapted result type of this step.
/// - [adapter] maps a fetched `NostrEvent` to a `T`.
/// - [filters] describes the current request. You can compute them using
///   captured values when you build the chain.
/// - [next] is an optional builder that receives ALL adapted results of the
///   current step (List<T>) and returns the next `ParallelRequest<U>`.
class ParallelRequest<T> extends Equatable {
  final List<NostrFilter> filters;
  final T Function(NostrEvent event) adapter;
  final String id;

  /// Build the next request using the results of this step.
  /// If provided, it will be invoked with the full List<T> produced by this step.
  /// Note: For better type inference, use the then<U>() method instead.
  final ParallelRequest Function(List<T> previousResults)? next;

  const ParallelRequest({
    required this.filters,
    required this.adapter,
    required this.id,
    this.next,
  });

  /// Fluent helper to attach a next step with full type inference.
  ParallelRequest<T> then<U>(
    ParallelRequest<U> Function(List<T> previousResults) buildNext,
  ) {
    return ParallelRequest<T>(
      filters: filters,
      id: id,
      adapter: adapter,
      next: (prev) => buildNext(prev),
    );
  }

  @override
  List<Object?> get props => [filters, adapter, next];
}
