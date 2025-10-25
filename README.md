# 🚀 flutter_nostr

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Nostr](https://img.shields.io/badge/Nostr-8B5CF6?style=for-the-badge&logo=lightning&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Beautiful, pragmatic Flutter primitives for building Nostr-powered feeds and social UX**

[📖 Documentation](#-documentation) • [🎯 Quick Start](#-quick-start) • [💡 Examples](#-examples) • [🔧 API Reference](#-api-reference) • [🤝 Contributing](#-contributing)

</div>

---

## ✨ What is flutter_nostr?

`flutter_nostr` is a powerful Flutter package that provides **building blocks** for creating Nostr-powered social applications. It handles the complexity of fetching events, enriching them with related data, and rendering them in beautiful, performant Flutter widgets.

### 🎯 Key Features

- 🔄 **Parallel Data Fetching**: Efficiently fetch related data (profiles, reactions, etc.) using typed parallel requests
- 📱 **Flutter-Native**: Built specifically for Flutter with proper state management and widget lifecycle
- 🎨 **Customizable**: Flexible builder patterns and adapters for any data structure
- ⚡ **Performant**: Smart caching, pagination, and visibility-based loading
- 🔗 **Type-Safe**: Full TypeScript-like type safety with Dart generics
- 📚 **Example-Rich**: Complete example app with multiple use cases

## 🚀 Quick Start

### 1. Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_nostr: ^0.1.0
```

### 2. Initialize

```dart
import 'package:flutter/material.dart';
import 'package:flutter_nostr/flutter_nostr.dart';

void main() async {
  // Initialize with one or more relays
  await FlutterNostr.init(relays: [
    'wss://relay.nostr.band',
    'wss://nos.lol',
  ]);

  runApp(const MyApp());
}
```

### 3. Enjoy the package capabilities.

## Feeds

Feeds are the core building block of social applications, it is that simple scrollable list of events enriched with related data customized to your needs, with support to all states like loading, error, empty, pull-to-refresh, infinite scroll and more.

### Simple Feed (1-layer Feed)

#### Key Components

The main component that you will always use to build a feed is `FlutterNostrFeed`, it is responsible for fetching the data and providing it to the `builder` function.

Inside the builder function, you can take full control on how/what you want to support in your feed, or you can simply use the pre-built `FlutterNostrFeedList` which abstract general handling for a feed like loading, error handling... and only prompt you to build the UI for your list of items.

The simple feed is refered to a feed that only loads requests sequentianlly only, and does require loading request events **only**

#### Example:

```dart
FlutterNostrFeed(
  filters: [
    NostrFilter(
      limit: 10, // limit each loading to 10 events
      kinds: [30402], // listings kinds
    ),
  ],.

  builder: (context, data, options) {
    return FlutterNostrFeedList(
      data: data,
      options: options,
      itemBuilder: (context, event, index, data, options) {
         return ListTile(
           title: Text(event.content ?? 'No content'),
           subtitle: Text('Author: ${event.pubkey.substring(0, 8)}...'),
         );
      },
    );
  },
),
```

**That's it!** 🎉 You now have a fully functional Nostr listings feed with:

- ✅ Pull-to-refresh
- ✅ Infinite scroll
- ✅ Loading states
- ✅ Error handling
- ✅ Smooth and lag-free rendering (using `ListView.builder` and some other techniques..)
- ✅ Much more handling that you propably don't know about but happens under the hood.

### Rich Feed (Multi-layer Feed)

In order for a Nostr Feed to be functional and usable, loading more entities that relates to what actually was requested initially is requested. as an example, creating a posts feed shoulf also fetch for these posts authors details such name, username, picture...

This is where the package also abstracts the complexity of doing so in a multi-layer feed, which basically have parallel loading for the initial requested events, so lets take this use case:

- When the posts feed is loaded. (**Layer 1**)
- For each post (Loaded in **Layer 1**) that the end-user sees, more parallel requests executes to get their authors user details, reactions, zaps, comments, referenced events/pubkeys if any with `nevent` ,`npub`,`note`, `nprofile`..., parent events if any... (**Layer 2**)
- For each post (Loaded in **Layer 1**) reaction/comment (Loaded in **Layer 2**), more parallel requests execute to get their user details or more related data (**Layer 3**)
- More parallel fetching if needed...

With this mechanism, you will be basically be able to build your goal feed even if it will require much more fetching layers.

#### Key Components

Note: I assume you read the [Simple Feed](#simple-feed-1-layer-feed) section before continuing.

- The `FlutterNostrFeed` still the main component that you will use to build a feed, but now you will also use the `parallelRequestRequestsHandler` parameter to define your parallel requests using the already loaded data from previous layers.
- Each parallel request is represented by the `ParallelRequest<T>` class, which is a typed request that holds the filters to be used to fetch the related data, and an adapter function to convert the fetched `NostrEvent` into the desired type `T`.
- Each parallel request is identified from other parallel requests if any with the `ParallelRequestId<T>`, where you basically create a unique `id` for each request you want to make.
- Results of each request is passed to the `builder` via the `FeedBuilderData data` parameter, where you can access the results of each request by its `ParallelRequestId<T>`.
- To execute more parallel requests based on the results of previous parallel requests, you can use the `.then<U>()` method on the `ParallelRequest<T>` instance to chain more requests, like:

```dart
ParallelRequest<T>(
  //...
).then<U>((List<T> previousResults) {
  return ParallelRequest<U>(
    //...
  );
}).then<V>((List<U> previousResults) {
  return ParallelRequest<V>(
    //...
  );
}).then<W>((List<V> previousResults) {
  return ParallelRequest<W>(
    //...
  );
});
```

#### Example 1: Feed with User Profiles

```dart
 final profileFetchRequestId = ParallelRequestId<UserInfo>(id: 'unique-id-1');

FlutterNostrFeed(
  filters: [
    NostrFilter(
      limit: 25,
      kinds: [1], // posts kinds
    ),
  ],
  parallelRequestRequestsHandler: (_, List<NostrEvent> postEvents) {
    return ParallelRequest(
      id: profileFetchRequestId,
      filters: [
        NostrFilter(
          kinds: [0], // user details kind
          authors: postEvents.map((e) => e.pubkey).toList(),
        ),
      ],
      adapter: (event) {
        return UserInfo.fromEvent(event);
      },
    );
  },
  builder: (context, data, options) {
    return FlutterNostrFeedList(
      data: data,
      options: options,
      itemBuilder: (context, NostrEvent postEvent, index, data, options) {
        final postContent = postEvent.content != null ? postEvent.content! : "";

        // This is how we access the requests results for a specific parallel request by its id
        final profileFetchResults = data.parallelRequestResultsFor(
          profileFetchRequestId,
        );

        List<UserInfo> userResults = profileFetchResults?.adaptedResults ?? [];

        UserInfo? user =
            userResults
                .where((element) => element.event.pubkey == postEvent.pubkey)
                .firstOrNull;

        final postOwnerName =
            user?.name.isEmpty ?? true ? "Loading Or Unknown" : user!.name;

        return ListTile(
          title: Text(postOwnerName),
          subtitle: Text(postContent),
        );
      },
    );
  },
),
```

#### Example 2: Feed with user profiles, user followings and user followers (Multi-Layer Feed)

```dart
 final profileFetchRequestId = ParallelRequestId<UserInfo>(id: 'unique-id-1');
 final followingsFetchRequestId = ParallelRequestId<UserFollowings>(id: 'unique-id-2');

FlutterNostrFeed(
  filters: [
    NostrFilter(
      limit: 25,
      kinds: [1], // posts kinds
    ),
  ],
  parallelRequestRequestsHandler: (_, List<NostrEvent> postEvents) {
    return ParallelRequest(
      id: profileFetchRequestId,
      filters: [
        NostrFilter(
          kinds: [0], // user details kind
          authors: postEvents.map((e) => e.pubkey).toList(),
        ),
      ],
      adapter: (event) {
        return UserInfo.fromEvent(event);
      },
    ).then<UserFollowings>((List<UserInfo> users) {
      return ParallelRequest(
        id: followingsFetchRequestId,
        filters: [
          NostrFilter(
            kinds: [3], // user followings kind
            authors: users.map((u) => u.event.pubkey).toList(),
          ),
        ],
        adapter: (event) {
          return UserFollowings.fromEvent(event);
        },
      );
    });
  },
  builder: (context, data, options) {
    return FlutterNostrFeedList(
      data: data,
      options: options,
      itemBuilder: (context, NostrEvent postEvent, index, data, options) {
        final postContent = postEvent.content != null ? postEvent.content! : "";

        final profileFetchResults = data.parallelRequestResultsFor(
          profileFetchRequestId,
        );

        final followingsFetchResults = data.parallelRequestResultsFor(
          followingsFetchRequestId,
        );

        List<UserInfo> userResults = profileFetchResults?.adaptedResults ?? [];

        List<UserFollowings> followingsResults =
            followingsFetchResults?.adaptedResults ?? [];

        UserInfo? user =
            userResults
                .where((element) => element.event.pubkey == postEvent.pubkey)
                .firstOrNull;

        UserFollowings? userFollowings =
            followingsResults
                .where((element) => element.pubkey == postEvent.pubkey)
                .firstOrNull;

        final postOwnerName =
            user?.name.isEmpty ?? true ? "Loading Or Unknown" : user!.name;

        final postOwnerFollowingsCount = userFollowings?.followings.length ?? 0;

        return ListTile(
          title: Text(postOwnerName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(postContent),
              SizedBox(height: 4),
              Text(
                'Followings: $postOwnerFollowingsCount',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  },
)
```

## 🎮 Example App

The package includes a comprehensive example app you can run and explore visually different use cases and implementations, simply run:

```bash
cd example
flutter pub get
flutter run
```

---

## 🛠️ Advanced Topics

### Error Handling

```dart
FlutterNostrFeed(
  builder: (context, data, options) {
    if (options.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Failed to load feed'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: options.refresh,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return FlutterNostrFeedList(/* ... */);
  },
)
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### 🐛 Bug Reports

- Use the issue template
- Include steps to reproduce
- Provide Flutter/Dart version info

### 💡 Feature Requests

- Describe the use case
- Explain why it would be valuable
- Consider contributing a PR

### 🔧 Pull Requests

- Fork the repository
- Create a feature branch
- Add tests for new functionality
- Update documentation
- Submit a PR with a clear description

## 📋 Roadmap

### 🎯 Version 0.2

- [ ] Chat primitives (NIP-44)
- [ ] Identity helpers and key management
- [ ] Enhanced error handling
- [ ] Performance improvements

### 🚀 Future Versions

- [ ] Payment integration (Lightning)
- [ ] NostrConnect support
- [ ] Relay moderation tools
- [ ] Advanced caching strategies
- [ ] WebSocket connection pooling

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Built on top of [dart_nostr](https://pub.dev/packages/dart_nostr) package
- Inspired by the Nostr protocol's simplicity and power
- Community feedback and contributions

---

<div align="center">

**Made with ❤️ for the Nostr community**

[⭐ Star this repo](https://github.com/anasfik/flutter_nostr) • [🐛 Report issues](https://github.com/anasfik/flutter_nostr/issues) • [💬 Join discussions](https://github.com/anasfik/flutter_nostr/discussions)

</div>
