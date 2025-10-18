# flutter_nostr

Beautiful, pragmatic Flutter primitives for building Nostr-powered feeds and social UX.

flutter_nostr provides a small, focused set of building blocks for fetching Nostr
events, enriching them with related data (profiles, contact lists, reactions)
using typed parallel requests, and rendering them with Flutter-friendly widgets.

Why this package
- Practical: opinionated widgets and helpers so you can ship a feed fast.
- Performant: parallel request executor fetches related data efficiently.
- Type-safe: generics and typed models make complex chains easier to reason about.
- Example-first: copyable example screens in `example/` to learn by doing.

Quick highlights
- `FlutterNostrFeed`  main feed widget (filters, builder callback)
- `FlutterNostrFeedList`  list with pagination, pull-to-refresh and visibility triggers
- `ParallelRequest<T>` / `ParallelRequestId<T>`  typed parallel requests with chaining

Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_nostr: ^0.1.0
```

Quick start

```dart
import 'package:flutter/material.dart';
import 'package:flutter_nostr/flutter_nostr.dart';

void main() async {
  // Initialize with one or more relays
  await FlutterNostr.init(relays: ['wss://relay.nostr.band']);
  runApp(const MyApp());
}
```

Minimal feed (render events)

```dart
FlutterNostrFeed(
  filters: [NostrFilter(kinds: [30402], limit: 20)],
  builder: (context, data, options) => FlutterNostrFeedList(
    data: data,
    options: options,
    itemBuilder: (context, event, index, data, options) =>
      ListTile(title: Text(event.content ?? event.pubkey)),
  ),
)
```

Enriching the feed with profiles (single-layer)

1. Build a `ParallelRequest<UserInfo>` that fetches profile events for the
   authors of the visible events.
2. The executor adapts profile events to `UserInfo` and stores them in
   `data.parallelRequestResults`.

```dart
final profileRequestId = ParallelRequestId<UserInfo>(id: 'profiles');

