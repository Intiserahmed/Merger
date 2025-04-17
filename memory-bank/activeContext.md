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
*   **New Merge Sequence (Tools):**
    *   Added a new "Tool" merge sequence (`🔧` -> `🔨` -> `🔩` -> `⚙️` -> `🔗`) in `lib/providers/grid_provider.dart`.
    *   Added corresponding merge logic and XP rewards in `GridNotifier.mergeTiles`.
    *   Added a new "Workshop" generator (`🏭`) definition and placement logic (`placeGenerator`) in `lib/providers/grid_provider.dart` to spawn the base tool (`🔧`).
*   **Game Grid Screen UI Overhaul (`lib/widgets/game_grid_screen.dart`):**
    *   Replaced the top status bar (`_buildTopArea`, `_buildResourceBar`) with a new HUD layout using placeholder emojis/icons (`👤`, `🪙`).
    *   Replaced the order display (`_buildOrderDisplay`) with a new layout showing only the first order, using placeholder emojis (`🧑`).
    *   Replaced the bottom info bar placeholder (`_buildBottomInfoBarPlaceholder`) with a new layout (`_buildBottomInfoBar`) using placeholder emojis (`ℹ️`).
    *   Added subtle drop shadows to item tiles in `_buildTile`.
    *   Removed the placeholder star background concept (`⭐`) from behind item tiles in `_buildTile`.
    *   Adjusted the visual tile size in the `_buildTile` method (reduced SizedBox dimensions).
    *   Modified the `Draggable` feedback and childWhenDragging to only show the item being dragged, leaving the base tile static.
*   **Grid Dimensions:**
    *   Changed grid size constants (`rowCount`, `colCount`) in `lib/providers/grid_provider.dart` from 11x6 to 9x7.
*   **Progression Overhaul:**
    *   Leveling is now based on completing orders (`_totalOrdersPerLevel` in `player_provider.dart`). XP is decoupled.
    *   `PlayerStats` model tracks `completedOrders` and `ordersForNextLevel`.
    *   `PlayerStatsNotifier` handles order-based leveling via `orderCompleted()` and updated `_checkLevelUp`/`levelUp`.
    *   `OrderNotifier` generates orders based on player level (`_ordersByLevel`) and calls `playerStatsNotifier.orderCompleted()`.
*   **Initial Setup:**
    *   `GridNotifier` now places Camp (`🏕️`), Mine (`⛏️`), and Workshop (`🏭`) generators at fixed positions (4,1), (4,3), (4,5) during initialization.
    *   The manual spawn `FloatingActionButton` has been removed from `GameGridScreen`. Item generation relies on generators.
*   **Generator Config:** Added missing configuration for Mine (`⛏️`) in `lib/models/generator_config.dart`.
*   **Generator Activation:** Temporarily commented out the cooldown check (`isReady`) in `GridNotifier.activateGenerator`.
*   **Build Runner:** Executed successfully after `PlayerStats` model changes.


## Next Steps

*   **Map Screen Implementation:** Replace the placeholder in `MapScreen` with actual map graphics, navigation, and potentially zone previews/interactions. Update its Top HUD.
*   **Grid UI Refinement:**
    *   Replace placeholder emojis/icons in the Top HUD, Order Display, and Bottom Info Bar with actual assets or final icons.
    *   Implement dynamic text updates for the Bottom Info Bar based on selected tile (Partially done, needs polish).
    *   Implement energy cooldown display in the Top HUD.
    *   Further adjust grid layout for the new 9x7 dimensions if needed.
*   **Refactor Shared UI:** Extract the new Top HUD code (`_buildTopArea`, `_buildTopResource`) into a shared widget used by both `GameGridScreen` and `MapScreen`.
*   **Content Expansion:**
    *   Populate `mergeItemsByEmoji` map in `lib/models/merge_trees.dart` with all items.
    *   Add more merge chains, generators, orders (using new items), and unlockable zones/map areas.
*   **Balancing:** Fine-tune order requirements, rewards, generator cooldowns/costs (cooldown currently disabled), and level-up order counts for the new progression system. Balance XP rewards if XP is kept for other purposes.
*   **Testing:** Implement automated tests, especially for the new leveling and order systems. Re-enable and test cooldowns later.

## Active Decisions and Considerations

*   **Shared UI Components:** The new Top HUD logic is currently only in `GameGridScreen` and needs to be added to `MapScreen` and potentially refactored.
*   **Placeholders:** The UI currently uses placeholder emojis/icons. Bottom Info Bar text is dynamic but needs polish.
*   **Leveling System:** The new order-based leveling system needs balancing. XP system is currently unused for leveling.
*   **Generator Cooldowns:** Currently disabled for testing/simplicity. Need to be re-enabled and balanced.
*   **Data Modeling:** (Existing consideration) Evaluate grid state storage efficiency.
*   **Save Frequency:** (Existing consideration) Determine optimal save frequency.
*   **Error Handling:** (Existing consideration) Improve Isar error handling.

## Important Patterns and Preferences

*   Use Riverpod for all state management.
*   Use Isar for local persistence.
*   Keep models immutable where possible.
*   Use asynchronous operations for I/O.
*   Leveling can be tied to different metrics (XP vs. Orders).

## Learnings and Project Insights

*   Isar is relatively easy to integrate and use for local persistence.
*   Riverpod's provider pattern simplifies state management and UI updates.
*   Careful data modeling is crucial for efficient persistence and retrieval.
*   Updating Isar models requires running `build_runner`.
*   Clear visual references are essential for UI tasks.
