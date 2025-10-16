# 🕊️ flutter_nostr  
### Build scalable, complex & time-consuming decentralized apps in a record time, even if you are new to Flutter/Nostr!


**flutter_nostr** is a modern, developer-friendly toolkit to create Nostr-based apps — feeds, chats, identity systems, interaction systems, payment systems or entire decentralized networks — **without needing to understand the low-level protocol.**

It provides a high-level, easy-to-use API that abstracts away the complexities of working with Nostr and Flutter, allowing you to focus on building your app's features and user UI/UX.

## 🚀 Why Choose flutter_nostr?

- **⚡ Lightning Fast**: Built-in parallel request execution for optimal performance
- **🎯 Developer Experience**: Simple, intuitive API that gets you started in minutes
- **🔄 Real-time**: Automatic pagination, refresh, and infinite scroll support
- **🛡️ Type Safe**: Full TypeScript-like type safety with Dart's strong typing
- **📱 Flutter Native**: Seamlessly integrates with Flutter's widget system and state management
- **🌐 Production Ready**: Handles errors, loading states, and edge cases out of the box



## Features
- **High-level abstractions**: Work with Nostr concepts like events, relays, and keys without dealing with low-level protocol details.
- **Flutter integration**: Seamlessly integrate with Flutter's widget system and state management solutions.
- **Scalability**: Designed to handle large-scale applications with ease.
- **Extensibility**: Easily extend and customize the toolkit to fit your specific needs.
- **Comprehensive documentation**: Detailed guides and examples to help you get started quickly.


## Quick Start

### 1. Add to your `pubspec.yaml`:
```yaml
dependencies:
  flutter_nostr: ^0.1.0
```

### 2. Initialize Flutter Nostr:
```dart
import 'package:flutter_nostr/flutter_nostr.dart';

void main() async {
  await FlutterNostr.init(relays: ['wss://relay.damus.io']);
  runApp(MyApp());
}
```

### 3. Create a Nostr Feed in 3 lines:
```dart
FlutterNostrFeed(
  filters: [NostrFilter(kinds: [1], limit: 20)], // Get latest notes
  builder: (context, data, options) {
    return ListView.builder(
      itemCount: data.events.length,
      itemBuilder: (context, index) {
        final event = data.events[index];
        return ListTile(
          title: Text(event.content ?? ''),
          subtitle: Text('by ${event.pubkey}'),
        );
      },
    );
  },
)
```

### 4. Advanced Feed with User Profiles:
```dart
FlutterNostrFeed(
  filters: [NostrFilter(kinds: [1], limit: 20)],
  parallelRequestRequestsHandler: (events) {
    // Automatically fetch user profiles for each event
    return ParallelRequest(
      id: "profiles",
      filters: [NostrFilter(
        kinds: [0], // Profile events
        authors: events.map((e) => e.pubkey).toList(),
      )],
      adapter: (event) => jsonDecode(event.content!),
    );
  },
  builder: (context, data, options) {
    final profiles = data.parallelRequestResults?["profiles"] ?? [];
    
    return ListView.builder(
      itemCount: data.events.length,
      itemBuilder: (context, index) {
        final event = data.events[index];
        final profile = profiles.firstWhere(
          (p) => p.event.pubkey == event.pubkey,
          orElse: () => null,
        );
        
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: profile?.adaptedResults['picture'] != null
                ? NetworkImage(profile!.adaptedResults['picture'])
                : null,
            ),
            title: Text(profile?.adaptedResults['name'] ?? event.pubkey),
            subtitle: Text(event.content ?? ''),
          ),
        );
      },
    );
  },
)
```

## 📱 Try the Example App

Want to see flutter_nostr in action? Check out our complete example app:

```bash
cd example
flutter pub get
flutter run
```

The example demonstrates:
- ✅ Real-time Nostr feed with live data
- ✅ User profile fetching and display
- ✅ Pull-to-refresh functionality
- ✅ Infinite scroll with automatic pagination
- ✅ Error handling and loading states
- ✅ Beautiful Material Design UI

## Features

- [~] Universal Feed Generator
  - [~] One-Request Feed Generator
  - [~] Multi-Request Feed Generator (handling multiple related requests such as loading notes then loading their comments, reactions, zaps, updates, owner details..., pagination, reloading)
  - [~] Feeds with local/remote searching
  - [~] Caching
  - [~] Error handling
  - [~] Optimization for UI, data fetching

- [~] Keys management
  - [~] private/public keys generator.
  - [~] private/public keys storage.
  - [~] private/public keys management.
  - [~] Nostr auth flow builder

- [~] Relays management
  - [~] Relays connection manager.
  - [~] Relays read/write manager.
  - [~] Relays status manager.
  
- [~] Chat
  - [~] Encrypted p2p chat latest encryption protocol, [NIP-44](https://github.com/nostr-protocol/nips/blob/master/44.md)
  - [~] Public group chat 
  - [~] Chat advanced features, like mentions, message replies, reactions, edit, deletion, voice notes, images, videos, files, etc.
  - [~] [Chat Messaging using MLS Protocol](https://github.com/nostr-protocol/nips/blob/master/EE.md)

- [~] Data fetching/writing
  - One event fetch/write Builder.
  - Multi event fetch/write Builder.
  - Error handling

- [~] Support for feature-based Nips
  - [~] Support fro Nips that a client would definitely need to implement, like [Nip-11](https://github.com/nostr-protocol/nips/blob/master/11.md), [Nip-05](https://github.com/nostr-protocol/nips/blob/master/05.md)...

- [] Payments
- [] third-party services integration (e.g., NostrConnect, NostrWalletConnect, etc.)
- [] Relay moderation based on [Nip-86](https://github.com/nostr-protocol/nips/blob/master/86.md)

## 🗺️ Roadmap

We're actively developing flutter_nostr with exciting features coming soon:

### 🎯 Coming Next (v0.2.0)
- **Chat System**: Encrypted P2P messaging with NIP-44 support
- **Identity Management**: Easy key generation, storage, and NIP-05 verification
- **Advanced Feeds**: Comments, reactions, zaps, and social interactions
- **Search & Discovery**: Local and remote search capabilities

### 🚀 Future Releases
- **Payment Integration**: Lightning Network support for seamless payments
- **NostrConnect**: Third-party service integrations
- **MLS Protocol**: Advanced group messaging
- **Relay Management**: Smart relay selection and moderation

## 🤝 Contributing
Contributions are welcome! Please open an issue or submit a pull request on GitHub.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
