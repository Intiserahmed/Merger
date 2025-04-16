# Active Context: Merger Game

## Current Work Focus

Implementing persistence using Isar database and adding XP/Leveling system.

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

## Next Steps

*   **UI Polish:** Improve the visual presentation of the game, including better tile graphics, animations, and feedback.
*   **Content Expansion:** Add more items, generators, orders, and unlockable zones.
*   **Balancing:** Fine-tune the XP gains, coin rewards, energy costs, and unlock requirements to create a balanced and engaging gameplay experience.
*   **Testing:** Implement automated tests to ensure the core mechanics and persistence are working correctly.

## Active Decisions and Considerations

*   **Data Modeling:** The current approach of saving the entire grid state as individual `TileData` objects might not be the most efficient for large grids. Consider alternative approaches like storing the grid as a compressed data structure or using a more relational database model.
*   **Save Frequency:** Determine the optimal frequency for saving the game state to balance data loss prevention with performance.
*   **Error Handling:** Implement more robust error handling for Isar operations.

## Important Patterns and Preferences

*   Use Riverpod for all state management.
*   Use Isar for local persistence.
*   Keep models immutable where possible.
*   Use asynchronous operations for I/O.

## Learnings and Project Insights

*   Isar is relatively easy to integrate and use for local persistence.
*   Riverpod's provider pattern simplifies state management and UI updates.
*   Careful data modeling is crucial for efficient persistence and retrieval.
