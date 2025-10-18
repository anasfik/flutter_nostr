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
    // use profiles in your UI
  },
)
```

Chaining requests (multi-layer)

You can chain parallel requests using `.then<U>()`, for example: fetch profiles,
then fetch followings for those profiles.

Example app (run locally)

```powershell
cd example
flutter pub get
flutter run
```

What to read next in the codebase
- `example/`  concrete, runnable examples. Best place to start.
- `lib/components/feed/`  the feed widget and the `FlutterNostrFeedList` UI
- `lib/data_source/parallel_request_executor.dart`  how chains are executed
- `lib/models/parallel_request.dart`  the typed API for building requests

Roadmap & contributions
- v0.2: chat primitives (NIP-44), identity helpers
- Later: payments, NostrConnect integration, relay moderation

Contributing
- PRs and issues welcome. Adding or improving an example screen helps everyone.

License
- MIT

Maintainer
- See the repository owner on GitHub. Open an issue or PR for questions.
