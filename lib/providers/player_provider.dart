// lib/providers/player_provider.dart
import 'dart:async'; // Import async for Timer
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_stats.dart'; // Import the model
import '../models/tile_unlock.dart'; // Import TileUnlock for the new method
import 'expansion_provider.dart'; // Import expansion provider

// Individual providers for simple stats (easy to watch individually) - Keeping for now
// Consider removing these if PlayerStatsNotifier is the primary way to manage stats
final energyProvider = StateProvider<int>((ref) => 100); // Initial energy
final coinsProvider = StateProvider<int>((ref) => 50); // Initial coins
final gemsProvider = StateProvider<int>((ref) => 20); // Initial gems
final xpProvider = StateProvider<int>((ref) => 0); // Initial XP
final playerLevelProvider = StateProvider<int>((ref) => 1); // Initial Level

// --- OR ---

// Define energy cost for spawning an item - Removing as spawn button will be removed
// const int spawnEnergyCost = 10;

// --- Define infrastructure upgrade costs and max level ---
const int maxInfrastructureUpgrade = 5;
const Map<int, int> infrastructureUpgradeCost = {
  // Upgrade Level : Cost
  1: 10, // New cost
  2: 15, // New cost
  3: 20, // New cost
  4: 25, // New cost
  5: 30, // New cost
};
// Define max player level based on infrastructure definitions
const int maxPlayerLevel = 5; // Example: Up to level 5 infrastructure

// A single Notifier for the whole PlayerStats object (better if stats often change together)
class PlayerStatsNotifier extends StateNotifier<PlayerStats> {
  final Ref ref;
  Timer? _energyRegenTimer;

  // Initialize with a non-const PlayerStats instance and start the timer
  PlayerStatsNotifier(this.ref)
    : super(
        // PlayerStats initializes with default infrastructure level ["1:0"]
        PlayerStats(),
      ) {
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
        // Create a new state object, copying all fields and updating energy
        state = PlayerStats(
          level: state.level,
          xp: state.xp,
          coins: state.coins,
          gems: state.gems,
          energy: state.energy + 1, // Update energy
          maxEnergy: state.maxEnergy,
          initialUnlockedZoneIds: state.unlockedZoneIds,
          // Ensure infrastructure data is copied
          initialInfrastructureLevelsData: state.infrastructureLevelsData,
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
      xp: state.xp + amount, // Update XP - Keep XP tracking separate for now
      coins: state.coins,
      gems: state.gems,
      energy: state.energy,
      maxEnergy: state.maxEnergy,
      initialUnlockedZoneIds: state.unlockedZoneIds,
      initialInfrastructureLevelsData: state.infrastructureLevelsData,
    );
    // _checkLevelUp(); // Remove XP-based level up check
  }

