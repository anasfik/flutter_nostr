import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class FlutterNostrFeedBuilderOptions extends Equatable {
  final VoidCallback? loadMore;
  final VoidCallback? refresh;

  const FlutterNostrFeedBuilderOptions({this.loadMore, this.refresh});
  @override
  List<Object?> get props => [loadMore];
}
