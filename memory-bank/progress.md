# Progress: Merger Game

## What Works

*   **Core Gameplay Loop:** Generating, merging (now with plant emojis), and delivering items to fulfill orders is functional.
*   **XP and Leveling:** XP is awarded (including for plant merges), and the player levels up, gaining increased max energy.
*   **Zone Unlocking:** Players can unlock new zones by meeting level and coin requirements.
*   **Persistence:** Game state (including gems) is saved and loaded correctly using Isar.
*   **Basic UI Structure:**
    *   `GameGridScreen` has a custom status bar, chessboard background, adjusted tile display (no numbers), and placeholders.
    *   `MapScreen` exists with the same status bar and a placeholder for map content.
*   **Player Stats:** Energy, Coins, and Gems are tracked via `PlayerStatsNotifier`.
*   **Screen Navigation:** Basic navigation between `GameGridScreen` and `MapScreen` is implemented using FABs.

## What's Left to Build

*   **Map Screen Implementation:** Replace the placeholder with actual map graphics, navigation, and potentially zone previews/interactions.
*   **UI Polish & Refinement:**
    *   Replace placeholders on `GameGridScreen` (e.g., bottom info bar) with final UI.
    *   Refine tile sizing and spacing for better visual appeal.
    *   Implement animations and visual feedback for merges, unlocks, etc.
    *   Refactor the duplicated status bar code into a shared widget.
*   **Content Expansion:** Add more merge chains (beyond plants), generators, orders, and unlockable zones/map areas.
*   **Balancing:** Fine-tune XP gains, coin/gem rewards, energy costs, generator cooldowns, and unlock requirements.
*   **Testing:** Implement automated tests for core mechanics, UI interactions, and persistence.
*   **Advanced Features:** (Same as before) Achievements, Quests, Social, etc.

## Current Status

The game has undergone a significant UI restructuring. The core mechanics remain functional, adapted for the new emoji merge sequence. A Map screen has been added but requires implementation. The Grid screen is visually closer to the target reference but needs further refinement and placeholder replacement.

## Known Issues

*   **Map Screen Placeholder:** The map screen is not yet functional.
*   **Grid Screen Placeholders:** Some UI elements on the grid screen are still placeholders.
*   **Duplicated UI Code:** The status bar logic exists in both `GameGridScreen` and `MapScreen`.
*   **Limited Content:** Still needs more items, merge chains, generators, orders, etc.
*   **Balancing Needed:** Game economy and progression require tuning.
*   **No Automated Testing:** Tests are still pending.
*   **Hardcoded Values:** Some configuration values remain hardcoded.

## Evolution of Project Decisions

*   **State Management:** Consistent use of Riverpod.
*   **Persistence:** Consistent use of Isar.
*   **UI:** Moved from basic emoji prototyping towards a more structured UI based on visual references. Replaced number-based merging with emoji-based merging (plant sequence). Added Gems as a player resource.