  /// Attempts to spend energy. Returns true if successful, false otherwise.
  bool spendEnergy(int amount) {
    if (state.energy >= amount) {
      // Create a new state object
      state = PlayerStats(
        level: state.level,
        xp: state.xp,
        coins: state.coins,
        gems: state.gems,
        energy: state.energy - amount, // Update energy
        maxEnergy: state.maxEnergy,
        initialUnlockedZoneIds: state.unlockedZoneIds,
        initialInfrastructureLevelsData: state.infrastructureLevelsData,
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
      gems: state.gems,
      energy: newEnergy, // Update energy
      maxEnergy: state.maxEnergy,
      initialUnlockedZoneIds: state.unlockedZoneIds,
      initialInfrastructureLevelsData: state.infrastructureLevelsData,
    );
    // Consider restarting the timer here if it was stopped when full
    // if (newEnergy < state.maxEnergy) _startEnergyRegeneration();
  }

  void addCoins(int amount) {
    // Create a new state object
    state = PlayerStats(
      level: state.level,
      xp: state.xp,
      coins: state.coins + amount, // Update coins
      gems: state.gems,
      energy: state.energy,
      maxEnergy: state.maxEnergy,
      initialUnlockedZoneIds: state.unlockedZoneIds,
      initialInfrastructureLevelsData: state.infrastructureLevelsData,
    );
  }

  // --- NEW: Method for upgrading infrastructure ---
  bool upgradeInfrastructure(int levelToUpgrade) {
    final currentInfrastructures = state.infrastructureLevels;
    final currentUpgradeLevel = currentInfrastructures[levelToUpgrade] ?? 0;

    if (currentUpgradeLevel >= maxInfrastructureUpgrade) {
      print("Infrastructure for level $levelToUpgrade already maxed out.");
      return false;
    }

    final cost = infrastructureUpgradeCost[currentUpgradeLevel + 1];
    if (cost == null) {
      print(
        "Error: No cost defined for upgrading level $levelToUpgrade infrastructure to level ${currentUpgradeLevel + 1}",
      );
      return false;
    }

    if (state.coins < cost) {
      print(
        "Not enough coins to upgrade level $levelToUpgrade infrastructure. Need $cost, have ${state.coins}",
      );
      return false;
    }

    // Spend coins
    spendCoins(cost); // This already updates the state

    // Update the infrastructure level
    final newUpgradeLevel = currentUpgradeLevel + 1;
    final newInfrastructureData = List<String>.from(
      state.infrastructureLevelsData,
    );
    final index = newInfrastructureData.indexWhere(
      (s) => s.startsWith('$levelToUpgrade:'),
    );
    if (index != -1) {
      newInfrastructureData[index] = '$levelToUpgrade:$newUpgradeLevel';
    } else {
      // Should not happen if initialized correctly, but handle defensively
      newInfrastructureData.add('$levelToUpgrade:$newUpgradeLevel');
    }

    // Update the state with the new infrastructure data
    // We need to read the state *after* spendCoins potentially updated it
    final currentState = state; // Capture state after spendCoins
    state = PlayerStats(
      level: currentState.level,
      xp: currentState.xp,
      coins: currentState.coins, // Coins already updated by spendCoins
      gems: currentState.gems,
      energy: currentState.energy,
      maxEnergy: currentState.maxEnergy,
      initialUnlockedZoneIds: currentState.unlockedZoneIds,
      initialInfrastructureLevelsData:
          newInfrastructureData, // The updated list
    );

    print(
      "Upgraded infrastructure for level $levelToUpgrade to level $newUpgradeLevel for $cost coins.",
    );

    // Check for player level up after infrastructure upgrade
    _checkPlayerLevelUp();

    return true;
  }

  // --- NEW: Check for player level up based on infrastructure ---
  void _checkPlayerLevelUp() {
    final currentLevel = state.level;
    if (currentLevel >= maxPlayerLevel) return; // Already max level

    final currentInfrastructures = state.infrastructureLevels;
    final currentLevelInfraUpgrade = currentInfrastructures[currentLevel] ?? 0;

    if (currentLevelInfraUpgrade >= maxInfrastructureUpgrade) {
      // Current level's infrastructure is maxed, trigger player level up
      levelUp();
    }
  }

  void spendCoins(int amount) {
    if (state.coins >= amount) {
      // Create a new state object
      state = PlayerStats(
        level: state.level,
        xp: state.xp,
        coins: state.coins - amount, // Update coins
        gems: state.gems,
        energy: state.energy,
        maxEnergy: state.maxEnergy,
        initialUnlockedZoneIds: state.unlockedZoneIds,
        initialInfrastructureLevelsData: state.infrastructureLevelsData,
      );
    } else {
      print("Not enough coins!");
      // throw Exception("Not enough coins"); // Or throw
    }
  }

  // Modified levelUp for infrastructure-based progression
  void levelUp() {
    final currentLevel = state.level;
    if (currentLevel >= maxPlayerLevel) {
      print("Already at max player level ($maxPlayerLevel).");
      return;
    }

    final nextLevel = currentLevel + 1;
    final currentInfrastructureData = List<String>.from(
      state.infrastructureLevelsData,
    );

    // Add the next level's infrastructure entry if it doesn't exist
    if (!currentInfrastructureData.any((s) => s.startsWith('$nextLevel:'))) {
      currentInfrastructureData.add('$nextLevel:0');
    }

    state = PlayerStats(
      level: nextLevel, // Update level
      xp: state.xp, // Keep XP as is
      coins: state.coins,
      gems: state.gems,
      // Increase max energy and refill current energy to the new max
      maxEnergy: state.maxEnergy + 10, // Increase max energy by 10
      energy: state.maxEnergy + 10, // Refill energy to the new max
      initialUnlockedZoneIds: state.unlockedZoneIds,
      initialInfrastructureLevelsData:
          currentInfrastructureData, // Include new level entry
    );
    print(
      "*** PLAYER LEVEL UP! Reached level ${state.level}. Max energy increased to ${state.maxEnergy}. ***",
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
      gems: loadedStats.gems,
      energy: loadedStats.energy,
      maxEnergy: loadedStats.maxEnergy,
      initialUnlockedZoneIds: loadedStats.unlockedZoneIds,
      // Load infrastructure progress
      initialInfrastructureLevelsData: loadedStats.infrastructureLevelsData,
    );
    // Ensure timer restarts
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
      gems: state.gems,
      energy: state.energy,
      maxEnergy: state.maxEnergy,
      initialUnlockedZoneIds: newUnlockedIds, // Assign the updated list
      initialInfrastructureLevelsData: state.infrastructureLevelsData,
    );

    // 4. Optional: Update Grid Tiles
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

  // --- Gem Management ---
  void addGems(int amount) {
    state = PlayerStats(
      level: state.level,
      xp: state.xp,
      coins: state.coins,
      gems: state.gems + amount, // Update gems
      energy: state.energy,
      maxEnergy: state.maxEnergy,
      initialUnlockedZoneIds: state.unlockedZoneIds,
      initialInfrastructureLevelsData: state.infrastructureLevelsData,
    );
  }

  bool spendGems(int amount) {
    if (state.gems >= amount) {
      state = PlayerStats(
        level: state.level,
        xp: state.xp,
        coins: state.coins,
        gems: state.gems - amount, // Update gems
        energy: state.energy,
        maxEnergy: state.maxEnergy,
        initialUnlockedZoneIds: state.unlockedZoneIds,
        initialInfrastructureLevelsData: state.infrastructureLevelsData,
      );
      return true;
    } else {
      print("Not enough gems!");
      return false;
    }
  }
}

final playerStatsProvider =
    StateNotifierProvider<PlayerStatsNotifier, PlayerStats>((ref) {
      // Pass the ref to the constructor
      return PlayerStatsNotifier(ref);
    });

// The Notifier is generally better for related state and logic encapsulation.

// --- Removed XP Threshold Helpers ---
