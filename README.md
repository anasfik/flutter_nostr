# 🕊️ flutter_nostr  
### Build scalable, complex & time-consuming decentralized apps in a record time, even if you are new to Flutter/Nostr!


**flutter_nostr** is a modern, developer-friendly toolkit to create Nostr-based apps — feeds, chats, identity systems, interaction systems, payment systems or entire decentralized networks — **without needing to understand the low-level protocol.**

It provides a high-level, easy-to-use API that abstracts away the complexities of working with Nostr and Flutter, allowing you to focus on building your app's features and user UI/UX.



## Features
- **High-level abstractions**: Work with Nostr concepts like events, relays, and keys without dealing with low-level protocol details.
- **Flutter integration**: Seamlessly integrate with Flutter's widget system and state management solutions.
- **Scalability**: Designed to handle large-scale applications with ease.
- **Extensibility**: Easily extend and customize the toolkit to fit your specific needs.
- **Comprehensive documentation**: Detailed guides and examples to help you get started quickly.


## Getting Started

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

 # Contributing
Contributions are welcome! Please open an issue or submit a pull request on GitHub.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
