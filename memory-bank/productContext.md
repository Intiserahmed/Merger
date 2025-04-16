# Product Context: Merger Game

## Problem Solved

Provides a casual, engaging mobile game experience centered around the satisfying mechanic of merging items and fulfilling goals. Offers a sense of progression through leveling, unlocking new content, and resource management.

## How It Should Work (User Experience)

1.  **Core Loop:**
    *   Players see a grid with items and generators.
    *   They tap generators or a spawn button (costing energy) to create base items.
    *   They drag identical items onto each other to merge them into higher-tier items.
    *   Players observe active orders requiring specific items.
    *   When they have the required items on the grid, they tap a "Deliver" button on the order.
    *   Items are removed from the grid, and the player receives rewards (Coins, XP).
    *   A new order appears.
2.  **Progression:**
    *   Gaining XP from merging and orders fills a level bar.
    *   Reaching XP thresholds triggers a level-up, granting benefits like refilled/increased max energy.
3.  **Expansion:**
    *   Locked areas are visible on the grid.
    *   Tapping a locked area shows requirements (Level, Coins).
    *   If requirements are met, the player can confirm the unlock, spending coins.
    *   The area becomes usable grid space.
4.  **Resource Management:**
    *   Energy is required for actions (spawning, generating) and regenerates over time.
    *   Coins are earned and spent on unlocks.
5.  **Persistence:** The game automatically saves progress (grid state, player stats, orders, unlocks) so the player can resume later.

## User Experience Goals

*   **Satisfying Merges:** The core merge action should feel intuitive and rewarding.
*   **Clear Progression:** Players should easily understand how to level up, what orders require, and how to unlock new areas.
*   **Balanced Pace:** The game should offer a steady stream of tasks (orders) and progression milestones without feeling too grindy or too fast.
*   **Casual Play:** Allow for short play sessions; progress should be saved reliably.
