# System Patterns: Merger Game

## Architecture

*   **Flutter:** The game is built using the Flutter framework for cross-platform mobile development (Android/iOS).
*   **Riverpod:** State management is handled using Riverpod.
    *   `StateNotifierProvider` is used for complex state (e.g., `GridNotifier`, `PlayerStatsNotifier`, `OrderNotifier`).
    *   `Provider` is used for derived or read-only data (e.g., `availableUnlocksProvider`).
    *   `StateProvider` is used for simple state (though this is being phased out in favor of `PlayerStatsNotifier` for player stats).
*   **Isar:** Local data persistence is implemented using the Isar NoSQL database.
    *   Models (`TileData`, `PlayerStats`, `Order`) are annotated with `@collection` for Isar.
    *   `GameService` handles loading and saving data to Isar.

## Key Technical Decisions

*   **Centralized State Management:** Riverpod is used to manage all game state, ensuring a single source of truth and simplifying UI updates.
*   **Local Persistence:** Isar is used for local persistence to enable offline play and quick loading.
*   **Data Modeling:** Models are designed to be immutable where appropriate (e.g., `TileUnlock`, `Point`) and mutable within the `StateNotifier`s.
*   **Asynchronous Operations:** Isar operations (load/save) are asynchronous to avoid blocking the UI thread.

## Design Patterns

*   **Provider Pattern:** Riverpod's provider pattern is used extensively to manage and access state throughout the application.
*   **Data Transfer Object (DTO):** Models (`TileData`, `PlayerStats`, `Order`) act as DTOs to transfer data between the UI, business logic, and persistence layers.
*   **Observer Pattern:** Riverpod's `ref.listen` is used to observe changes in state (e.g., `unlockedStatusProvider` in `GridNotifier`) and trigger updates.

## Component Relationships

*   `GameGridScreen` (UI) interacts with:
    *   `GridNotifier` (to get grid data, merge tiles, activate generators).
    *   `PlayerStatsNotifier` (to get player stats, unlock zones).
    *   `OrderNotifier` (to get active orders, deliver orders).
    *   `expansionProvider` (to get available unlocks).
*   `GridNotifier` interacts with:
    *   `PlayerStatsNotifier` (to award XP, refund energy).
    *   `expansionProvider` (to get unlock definitions).
*   `OrderNotifier` interacts with:
    *   `GridNotifier` (to remove items on order fulfillment).
    *   `PlayerStatsNotifier` (to award coins/XP).
*   `PlayerStatsNotifier` interacts with:
    *   `expansionProvider` (to get unlock definitions).

## Critical Implementation Paths

*   **Merging:** `GameGridScreen._buildTile` uses `DragTarget` to detect drops. `GridNotifier.mergeTiles` updates the grid state.
*   **Order Fulfillment:** `GameGridScreen._buildOrderDisplay` displays orders and calls `OrderNotifier.attemptDelivery`.
*   **Zone Unlocking:** `GameGridScreen._buildTile` (for locked tiles) calls `PlayerStatsNotifier.unlockZone`.
*   **Saving/Loading:** `main.dart` initializes Isar and calls `GameService.loadGame`. The "Save" button in `GameGridScreen` calls `GameService.saveGame`.
