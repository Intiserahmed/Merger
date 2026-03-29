// lib/providers/expansion_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tile_unlock.dart'; // Or Zone
import 'player_provider.dart'; // To watch player level

// All unlockable zones. zone_starter is unlocked by default at game start.
final List<TileUnlock> _allUnlockableTiles = [
  // ── Starter region ─────────────────────────────────────────────────────
  TileUnlock(
    id: 'zone_starter',
    requiredLevel: 1,
    unlockCostCoins: 0,
    coveredTiles: [],
  ),
  TileUnlock(
    id: 'zone_fishing',
    requiredLevel: 2,
    unlockCostCoins: 80,
    coveredTiles: [],
  ),
  TileUnlock(
    id: 'zone_farmlands',
    requiredLevel: 2,
    unlockCostCoins: 80,
    coveredTiles: [],
  ),

  // ── Coastal region ──────────────────────────────────────────────────────
  TileUnlock(
    id: 'zone_beach_1',
    requiredLevel: 3,
    unlockCostCoins: 150,
    coveredTiles: [
      Point(7, 4), Point(7, 5), Point(7, 6),
      Point(8, 4), Point(8, 5), Point(8, 6),
    ],
  ),
  TileUnlock(
    id: 'zone_harbor',
    requiredLevel: 4,
    unlockCostCoins: 300,
    coveredTiles: [],
  ),
  TileUnlock(
    id: 'zone_coral_reef',
    requiredLevel: 6,
    unlockCostCoins: 550,
    coveredTiles: [],
  ),
  TileUnlock(
    id: 'zone_pirate_cove',
    requiredLevel: 9,
    unlockCostCoins: 1100,
    coveredTiles: [],
  ),

  // ── Forest region ───────────────────────────────────────────────────────
  TileUnlock(
    id: 'zone_forest_1',
    requiredLevel: 3,
    unlockCostCoins: 150,
    coveredTiles: [
      Point(0, 4), Point(0, 5), Point(0, 6),
      Point(1, 4), Point(1, 5), Point(1, 6),
      Point(2, 4), Point(2, 5), Point(2, 6),
    ],
  ),
  TileUnlock(
    id: 'zone_swamp',
    requiredLevel: 4,
    unlockCostCoins: 320,
    coveredTiles: [],
  ),
  TileUnlock(
    id: 'zone_mushroom',
    requiredLevel: 5,
    unlockCostCoins: 420,
    coveredTiles: [],
  ),
  TileUnlock(
    id: 'zone_treehouse',
    requiredLevel: 7,
    unlockCostCoins: 750,
    coveredTiles: [],
  ),

  // ── Mountain / Mine region ──────────────────────────────────────────────
  TileUnlock(
    id: 'zone_ruins',
    requiredLevel: 3,
    unlockCostCoins: 200,
    coveredTiles: [],
  ),
  TileUnlock(
    id: 'zone_mine_1',
    requiredLevel: 4,
    unlockCostCoins: 400,
    coveredTiles: [
      Point(3, 5), Point(3, 6),
      Point(4, 6),
      Point(5, 5), Point(5, 6),
    ],
  ),
  TileUnlock(
    id: 'zone_volcano',
    requiredLevel: 6,
    unlockCostCoins: 600,
    coveredTiles: [],
  ),

  // ── Endgame region ───────────────────────────────────────────────────────
  TileUnlock(
    id: 'zone_castle_1',
    requiredLevel: 5,
    unlockCostCoins: 600,
    coveredTiles: [
      Point(0, 0), Point(0, 1), Point(0, 2),
      Point(1, 0), Point(1, 1), Point(1, 2),
      Point(2, 0), Point(2, 1), Point(2, 2),
    ],
  ),
  TileUnlock(
    id: 'zone_glacier',
    requiredLevel: 8,
    unlockCostCoins: 900,
    coveredTiles: [],
  ),
  TileUnlock(
    id: 'zone_capital',
    requiredLevel: 10,
    unlockCostCoins: 1500,
    coveredTiles: [],
  ),
  TileUnlock(
    id: 'zone_dragon_lair',
    requiredLevel: 10,
    unlockCostCoins: 2500,
    coveredTiles: [],
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
  final playerLevel = ref.watch(playerStatsProvider.select((s) => s.level));
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
