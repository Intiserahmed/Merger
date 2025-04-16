// lib/providers/player_provider.dart
import 'dart:async'; // Import async for Timer
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_stats.dart'; // Import the model
import '../models/tile_unlock.dart'; // Import TileUnlock for the new method
import 'expansion_provider.dart'; // Import expansion provider
// import 'grid_provider.dart'; // Import grid provider if needed for tile updates

// Individual providers for simple stats (easy to watch individually)
// Consider removing these if PlayerStatsNotifier is the primary way to manage stats
final energyProvider = StateProvider<int>((ref) => 100); // Initial energy
final coinsProvider = StateProvider<int>((ref) => 50); // Initial coins
final xpProvider = StateProvider<int>((ref) => 0); // Initial XP
final playerLevelProvider = StateProvider<int>((ref) => 1); // Initial Level

// --- OR ---

// Define energy cost for spawning an item
const int spawnEnergyCost =
    10; // Keep this if used elsewhere, otherwise can be removed if generators have costs

// A single Notifier for the whole PlayerStats object (better if stats often change together)
class PlayerStatsNotifier extends StateNotifier<PlayerStats> {
  final Ref ref; // Inject Ref
  Timer? _energyRegenTimer; // Timer for energy regeneration

  // Initialize with a non-const PlayerStats instance and start the timer
  PlayerStatsNotifier(this.ref) : super(PlayerStats()) {
    // Initial default stats
    _startEnergyRegeneration();
  }

