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

// --- Define total orders needed to reach each level ---
const Map<int, int> _totalOrdersPerLevel = {
  2: 3, // Need 3 total orders to reach level 2
  3: 8, // Need 8 total orders to reach level 3 (5 more)
  4: 15, // Need 15 total orders to reach level 4 (7 more)
  5: 25, // Need 25 total orders to reach level 5 (10 more)
  6: 40, // Need 40 total orders to reach level 6 (15 more) - Max level 5 for now
  // Add more levels as needed
};

// A single Notifier for the whole PlayerStats object (better if stats often change together)
class PlayerStatsNotifier extends StateNotifier<PlayerStats> {
  final Ref ref;
  Timer? _energyRegenTimer;

  // Initialize with a non-const PlayerStats instance and start the timer
  PlayerStatsNotifier(this.ref)
    : super(
        PlayerStats(
          // Initialize ordersForNextLevel for level 1 -> 2
          ordersForNextLevel: _totalOrdersPerLevel[2] ?? 3,
        ),
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
        state = PlayerStats(
          level: state.level,
          xp: state.xp,
          coins: state.coins,
          gems: state.gems, // Include gems
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
      xp: state.xp + amount, // Update XP - Keep XP tracking separate for now
      coins: state.coins,
      gems: state.gems,
      energy: state.energy,
      maxEnergy: state.maxEnergy,
      initialUnlockedZoneIds: state.unlockedZoneIds,
      completedOrders: state.completedOrders, // Keep existing order count
      ordersForNextLevel: state.ordersForNextLevel, // Keep existing target
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
        gems: state.gems, // Include gems
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
      gems: state.gems,
      energy: newEnergy, // Update energy
      maxEnergy: state.maxEnergy,
      initialUnlockedZoneIds: state.unlockedZoneIds,
      completedOrders: state.completedOrders, // Keep existing order count
      ordersForNextLevel: state.ordersForNextLevel, // Keep existing target
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
      completedOrders: state.completedOrders, // Keep existing order count
      ordersForNextLevel: state.ordersForNextLevel, // Keep existing target
    );
  }

  // --- NEW: Method called when an order is successfully completed ---
  void orderCompleted() {
    final newCompletedOrders = state.completedOrders + 1;
    state = PlayerStats(
      level: state.level,
      xp: state.xp, // Keep XP separate
      coins: state.coins, // Rewards are added separately by OrderNotifier
      gems: state.gems,
      energy: state.energy,
      maxEnergy: state.maxEnergy,
      initialUnlockedZoneIds: state.unlockedZoneIds,
      completedOrders: newCompletedOrders, // Increment completed orders
      ordersForNextLevel: state.ordersForNextLevel, // Keep target for now
    );
    _checkLevelUp(); // Check if this completion triggers a level up
  }

  /// Checks if the completed orders meet the threshold for the next level.
  void _checkLevelUp() {
    // Check if player has completed enough orders for the *next* level
    if (state.completedOrders >= state.ordersForNextLevel) {
      // Check if there's a defined next level target
      if (_totalOrdersPerLevel.containsKey(state.level + 1)) {
        levelUp();
        // Optional: Recursively call _checkLevelUp() if multiple levels might be gained
        // _checkLevelUp();
      } else {
        print("Max level reached (based on defined orders per level).");
      }
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
        completedOrders: state.completedOrders, // Keep existing order count
        ordersForNextLevel: state.ordersForNextLevel, // Keep existing target
      );
    } else {
      print("Not enough coins!");
      // throw Exception("Not enough coins"); // Or throw
    }
  }

  // Modified levelUp for order-based progression
  void levelUp() {
    final nextLevel = state.level + 1;
    // Get the total orders needed for the level *after* the next one, or a high number if max level
    final ordersForLevelAfterNext =
        _totalOrdersPerLevel[nextLevel + 1] ?? 999999;

    state = PlayerStats(
      level: nextLevel, // Update level
      xp: state.xp, // Keep XP as is
      coins: state.coins,
      gems: state.gems,
      // Increase max energy and refill current energy to the new max
      maxEnergy: state.maxEnergy + 10, // Increase max energy by 10
      energy: state.maxEnergy + 10, // Refill energy to the new max
      initialUnlockedZoneIds: state.unlockedZoneIds,
      completedOrders: state.completedOrders, // Keep total completed orders
      // Set the target for the *next* level up
      ordersForNextLevel: ordersForLevelAfterNext,
    );
    print(
      "Level Up! Reached level ${state.level}. Max energy increased to ${state.maxEnergy}. Next level at ${state.ordersForNextLevel} total orders.",
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
      // Load order progress
      completedOrders: loadedStats.completedOrders,
      ordersForNextLevel: loadedStats.ordersForNextLevel,
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
      completedOrders: state.completedOrders, // Keep existing order count
      ordersForNextLevel: state.ordersForNextLevel, // Keep existing target
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
      completedOrders: state.completedOrders, // Keep existing order count
      ordersForNextLevel: state.ordersForNextLevel, // Keep existing target
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
        completedOrders: state.completedOrders, // Keep existing order count
        ordersForNextLevel: state.ordersForNextLevel, // Keep existing target
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
