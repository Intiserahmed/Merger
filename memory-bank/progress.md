# Progress: Merger Game

## What Works

*   **Core Gameplay Loop:** Generating items via initial generators (Camp, Mine, Workshop), merging (Plant `🌱` and Tool `🔧` sequences), and delivering items to fulfill orders is functional. Manual spawning is removed.
*   **Leveling:** Leveling up is now based on completing a set number of orders per level (`_totalOrdersPerLevel` in `player_provider.dart`). Leveling up grants increased max energy. XP is tracked but currently decoupled from leveling.
*   **Order System:** Orders are generated based on player level (`_ordersByLevel` in `order_provider.dart`), starting simple. Completing an order triggers the leveling check.
*   **Zone Unlocking:** Players can unlock new zones by meeting level and coin requirements (unchanged mechanism, but level is now tied to orders).
*   **Persistence:** Game state (including order completion progress) is saved and loaded correctly using Isar. `build_runner` executed successfully after model changes.
*   **UI Structure:**
    *   `GameGridScreen` has a new Top HUD, Order Display, and Bottom Info Bar layout (using placeholders). It includes chessboard background and item shadows.
    *   `MapScreen` exists with the *old* status bar and a placeholder for map content.
*   **Player Stats:** Energy, Coins, and Gems are tracked via `PlayerStatsNotifier`.
*   **Screen Navigation:** Basic navigation between `GameGridScreen` and `MapScreen` is implemented using a single FAB on `GameGridScreen`.
*   **Merge Sequences:** Both Plant (`🌱`...) and Tool (`🔧`...) merge sequences are defined with logic in `GridNotifier`.
*   **Initial Setup:** Camp, Mine, and Workshop generators are placed on the grid at startup. Configuration for Mine (`⛏️`) added.
*   **Generator Activation:** Cooldown check is temporarily disabled.

## What's Left to Build

*   **Map Screen Implementation:** Replace the placeholder with actual map graphics, navigation, and potentially zone previews/interactions. Update its Top HUD to match `GameGridScreen`.
*   **Grid UI Polish & Refinement:**
    *   Replace placeholder emojis/icons in `GameGridScreen`'s Top HUD (`👤`, `🪙`), Order Display (`🧑`), and Bottom Info Bar (`ℹ️`) with actual assets/icons.
    *   Implement dynamic text updates for the Bottom Info Bar based on selected tile (Partially done, needs polish).
    *   Implement energy cooldown display in the Top HUD.
    *   Refine tile sizing, spacing, and item shadow appearance.
    *   Implement animations and visual feedback for merges, unlocks, etc.
*   **Refactor Shared UI:** Extract the new Top HUD code (`_buildTopArea`, `_buildTopResource`) into a shared widget used by both `GameGridScreen` and `MapScreen`.
*   **Content Expansion:**
    *   Populate `mergeItemsByEmoji` map in `lib/models/merge_trees.dart` with all items.
    *   Add more merge chains, generators, orders (using new items), and unlockable zones/map areas.
*   **Balancing:** Fine-tune order requirements, rewards, generator cooldowns/costs, and level-up order counts for the new progression system. Balance XP rewards if XP is kept for other purposes.
*   **Testing:** Implement automated tests for core mechanics, UI interactions, persistence, and the new leveling/order system.
*   **Advanced Features:** (Same as before) Achievements, Quests, Social, etc.

## Current Status

The game now features two distinct merge sequences (Plants and Tools). The `GameGridScreen` UI has been significantly overhauled to match specific design requirements, using placeholder elements for icons and some dynamic content. The core mechanics remain functional for both merge types. The `MapScreen` exists but is largely unimplemented and uses the old status bar.

## Known Issues

*   **Map Screen Placeholder:** The map screen is not yet functional and uses the old status bar.
*   **Grid Screen Placeholders:** Top HUD, Order Display, and Bottom Info Bar use placeholder emojis/icons. Bottom Info Bar text is dynamic but needs polish. Energy cooldown is not displayed.
*   **Shared UI Needed:** The new Top HUD logic needs to be shared between screens.
*   **Limited Content:** Needs more items, orders, etc. `mergeItemsByEmoji` map needs full population.
*   **Balancing Needed:** Game economy and progression (orders per level, rewards, costs) require tuning for the new system.
*   **No Automated Testing:** Tests are still pending. Re-enable and test cooldowns later.
*   **Hardcoded Values:** Some configuration values remain hardcoded (e.g., generator positions, order definitions).

## Evolution of Project Decisions

*   **State Management:** Consistent use of Riverpod.
*   **Persistence:** Consistent use of Isar.
*   **UI:** Moved from basic emoji prototyping towards a more structured UI based on visual references. Replaced number-based merging with emoji-based merging (plant sequence). Added Gems as a player resource. Introduced a second merge sequence (Tools). Overhauled `GameGridScreen` UI based on specific design snippets, using placeholders initially. Changed grid dimensions to 9x7 and reduced tile size. **Refactored progression to be order-based, placed initial generators, and removed manual spawning.**
