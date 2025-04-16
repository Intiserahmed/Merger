# Progress: Merger Game

## What Works

*   **Core Gameplay Loop:** Generating, merging, and delivering items to fulfill orders is functional.
*   **XP and Leveling:** XP is awarded, and the player levels up, gaining increased max energy.
*   **Zone Unlocking:** Players can unlock new zones by meeting level and coin requirements.
*   **Persistence:** Game state is saved and loaded correctly using Isar.

## What's Left to Build

*   **UI Polish:** The UI is currently functional but lacks visual appeal.
*   **Content Expansion:** More items, generators, orders, and zones are needed to provide a longer and more varied gameplay experience.
*   **Balancing:** The game's economy and progression need to be carefully balanced to ensure a smooth and engaging experience.
*   **Testing:** Automated tests are needed to ensure the game's core mechanics and persistence are working correctly.
*   **Advanced Features:** Consider adding more advanced features like:
    *   Achievements
    *   Daily Quests
    *   Social Features (leaderboards, sharing)
    *   More complex merge chains
    *   More varied generator types

## Current Status

The game is in a playable state with the core mechanics implemented. Persistence is working, allowing players to save and resume their progress.

## Known Issues

*   **Limited Content:** The game currently has a limited number of items, generators, and orders.
*   **Basic UI:** The UI is functional but lacks visual polish.
*   **No Automated Testing:** There are currently no automated tests in place.
*   **Hardcoded Values:** Some values (like initial grid layout, unlock costs) are hardcoded and should be moved to a configuration file or data source.

## Evolution of Project Decisions

*   **State Management:** Initially considered a simpler state management solution but decided to use Riverpod for its scalability and testability.
*   **Persistence:** Initially considered using SharedPreferences but switched to Isar for its performance and type safety.
*   **UI:** Started with basic emoji-based UI for rapid prototyping but plan to replace with more visually appealing assets.
