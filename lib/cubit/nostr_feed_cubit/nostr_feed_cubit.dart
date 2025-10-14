import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'nostr_feed_state.dart';

class NostrFeedCubit extends Cubit<NostrFeedState> {
  final List<NostrFilter> filters;

  NostrFeedCubit({required this.filters}) : super(NostrFeedInitial());
}
