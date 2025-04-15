// lib/providers/player_provider.dart
import 'dart:async'; // Import async for Timer
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_stats.dart'; // Import the model

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
  Timer? _energyRegenTimer; // Timer for energy regeneration

  // Initialize with a non-const PlayerStats instance and start the timer
  PlayerStatsNotifier() : super(PlayerStats()) {
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
    );
    // Add level up logic here later (Milestone 3)
    // TODO: Implement level up check based on XP thresholds
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
      energy: state.maxEnergy, // Refill energy on level up
      maxEnergy:
          state.maxEnergy, // Keep max energy (or increase it based on level?)
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
    );
    // Ensure timer restarts if loading changes energy state significantly
    _startEnergyRegeneration();
  }
}

final playerStatsProvider =
    StateNotifierProvider<PlayerStatsNotifier, PlayerStats>((ref) {
      return PlayerStatsNotifier();
    });

// Choose EITHER individual providers OR the combined Notifier based on preference.
// The Notifier is generally better for related state and logic encapsulation.
