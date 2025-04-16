// lib/providers/expansion_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tile_unlock.dart'; // Or Zone
import 'player_provider.dart'; // To watch player level

// Assume you have a predefined list of all possible zones/unlocks
// Define the areas covered by each zone
final List<TileUnlock> _allUnlockableTiles = [
  TileUnlock(
    id: 'zone_beach_1',
    requiredLevel: 2,
    unlockCostCoins: 100,
    // Example: Covers a 2x2 area in the bottom right (using hardcoded 11x6 grid size)
    coveredTiles: [
      Point(9, 4), // row 9, col 4
      Point(9, 5), // row 9, col 5
      Point(10, 4), // row 10, col 4
      Point(10, 5), // row 10, col 5
    ],
  ),
  TileUnlock(
    id: 'zone_forest_1',
    requiredLevel: 5,
    unlockCostCoins: 500,
    // Example: Covers a 3x2 area near the top right (using hardcoded 11x6 grid size)
    coveredTiles: [
      Point(0, 4), // row 0, col 4
      Point(0, 5), // row 0, col 5
      Point(1, 4), // row 1, col 4
      Point(1, 5), // row 1, col 5
      Point(2, 4), // row 2, col 4
      Point(2, 5), // row 2, col 5
    ],
  ),
  // ... more zones with defined coveredTiles
];

// Note: rowCount and colCount are now defined in grid_provider.dart
// The _allUnlockableTiles list uses hardcoded values based on those constants.

// Provider for the master list (could load from JSON/config)
final allUnlocksProvider = Provider<List<TileUnlock>>((ref) {
  return _allUnlockableTiles;
});

// Provider for *which ones the player has actually unlocked*
// This now derives directly from the PlayerStats state.
final unlockedStatusProvider = Provider<Set<String>>((ref) {
  // Watch the player stats and select the unlocked zones, converting to a Set
  final unlockedIdsList = ref.watch(playerStatsProvider).unlockedZoneIds;
  return unlockedIdsList.toSet();
});
// Note: The actual modification of unlocked zones now happens in PlayerStatsNotifier.unlockZone

// Derived provider: Which zones CAN the player currently see/interact with?
final availableUnlocksProvider = Provider<List<TileUnlock>>((ref) {
  final playerLevel = ref.watch(
    playerLevelProvider,
  ); // Watch simple level provider
  // OR: final playerLevel = ref.watch(playerStatsProvider).level; // Watch notifier
  final allUnlocks = ref.watch(allUnlocksProvider);
  final unlockedIds = ref.watch(unlockedStatusProvider);

  return allUnlocks.where((unlock) {
    // Show if level requirement met AND it's not already unlocked
    return playerLevel >= unlock.requiredLevel &&
        !unlockedIds.contains(unlock.id);
  }).toList();
});

// Derived provider: Which zones are *visibly unlocked* on the map?
final visuallyUnlockedZonesProvider = Provider<List<TileUnlock>>((ref) {
  final allUnlocks = ref.watch(allUnlocksProvider);
  final unlockedIds = ref.watch(unlockedStatusProvider);
  return allUnlocks.where((unlock) => unlockedIds.contains(unlock.id)).toList();
});

// You'll need a Notifier/method to handle the actual unlocking action (spending coins, updating unlockedStatusProvider)
// This could go in PlayerStatsNotifier or a dedicated ExpansionNotifier
