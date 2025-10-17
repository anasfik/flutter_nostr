import 'package:dart_nostr/dart_nostr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nostr/models/feed_builder_data.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_nostr/models/feed_builder_options.dart';

class FlutterNostrFeedList extends StatelessWidget {
  const FlutterNostrFeedList({
    super.key,
    required this.data,
    required this.options,
    this.loadingBuilder,
    this.errorBuilder,
    this.itemBuilder,
    this.emptyBuilder,
    this.listBuilder,
  });

  final FlutterNostrFeedBuilderData data;
  final FlutterNostrFeedBuilderOptions options;

  final Widget Function(BuildContext context, FlutterNostrFeedBuilderData data)?
  loadingBuilder;
  final Widget Function(
    BuildContext context,
    String error,
    FlutterNostrFeedBuilderData data,
  )?
  errorBuilder;
  final Widget Function(
    BuildContext context,
    NostrEvent event,
    int index,
    FlutterNostrFeedBuilderData data,
    FlutterNostrFeedBuilderOptions options,
  )?
  itemBuilder;
  final Widget Function(BuildContext context, FlutterNostrFeedBuilderData data)?
  emptyBuilder;
  final Widget Function(
    BuildContext context,
    List<NostrEvent> items,
    FlutterNostrFeedBuilderData data,
    FlutterNostrFeedBuilderOptions options,
  )?
  listBuilder;

  @override
  Widget build(BuildContext context) {
    final profileFetchResults = data.parallelRequestResults?["profile-fetch"];

    // Keep computed results here if needed by custom item builders through data.parallelRequestResults
    final _ =
        profileFetchResults
            ?.map((e) => e.adaptedResults)
            .expand((e) => e)
            .toList() ??
        [];

    // Loading
    if (data.isLoading && data.events.isEmpty) {
      return loadingBuilder?.call(context, data) ??
          const Center(child: CircularProgressIndicator());
    }

    // Error
    if (data.error != null && data.error!.isNotEmpty) {
      return errorBuilder?.call(context, data.error!, data) ??
          Center(child: Text('Error: ${data.error}'));
    }

    // Empty
    if (data.events.isEmpty) {
      return emptyBuilder?.call(context, data) ??
          const Center(child: Text('No items found.'));
    }

    final items = data.events;

    // Full list override
    if (listBuilder != null) {
      return listBuilder!(context, items, data, options);
    }

    return RefreshIndicator(
      onRefresh: () async {
        options.refresh?.call();
      },
      child: ListView.builder(
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == items.length && index != 0) {
            return VisibilityDetector(
              key: ValueKey('load-more-$index'),
              onVisibilityChanged: (options.loadMore != null)
                  ? (info) {
                      if (info.visibleFraction > 0) {
                        options.loadMore!.call();
                      }
                    }
                  : null,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          final event = items[index];
          return VisibilityDetector(
            key: ValueKey('event-$index'),
            onVisibilityChanged: (info) {
              if (info.visibleFraction > 0) {
                options.onRegisterEntityForNextParallelRequest?.call(event);
                options.onRunParallelRequest?.call();
              }
            },
            child: itemBuilder != null
                ? itemBuilder!(context, event, index, data, options)
                : _DefaultFeedItem(event: event),
          );
        },
      ),
    );
  }

  // Intentionally left for future theming tweaks
}

class _DefaultFeedItem extends StatelessWidget {
  const _DefaultFeedItem({required this.event});

  final NostrEvent event;

  @override
  Widget build(BuildContext context) {
    final text = event.content ?? '';
    final bg = Color(
      ((text.hashCode) * 0xFFFFFF) | 0xFF000000,
    ).withValues(alpha: 0.08);
    return Container(
      key: ValueKey('default-item-${event.id ?? ''}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: bg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.pubkey,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(text.length > 200 ? text.substring(0, 200) : text),
        ],
      ),
    );
  }
}
