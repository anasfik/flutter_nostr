# Copilot Instructions for flutter_nostr

## Project Overview

- **flutter_nostr** is a Flutter package for building Nostr-powered social apps, focusing on feeds, event enrichment, and efficient data fetching.
- The architecture is modular: core logic in `lib/`, example app in `example/`, tests in `test/`.
- Major features: parallel data fetching, builder/adapters for custom data, smart caching, and multi-layer event enrichment.

## Key Architectural Patterns

- **Clean Architecture**: Organize code into modules, controllers, services, repositories, and entities. See `lib/` for structure.
- **Repository Pattern**: Used for data persistence and caching. Example: `lib/data_source/nostr_service.dart`.
- **Controller Pattern**: Business logic managed with Riverpod (preferred for state management).
- **Freezed**: Used for UI state modeling.
- **getIt**: Dependency injection for services/repositories (singleton), use cases (factory), controllers (lazy singleton).
- **AutoRoute**: For navigation and passing data between pages.

## Naming & Coding Conventions

- **Types**: Always declare explicit types for variables, parameters, and return values. Avoid `any`.
- **Naming**: PascalCase for classes, camelCase for variables/functions, underscores_case for files/dirs.
- **Functions**: Start with a verb, use RO-RO (object for params/results), prefer short, single-purpose functions (<20 instructions).
- **Booleans**: Use verbs (isLoading, hasError, canDelete).
- **Constants**: UPPERCASE for env vars, define magic numbers as constants.
- **Abbreviations**: Only standard (API, URL) or well-known (i, j, err, ctx, req, res, next).

## Widget & UI Guidelines

- **Flat Widget Trees**: Avoid deep nesting; break large widgets into smaller, focused components. Use `lib/widgets/` for reusable UI.
- **Const Constructors**: Use wherever possible to reduce rebuilds.
- **Theme/Localization**: Use `ThemeData` and `AppLocalizations`.

## Data & Event Handling

- **Feeds**: Use `FlutterNostrFeed` and `FlutterNostrFeedList` for event lists. Support for loading, error, empty, pull-to-refresh, infinite scroll.
- **Parallel Requests**: Use `ParallelRequest<T>` and `ParallelRequestId<T>` for multi-layer event enrichment. Chain requests with `.then<U>()`.
- **One-Time Fetching**: Use `OneTimeEventBuilder` and `OneTimeEventsBuilder` for single/multiple event fetches.

## Testing

- **Widget Tests**: Standard Flutter widget testing in `test/`.
- **Integration Tests**: For API modules.
- **Naming**: Use Arrange-Act-Assert, clear variable names (inputX, mockX, actualX, expectedX).

## Developer Workflows

- **Build/Run Example App**:
  ```bash
  cd example
  flutter pub get
  flutter run
  ```
- **Run Tests**:
  ```bash
  flutter test
  ```
- **Debugging**: Use Flutter's built-in tools. For parallel data issues, check adapters and request chaining in feeds.

## External Integrations

- **Nostr Protocol**: See [Nostr website](https://nostr.com/) and [NIPs repo](https://github.com/nostr-protocol/nips).
- **dart_nostr**: Core dependency for Nostr protocol support.
- **Nostrbook MCP**: For structured NIP queries (install from https://nostrbook.dev/mcp if needed).

## References

- See `README.md` for usage examples and advanced topics.
- See `.cursor/rules` for detailed coding standards and patterns.
- Explore `lib/` for architecture, adapters, and data flow.

---

_Update this file as project conventions evolve. For unclear or missing sections, ask maintainers for clarification._
