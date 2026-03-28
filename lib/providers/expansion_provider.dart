// lib/providers/expansion_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tile_unlock.dart'; // Or Zone
import 'player_provider.dart'; // To watch player level

// All unlockable zones. zone_starter is unlocked by default at game start.
final List<TileUnlock> _allUnlockableTiles = [
  TileUnlock(
    id: 'zone_starter',
    requiredLevel: 1,
    unlockCostCoins: 0,
    coveredTiles: [],
  ),
  TileUnlock(
    id: 'zone_beach_1',
    requiredLevel: 2,
    unlockCostCoins: 100,
    // Bottom-right corner — clear of all generators
    coveredTiles: [
      Point(7, 4), Point(7, 5), Point(7, 6),
      Point(8, 4), Point(8, 5), Point(8, 6),
    ],
  ),
  TileUnlock(
    id: 'zone_forest_1',
    requiredLevel: 3,
    unlockCostCoins: 250,
    // Top-right corner
    coveredTiles: [
      Point(0, 4), Point(0, 5), Point(0, 6),
      Point(1, 4), Point(1, 5), Point(1, 6),
      Point(2, 4), Point(2, 5), Point(2, 6),
    ],
  ),
  TileUnlock(
    id: 'zone_mine_1',
    requiredLevel: 4,
    unlockCostCoins: 400,
    // Right edge — skips (4,5) which is the Workshop generator
    coveredTiles: [
      Point(3, 5), Point(3, 6),
      Point(4, 6),             // (4,5) is Workshop — skip it
      Point(5, 5), Point(5, 6),
    ],
  ),
  TileUnlock(
    id: 'zone_castle_1',
    requiredLevel: 5,
    unlockCostCoins: 600,
    // Top-left corner — clear of all generators
    coveredTiles: [
      Point(0, 0), Point(0, 1), Point(0, 2),
      Point(1, 0), Point(1, 1), Point(1, 2),
      Point(2, 0), Point(2, 1), Point(2, 2),
    ],
  ),
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
