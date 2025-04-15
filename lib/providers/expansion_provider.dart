// lib/providers/expansion_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tile_unlock.dart'; // Or Zone
import 'player_provider.dart'; // To watch player level

// Assume you have a predefined list of all possible zones/unlocks
final List<TileUnlock> _allUnlockableTiles = [
  TileUnlock(id: 'zone_beach_1', requiredLevel: 2, unlockCostCoins: 100),
  TileUnlock(id: 'zone_forest_1', requiredLevel: 5, unlockCostCoins: 500),
  // ... more zones
];

// Provider for the master list (could load from JSON/config)
final allUnlocksProvider = Provider<List<TileUnlock>>((ref) {
  return _allUnlockableTiles;
});

// Provider for *which ones the player has actually unlocked*
// This state needs to be persistent (Milestone 3)
final unlockedStatusProvider = StateProvider<Set<String>>((ref) {
  // Load from save data in Milestone 3
  return <String>{}; // Start with none unlocked
});

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
