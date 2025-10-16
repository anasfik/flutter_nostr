import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_nostr/flutter_nostr.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() async {
  await FlutterNostr.init(relays: ['wss://relay.damus.io']);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const Screen());
  }
}

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Nostr Example')),
      body: FlutterNostrFeed(
        filters: [
          NostrFilter(kinds: [1], limit: 2),
        ],
        parallelRequestRequestsHandler: (items) {
          final allEvents = items;

          return ParallelRequest<(NostrEvent, Map<String, dynamic>)>(
            id: "profile-fetch",
            filters: [
              NostrFilter(
                kinds: [0],
                authors: allEvents.map((e) => e.pubkey).toList(),
              ),
            ],
            adapter: (event) {
              try {
                return (
                  event,
                  jsonDecode(event.content!) as Map<String, dynamic>,
                );
              } catch (e) {
                return (event, <String, dynamic>{});
              }
            },
          );

          // .then((previousRequestResults) {
          //   // Now 'previousRequestResults' is properly typed as List<(NostrEvent, Map<String, dynamic>)>
          //   // No casting needed - the type system knows the exact type
          //   return ParallelRequest<(String, List<dynamic>)>(
          //     filters: [
          //       NostrFilter(
          //         kinds: [3],
          //         authors: previousRequestResults
          //             .map(
          //               (e) => e.$1.pubkey,
          //             ) // e.$1 is NostrEvent, e.$2 is Map<String, dynamic>
          //             .toList(), // This will be List<String> automatically
          //       ),
          //     ],
          //     adapter: (event) {
          //       return (
          //         event.pubkey,
          //         event.tags
          //                 ?.where((list) => list.firstOrNull == 'p')
          //                 .map((list) => list.length > 1 ? list[1] : '')
          //                 .toList() ??
          //             <String>[],
          //       );
          //     },
          //   );
          // });
        },
        builder: (context, data, options) {
          final allEvents = data.events;

          return Feed(
            isLoading: data.isLoading,
            items: allEvents,
            error: data.error,
            parallelRequestResults: data.parallelRequestResults,
            onLoadMore: options.loadMore,
            onRefresh: options.refresh,
          );
        },
      ),
    );
  }
}

class Feed extends StatefulWidget {
  const Feed({
    super.key,
    this.onLoadMore,
    this.onRefresh,
    this.isLoading = false,
    this.items = const [],
    this.error,
    this.parallelRequestResults = const {},
  });

  final bool isLoading;
  final List<NostrEvent> items;
  final String? error;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRefresh;
  final Map<String, List<ParallelEventsRequestResponse>>?
  parallelRequestResults;
  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileFetchResults = widget.parallelRequestResults?["profile-fetch"];
    final userResults =
        profileFetchResults
            ?.map((e) {
              return e.adaptedResults
                  .cast<(NostrEvent, Map<String, dynamic>)>();
            })
            .expand((e) => e)
            .toList() ??
        [];

    return Column(
      children: [
        Text('Total items: ${widget.items.length}'),
        Flexible(
          child: RefreshIndicator(
            onRefresh: () async {
              if (widget.onRefresh != null) {
                widget.onRefresh!();
              }
            },

            child: Builder(
              builder: (context) {
                if (widget.error != null && widget.error!.isNotEmpty) {
                  return Center(child: Text('Error: ${widget.error}'));
                }

                if (widget.isLoading && widget.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: widget.items.length + 1,

                  itemBuilder: (context, index) {
                    if (index == widget.items.length && index != 0) {
                      return VisibilityDetector(
                        key: ValueKey('load-more-$index'),

                        onVisibilityChanged: (widget.onLoadMore != null)
                            ? (info) {
                                if (info.visibleFraction > 0) {
                                  widget.onLoadMore!();
                                }
                              }
                            : null,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    final event = widget.items[index];
                    final text = event.content ?? '';

                    final tileColor = randomColor(
                      seed: text.hashCode,
                    ).withValues(alpha: 0.25);

                    final user = userResults.firstWhere(
                      (element) => element.$1.pubkey == event.pubkey,
                      orElse: () => (event, <String, dynamic>{}),
                    );

                    return ListTile(
                      key: ValueKey('item-$index'),

                      tileColor: tileColor,
                      title: Text(user.$2['name'] ?? event.pubkey),
                      leading: CircleAvatar(
                        backgroundImage:
                            (user.$2['picture'] != null &&
                                user.$2['picture'].toString().isNotEmpty)
                            ? NetworkImage(user.$2['picture'])
                            : null,
                      ),
                      subtitle: Linkify(
                        text: text.substring(
                          0,
                          text.length > 200 ? 200 : text.length,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  final map = {};

  Color randomColor({required int seed}) {
    return map[seed] ??= Color((seed * 0xFFFFFF) | 0xFF000000);
  }
}
