# Progress: Merger Game

## What Works

*   **Core Gameplay Loop:** Generating, merging (Plant `🌱` and Tool `🔧` sequences), and delivering items to fulfill orders is functional.
*   **XP and Leveling:** XP is awarded (for both merge sequences), and the player levels up, gaining increased max energy.
*   **Zone Unlocking:** Players can unlock new zones by meeting level and coin requirements.
*   **Persistence:** Game state (including gems) is saved and loaded correctly using Isar.
*   **UI Structure:**
    *   `GameGridScreen` has a new Top HUD, Order Display, and Bottom Info Bar layout (using placeholders). It includes chessboard background and item shadows.
    *   `MapScreen` exists with the *old* status bar and a placeholder for map content.
*   **Player Stats:** Energy, Coins, and Gems are tracked via `PlayerStatsNotifier`.
*   **Screen Navigation:** Basic navigation between `GameGridScreen` and `MapScreen` is implemented using FABs.
*   **Merge Sequences:** Both Plant (`🌱`...) and Tool `🔧`...) merge sequences are defined with logic in `GridNotifier`.

## What's Left to Build

*   **Map Screen Implementation:** Replace the placeholder with actual map graphics, navigation, and potentially zone previews/interactions. Update its Top HUD to match `GameGridScreen`.
*   **Grid UI Polish & Refinement:**
    *   Replace placeholder emojis/icons in `GameGridScreen`'s Top HUD (`👤`, `🪙`), Order Display (`🧑`), and Bottom Info Bar (`ℹ️`) with actual assets/icons.
    *   Implement dynamic text updates for the Bottom Info Bar based on selected tile.
    *   Implement energy cooldown display in the Top HUD.
    *   Refine tile sizing, spacing, and item shadow appearance.
    *   Implement animations and visual feedback for merges, unlocks, etc.
*   **Refactor Shared UI:** Extract the new Top HUD code (`_buildTopArea`, `_buildTopResource`) into a shared widget used by both `GameGridScreen` and `MapScreen`.
*   **Content Expansion:**
    *   Add the new Workshop generator (`🏭`) to the initial grid setup or make it unlockable.
    *   Add more merge chains, generators, orders (using new items), and unlockable zones/map areas.
*   **Balancing:** Fine-tune XP gains, coin/gem rewards, energy costs, generator cooldowns, and unlock requirements for *both* merge sequences.
*   **Testing:** Implement automated tests for core mechanics, UI interactions, and persistence.
*   **Advanced Features:** (Same as before) Achievements, Quests, Social, etc.

## Current Status

The game now features two distinct merge sequences (Plants and Tools). The `GameGridScreen` UI has been significantly overhauled to match specific design requirements, using placeholder elements for icons and some dynamic content. The core mechanics remain functional for both merge types. The `MapScreen` exists but is largely unimplemented and uses the old status bar.

## Known Issues

*   **Map Screen Placeholder:** The map screen is not yet functional and uses the old status bar.
*   **Grid Screen Placeholders:** Top HUD, Order Display, and Bottom Info Bar use placeholder emojis/icons. Bottom Info Bar text is static. Energy cooldown is not displayed.
*   **Shared UI Needed:** The new Top HUD logic needs to be shared between screens.
*   **Limited Content:** Needs more items, generators (Workshop not placed by default), orders, etc.
*   **Balancing Needed:** Game economy and progression require tuning for both merge sequences.
*   **No Automated Testing:** Tests are still pending.
*   **Hardcoded Values:** Some configuration values remain hardcoded.

## Evolution of Project Decisions

*   **State Management:** Consistent use of Riverpod.
*   **Persistence:** Consistent use of Isar.
*   **UI:** Moved from basic emoji prototyping towards a more structured UI based on visual references. Replaced number-based merging with emoji-based merging (plant sequence). Added Gems as a player resource. **Introduced a second merge sequence (Tools). Overhauled `GameGridScreen` UI based on specific design snippets, using placeholders initially. Changed grid dimensions to 9x7 and reduced tile size.**
