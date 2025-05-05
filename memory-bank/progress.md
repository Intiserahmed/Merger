# Progress: Merger Game

## What Works

*   **Core Gameplay Loop:** Generating items via initial generators (Camp, Mine, Workshop), merging (Plant `🌱` and Tool `🔧` sequences), and delivering items to fulfill orders is functional. Manual spawning is removed.
*   **Leveling (Infrastructure-Based):** Leveling up is triggered by maxing out the infrastructure upgrades for the current player level (`maxInfrastructureUpgrade` in `player_provider.dart`). Leveling up grants increased max energy. XP is tracked but decoupled from leveling.
*   **Order System:** Orders are generated based on player level (`_ordersByLevel` in `order_provider.dart`). Completing an order grants rewards (coins, XP) but does *not* trigger a leveling check.
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

## What's Left to Build (Prioritized)

*   **Refactor Shared UI:** Extract the new Top HUD code (`_buildTopArea`, `_buildTopResource`) into a shared widget for `GameGridScreen` and `MapScreen`. (Highest Priority)
*   **Grid UI Polish & Refinement:**
    *   Replace placeholder emojis/icons in Top HUD (`👤`, `🪙`), Order Display (`🧑`), Bottom Info Bar (`ℹ️`).
    *   Implement dynamic text updates for Bottom Info Bar (Needs polish).
    *   Implement energy cooldown display in Top HUD.
    *   Refine tile sizing, spacing, shadows.
    *   Implement animations/feedback (merges, unlocks).
*   **Map Screen Implementation:**
    *   Integrate the shared Top HUD.
    *   Replace placeholder with actual map graphics, navigation, zone previews.
*   **Content Expansion:**
    *   **Crucial:** Populate `mergeItemsByEmoji` map in `lib/models/merge_trees.dart`.
    *   Add more merge chains, generators, orders, unlockable zones/map areas.
*   **Balancing:** Fine-tune order requirements, rewards, generator cooldowns/costs (cooldown disabled), and **infrastructure upgrade costs**. Balance XP if kept.
*   **Testing:** Implement automated tests (leveling, orders, UI). Re-enable and test cooldowns.
*   **Advanced Features:** Achievements, Quests, Social, etc.

## Current Status

The game now features two distinct merge sequences (Plants and Tools). The `GameGridScreen` UI has been significantly overhauled to match specific design requirements, using placeholder elements for icons and some dynamic content. The core mechanics remain functional for both merge types. The `MapScreen` exists but is largely unimplemented and uses the old status bar.

## Known Issues

*   **Shared UI Needed:** The new Top HUD logic is not yet extracted into a shared widget. (Top Priority Block)
*   **Map Screen Placeholder:** The map screen is not functional and uses the old status bar (Blocked by Shared UI).
*   **Grid Screen Placeholders:** Top HUD, Order Display, Bottom Info Bar use placeholders. Bottom Info Bar text needs polish. Energy cooldown not displayed.
*   **Limited Content:** Needs more items, orders, etc. `mergeItemsByEmoji` map needs full population (Crucial).
*   **Balancing Needed:** Game economy and progression require tuning. Generator cooldowns disabled.
*   **No Automated Testing:** Tests are pending.
*   **Hardcoded Values:** Some configuration values remain hardcoded.

## Evolution of Project Decisions

*   **State Management:** Consistent use of Riverpod.
*   **Persistence:** Consistent use of Isar.
*   **UI:** Moved from basic emoji prototyping towards a more structured UI based on visual references. Replaced number-based merging with emoji-based merging (plant sequence). Added Gems as a player resource. Introduced a second merge sequence (Tools). Overhauled `GameGridScreen` UI based on specific design snippets, using placeholders initially. Changed grid dimensions to 9x7 and reduced tile size. **Refactored progression to be infrastructure-based, placed initial generators, and removed manual spawning.**
