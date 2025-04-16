# Project Brief: Merger Game

## Core Goal

To create a mobile merge game using Flutter where players merge items on a grid to fulfill orders, gain experience, level up, unlock new areas, and progress.

## Key Features

*   **Grid-Based Merging:** Players interact with items on a grid, merging identical items to create higher-tier items.
*   **Item Generation:** Items are generated through manual spawning (costing energy) and automated generators (costing energy, with cooldowns).
*   **Order Fulfillment:** Players fulfill randomly generated orders requiring specific merged items.
*   **Progression System:**
    *   Gain XP for merging and fulfilling orders.
    *   Level up based on XP thresholds.
    *   Leveling up provides benefits (e.g., increased max energy).
*   **Zone Unlocking:** Unlock new grid areas by meeting level and coin requirements.
*   **Resource Management:** Manage player resources like Energy (regenerates over time) and Coins (earned from orders/generators).
*   **Persistence:** Game state (grid, player stats, orders, unlocked zones) is saved locally using Isar database.

## Target Platform

*   Mobile (Android/iOS via Flutter).

## Current Status

*   Core mechanics (merging, generation, orders, leveling, unlocking, persistence) are implemented.
*   Basic UI using Flutter and Riverpod for state management.