  // --- Energy Regeneration ---
  void _startEnergyRegeneration() {
    // Cancel any existing timer
    _energyRegenTimer?.cancel();
    // Start a new timer to regenerate 1 energy every 60 seconds
    _energyRegenTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (state.energy < state.maxEnergy) {
        // Create a new state object with updated energy
        // Isar manages the ID, so we don't pass it here.
        state = PlayerStats(
          level: state.level,
          xp: state.xp,
          coins: state.coins,
          energy: state.energy + 1, // Increment energy
          maxEnergy: state.maxEnergy,
          initialUnlockedZoneIds: state.unlockedZoneIds, // Keep existing zones
        );
      } else {
        // Optional: Could cancel the timer if energy is full and restart when spent,
        // but periodic check is simpler and often sufficient.
      }
    });
  }

  // Override dispose to cancel the timer when the notifier is no longer used
  @override
  void dispose() {
    _energyRegenTimer?.cancel();
    super.dispose();
  }

  // --- Existing Methods (Modified to use the new state structure) ---
  void addXp(int amount) {
    // Create a new state object
    state = PlayerStats(
      level: state.level,
      xp: state.xp + amount, // Update XP
      coins: state.coins,
      energy: state.energy,
      maxEnergy: state.maxEnergy,
      initialUnlockedZoneIds: state.unlockedZoneIds, // Keep existing zones
    );
    // Add level up logic here later (Milestone 3)
    // TODO: Implement level up check based on XP thresholds
    _checkLevelUp(); // Check for level up after adding XP
  }

  /// Checks if the current XP meets the threshold for the next level.
  void _checkLevelUp() {
    final currentLevel = state.level;
    final currentXp = state.xp;
    final xpNeeded = getXpNeededForNextLevel(currentLevel);

    // Use cumulative XP for checking against total XP
    final totalXpNeededForNextLevel = getTotalXpForLevel(currentLevel + 1);

    // Check if current XP meets the requirement for the *next* level
    if (currentXp >= totalXpNeededForNextLevel) {
      // Potentially handle multiple level ups in one go if a large amount of XP is gained
      // For simplicity, we'll just do one level up at a time for now.
      levelUp();
      // Optional: Recursively call _checkLevelUp() again if player might gain multiple levels at once
      // _checkLevelUp();
    }
  }

  /// Attempts to spend energy. Returns true if successful, false otherwise.
  bool spendEnergy(int amount) {
    if (state.energy >= amount) {
      // Create a new state object
      state = PlayerStats(
        level: state.level,
        xp: state.xp,
        coins: state.coins,
        energy: state.energy - amount, // Update energy
        maxEnergy: state.maxEnergy,
        initialUnlockedZoneIds: state.unlockedZoneIds, // Keep existing zones
      );
      // Consider restarting the timer here if it was stopped when full
      // _startEnergyRegeneration(); // If implementing stop-when-full logic
      return true; // Energy spent successfully
    } else {
      // Handle insufficient energy (e.g., show message)
      print("Not enough energy!");
      return false; // Failed to spend energy
    }
  }

  /// Adds energy, ensuring it doesn't exceed maxEnergy.
  void addEnergy(int amount) {
    // Create a new state object
    final newEnergy = (state.energy + amount).clamp(
      0,
      state.maxEnergy,
    ); // Clamp between 0 and max
    state = PlayerStats(
      level: state.level,
      xp: state.xp,
      coins: state.coins,
      energy: newEnergy, // Update energy
      maxEnergy: state.maxEnergy,
      initialUnlockedZoneIds: state.unlockedZoneIds, // Keep existing zones
    );
    // Consider restarting the timer here if it was stopped when full and energy was added below max
    // if (newEnergy < state.maxEnergy) _startEnergyRegeneration();
  }

  void addCoins(int amount) {
    // Create a new state object
    state = PlayerStats(
      level: state.level,
      xp: state.xp,
      coins: state.coins + amount, // Update coins
      energy: state.energy,
      maxEnergy: state.maxEnergy,
      initialUnlockedZoneIds: state.unlockedZoneIds, // Keep existing zones
    );
  }

  void spendCoins(int amount) {
    if (state.coins >= amount) {
      // Create a new state object
      state = PlayerStats(
        level: state.level,
        xp: state.xp,
        coins: state.coins - amount, // Update coins
        energy: state.energy,
        maxEnergy: state.maxEnergy,
        initialUnlockedZoneIds: state.unlockedZoneIds, // Keep existing zones
      );
    } else {
      print("Not enough coins!");
      // throw Exception("Not enough coins"); // Or throw
    }
  }

  void levelUp() {
    // Example level up logic
    // Create a new state object
    state = PlayerStats(
      level: state.level + 1, // Update level
      xp: 0, // Reset XP on level up? Consider carrying over excess XP
      coins: state.coins,
      // Increase max energy and refill current energy to the new max
      maxEnergy: state.maxEnergy + 10, // Increase max energy by 10
      energy: state.maxEnergy + 10, // Refill energy to the new max
      initialUnlockedZoneIds: state.unlockedZoneIds, // Keep existing zones
    );
    print(
      "Level Up! Reached level ${state.level}. Max energy increased to ${state.maxEnergy}.",
    );
    // Consider restarting the timer here if it was stopped when full
    // _startEnergyRegeneration(); // If implementing stop-when-full logic
  }

  // Load/Save methods for Milestone 3
  void loadStats(PlayerStats loadedStats) {
    // Ensure the loaded stats object is assigned correctly
    // We create a new instance based on the loaded data, Isar handles the ID.
    state = PlayerStats(
      level: loadedStats.level,
      xp: loadedStats.xp,
      coins: loadedStats.coins,
      energy: loadedStats.energy,
      maxEnergy: loadedStats.maxEnergy,
      // Load unlocked zones as well
      initialUnlockedZoneIds: loadedStats.unlockedZoneIds,
    );
    // Ensure timer restarts if loading changes energy state significantly
    _startEnergyRegeneration();
  }

  // --- Zone Unlocking ---
  /// Attempts to unlock a zone. Returns true if successful.
  bool unlockZone(TileUnlock zoneToUnlock) {
    // 1. Check Requirements
    if (state.level < zoneToUnlock.requiredLevel) {
      print(
        "Cannot unlock zone '${zoneToUnlock.id}'. Requires level ${zoneToUnlock.requiredLevel}, player is level ${state.level}.",
      );
      // Optional: Show feedback to user
      return false;
    }
    if (state.coins < zoneToUnlock.unlockCostCoins) {
      print(
        "Cannot unlock zone '${zoneToUnlock.id}'. Requires ${zoneToUnlock.unlockCostCoins} coins, player has ${state.coins}.",
      );
      // Optional: Show feedback to user
      return false;
    }

    // 2. Spend Coins (using existing method which handles the state update)
    spendCoins(
      zoneToUnlock.unlockCostCoins,
    ); // Assumes spendCoins doesn't throw

    // 3. Update Unlocked Status (directly modify state)
    // Create a new list with the added zone ID
    final newUnlockedIds = List<String>.from(state.unlockedZoneIds)
      ..add(zoneToUnlock.id);
    // Update the state with the new list
    state = PlayerStats(
      level: state.level,
      xp: state.xp,
      coins: state.coins, // Coins already spent by spendCoins call
      energy: state.energy,
      maxEnergy: state.maxEnergy,
      initialUnlockedZoneIds: newUnlockedIds, // Assign the updated list
    );

    // 4. Optional: Update Grid Tiles (if zone defines specific tiles)
    // This might be better handled by watching unlockedStatusProvider in GridProvider
    // or by passing the gridNotifier reference here.
    // Example (if gridNotifier was passed or read):
    // final gridNotifier = ref.read(gridProvider.notifier);
    // gridNotifier.unlockTilesForZone(zoneToUnlock); // Needs implementation in GridNotifier

    print(
      "Zone '${zoneToUnlock.id}' unlocked successfully for ${zoneToUnlock.unlockCostCoins} coins!",
    );
    return true;
  }
}

final playerStatsProvider =
    StateNotifierProvider<PlayerStatsNotifier, PlayerStats>((ref) {
      // Pass the ref to the constructor
      return PlayerStatsNotifier(ref);
    });

// Choose EITHER individual providers OR the combined Notifier based on preference.
// The Notifier is generally better for related state and logic encapsulation.

// --- XP Thresholds for Leveling Up ---
// Example: Level 2 needs 100 XP, Level 3 needs 250 more (total 350), etc.
const Map<int, int> xpPerLevel = {
  1: 100, // XP needed to reach level 2
  2: 250, // Additional XP needed to reach level 3 (current XP must be >= 100 + 250)
  3: 500, // Additional XP needed to reach level 4 (current XP must be >= 100 + 250 + 500)
  // Add more levels as needed
};

// Helper to get total XP required for a given level
int getTotalXpForLevel(int level) {
  int totalXp = 0;
  // Calculate cumulative XP needed for the *start* of the target level
  for (int i = 1; i < level; i++) {
    totalXp += xpPerLevel[i] ?? 0;
  }
  return totalXp;
}

// Helper to get XP needed for the *next* level from the current level's base
int getXpNeededForNextLevel(int currentLevel) {
  return xpPerLevel[currentLevel] ??
      999999; // Return a large number if level cap reached
}
