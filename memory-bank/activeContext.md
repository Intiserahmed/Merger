# Active Context: Merger Game

## Current Work Focus

Overhauling the UI, adding a Map Screen, and refining the Game Grid Screen based on visual references. Implementing a new emoji-based merge sequence.

## Recent Changes

*   **Persistence:**
    *   Implemented local data persistence using Isar.
    *   `GameService` handles loading and saving game state (grid, player stats, orders, unlocked zones).
    *   `TileData`, `PlayerStats`, and `Order` models are now Isar collections.
    *   A debug "Save Game" button has been added to the UI.
*   **XP + Leveling System:**
    *   XP thresholds per level are defined.
    *   XP is awarded for completing orders and merging items.
    *   `PlayerStatsNotifier` automatically triggers `levelUp` when enough XP is gained.
    *   `levelUp` increases the player level, resets XP, refills energy, and increases `maxEnergy`.
*   **Order System:**
    *   The `currentCount` field was removed from the `Order` model.
    *   The `OrderNotifier` now checks the grid directly for item counts.
*   **Zone Unlocking:**
    *   The `unlockedStatusProvider` now derives its state from `playerStatsProvider`.
    *   The `unlockZone` method in `PlayerStatsNotifier` directly modifies the `unlockedZoneIds` list within the `PlayerStats` state.
    *   The `_initializeGridData` method in `GridNotifier` now creates `TileType.locked` tiles based on the zones defined in `expansion_provider` that are *not* initially unlocked.
    *   The `_unlockTilesForZone` method in `GridNotifier` updates the types/images of tiles within that zone.
*   **Map Screen:**
    *   Created `lib/screens/map_screen.dart`.
    *   Added a top status bar (Level, Energy, Coins, Gems) similar to the reference image.
    *   Included a placeholder for the main map content area.
*   **Game Grid Screen (`lib/widgets/game_grid_screen.dart`):**
    *   Removed the default `AppBar`.
    *   Added the same custom top status bar as the Map Screen.
    *   Implemented a brown/light-brown chessboard background for grid tiles.
    *   Removed the visual number display (`overlayNumber`) from items.
    *   Adjusted tile sizing slightly.
    *   Added placeholder elements (e.g., bottom info bar).
*   **Merging & Items:**
    *   Introduced a new plant-based emoji merge sequence (`🌱` -> `🌿` -> `🌳` ...) in `lib/providers/grid_provider.dart`.
    *   Removed the previous number-based merging logic and associated XP gains.
    *   Added XP gains based on the plant merge level.
    *   Updated the Barracks generator to spawn the base plant item (`🌱`).
*   **Player Stats:**
    *   Added a `gems` field to the `PlayerStats` model (`lib/models/player_stats.dart`).
    *   Updated `PlayerStatsNotifier` (`lib/providers/player_provider.dart`) to manage the `gems` state.
    *   Ran `build_runner` to update generated files.
*   **Screen Navigation:**
    *   Implemented a `StateProvider` (`lib/providers/navigation_provider.dart`) to manage the active screen index.
    *   Added a `FloatingActionButton` to both `GameGridScreen` and `MapScreen` to toggle between the screens.
    *   Modified `lib/main.dart` to use the `activeScreenIndexProvider` to display the correct screen.

## Next Steps

*   **Map Screen Implementation:** Replace the placeholder in `MapScreen` with actual map graphics and interactive elements.
*   **Grid UI Refinement:** Further adjust grid tile sizing and layout for optimal appearance. Replace placeholder elements with final UI components.
*   **Refactor Shared UI:** Extract the duplicated status bar code (`_buildTopArea`, `_buildResourceBar`) from `GameGridScreen` and `MapScreen` into a reusable widget.
*   **Content Expansion:** Continue adding more items, generators, orders, and zones.
*   **Balancing:** Fine-tune XP, costs, rewards, and unlock requirements.
*   **Testing:** Implement automated tests.

## Active Decisions and Considerations

*   **Shared UI Components:** The status bar logic is currently duplicated and should be refactored for better maintainability.
*   **Data Modeling:** (Existing consideration) Evaluate grid state storage efficiency.
*   **Save Frequency:** (Existing consideration) Determine optimal save frequency.
*   **Error Handling:** (Existing consideration) Improve Isar error handling.

## Important Patterns and Preferences

*   Use Riverpod for all state management.
*   Use Isar for local persistence.
*   Keep models immutable where possible.
*   Use asynchronous operations for I/O.

## Learnings and Project Insights

*   Isar is relatively easy to integrate and use for local persistence.
*   Riverpod's provider pattern simplifies state management and UI updates.
*   Careful data modeling is crucial for efficient persistence and retrieval.
*   Updating Isar models requires running `build_runner`.
*   Clear visual references are essential for UI tasks.
