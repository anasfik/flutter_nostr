import 'package:dart_nostr/dart_nostr.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class FlutterNostrFeedBuilderOptions extends Equatable {
  final VoidCallback? loadMore;
  final VoidCallback? refresh;
  final VoidCallback? onRunParallelRequest;
  final void Function(NostrEvent event)? onRegisterEntityForNextParallelRequest;

  const FlutterNostrFeedBuilderOptions({
    this.loadMore,
    this.refresh,
    this.onRunParallelRequest,
    this.onRegisterEntityForNextParallelRequest,
  });

  @override
  List<Object?> get props => [
    loadMore,
    refresh,
    onRunParallelRequest,
    onRegisterEntityForNextParallelRequest,
  ];
}