FlutterNostrFeed(
  filters: [...],
  parallelRequestRequestsHandler: (parallelResults, events) {
    return ParallelRequest<UserInfo>(
      id: profileRequestId,
      filters: [NostrFilter(kinds: [0], authors: events.map((e) => e.pubkey).toList())],
      adapter: (event) => UserInfo.fromEvent(event),
    );
  },
  builder: (context, data, options) {
    final profiles = data.locateParallelRequestResultsById(profileRequestId)?.adaptedResults ?? [];
    # flutter_nostr

    Beautiful, pragmatic Flutter primitives for building Nostr-powered feeds and
    social UX. This README is written for all levels — from beginners who want a
    copy/paste example to advanced users who need typed parallel chains and
    customization points.

    Table of contents
    - What is flutter_nostr?
    - Quick start (copy/paste)
    - Examples (beginner → advanced)
    - API reference (short)
    - Example app walkthrough
    - Tips for beginners
    - Advanced topics
    - Roadmap & contributing

    What is flutter_nostr?
    ----------------------

    flutter_nostr provides building blocks for:

    - Fetching events from Nostr relays using `NostrFilter`s.
    - Enriching events with related data via typed `ParallelRequest<T>` chains.
    - Rendering lists with `FlutterNostrFeed` and `FlutterNostrFeedList` — both
      include pagination, pull-to-refresh and visibility-triggered parallel
      execution hooks.

    Quick start (copy/paste)
    -----------------------

    1. Add to `pubspec.yaml`:

    ```yaml
    dependencies:
      flutter_nostr: ^0.1.0
    ```

    2. Initialize the SDK in `main.dart`:

    ```dart
    import 'package:flutter/material.dart';
    import 'package:flutter_nostr/flutter_nostr.dart';

    void main() async {
      await FlutterNostr.init(relays: ['wss://relay.nostr.band']);
      runApp(const MyApp());
    }
    ```

    3. Minimal feed widget:

    ```dart
    FlutterNostrFeed(
      filters: [NostrFilter(kinds: [30402], limit: 20)],
      builder: (context, data, options) => FlutterNostrFeedList(
        data: data,
        options: options,
        itemBuilder: (context, event, index, data, options) =>
          ListTile(title: Text(event.content ?? event.pubkey)),
      ),
    )
    ```

    Examples (step-by-step)
    -----------------------

    1) Beginner — simple feed

    - Goal: render the latest events of a kind with pull-to-refresh and infinite
      scroll.

    Use the minimal feed above. The `FlutterNostrFeedList` handles showing a
    loading indicator and calling `options.loadMore` when the user scrolls near
    the end.

    2) Intermediate — enrich results with user profiles (single-layer)

    - Goal: fetch profile (kind 0) events for authors of visible events and show
      their names and avatars.

    Step A — declare a request id and a request builder

    ```dart
    final profileRequestId = ParallelRequestId<UserInfo>(id: 'profiles');

    ParallelRequest<UserInfo>(
      id: profileRequestId,
      filters: [NostrFilter(kinds: [0], authors: authorsList)],
      adapter: (event) => UserInfo.fromEvent(event),
    )
    ```

    Step B — pass a handler to the feed

    ```dart
    FlutterNostrFeed(
      filters: [NostrFilter(kinds: [30402], limit: 20)],
      parallelRequestRequestsHandler: (parallelResults, events) {
        return ParallelRequest<UserInfo>(
          id: profileRequestId,
          filters: [NostrFilter(kinds: [0], authors: events.map((e) => e.pubkey).toList())],
          adapter: (event) => UserInfo.fromEvent(event),
        );
      },
      builder: (context, data, options) {
        final profiles = data.locateParallelRequestResultsById(profileRequestId)?.adaptedResults ?? [];
        // find the profile for an event by matching pubkey
      },
    )
    ```

    Notes:
    - The feed registers events for parallel requests when they become visible.
    - Results are collected into `data.parallelRequestResults` and exposed via
      `locateParallelRequestResultsById` with proper typing.

    3) Advanced — multi-layer chaining (profiles → followings)

    - Goal: fetch profiles first, then fetch each profile's contact list (kind 3)
      to show following counts.

    Use `.then<U>()` on `ParallelRequest<T>` to construct a chain where the next
    request receives the adapted results of the previous step.

    ```dart
    ParallelRequest<UserInfo>(...)
      .then<UserFollowings>((profiles) {
        return ParallelRequest<UserFollowings>(
          id: ParallelRequestId(id: 'followings'),
          filters: [NostrFilter(kinds: [3], authors: profiles.map((p) => p.pubkey).toList())],
          adapter: (event) => UserFollowings.fromEvent(event),
        );
      });
    ```

    API reference (short)
    ---------------------

    - `FlutterNostr.init({List<String> relays})` — initialize the client
    - `FlutterNostrFeed({filters, parallelRequestRequestsHandler, builder})` —
      feed widget
    - `FlutterNostrFeedList` — list widget with built-in pagination and triggers
    - `ParallelRequest<T>` / `ParallelRequestId<T>` — typed parallel request API

    Example app walkthrough
    -----------------------

    The `example/` folder includes three screens:

    - `SimpleFeedScreen` — demonstrates a minimal feed with link detection.
    - `SingleLayerParallelFeedScreen` — shows profile enrichment and displaying
      avatars and names.
    - `MultiLayerParallelFeedScreen` — demonstrates chaining requests and
      aggregating results.

    Run it locally:

    ```powershell
    cd example
    flutter pub get
    flutter run
    ```

    Tips for beginners
    ------------------

    - Start with the minimal feed and inspect `example/` to see wiring and
      navigation.
    - Use small `limit` values in `NostrFilter` while developing to reduce
      network noise and speed up iteration.
    - Step through the code in `example/` to learn how `parallelRequestRequestsHandler`
      is wired to `FlutterNostrFeed`.

    Advanced topics
    ---------------

    - Error handling: parallel requests can fail for a step — results include an
      `error` field for inspection.
    - Caching: the example shows lifting results into state; you can add a cache
      layer around the executor if needed.

    Roadmap & contributing
    ----------------------

    - v0.2: chat primitives (NIP-44), identity helpers
    - Later: payments, NostrConnect, relay moderation

    Contributing
    ------------

    PRs and issues welcome. Adding an example screen that demonstrates a real
    use-case (for example, reactions or threaded comments) is especially helpful.

    License
    -------

    MIT — see `LICENSE`.

    Maintainer
    ----------

    See repository owner on GitHub. Open an issue or PR for questions.
