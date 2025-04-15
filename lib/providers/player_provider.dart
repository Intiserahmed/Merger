// lib/providers/player_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_stats.dart'; // Import the model

// Individual providers for simple stats (easy to watch individually)
final energyProvider = StateProvider<int>((ref) => 100); // Initial energy
final coinsProvider = StateProvider<int>((ref) => 50); // Initial coins
final xpProvider = StateProvider<int>((ref) => 0); // Initial XP
final playerLevelProvider = StateProvider<int>((ref) => 1); // Initial Level

// --- OR ---

// Define energy cost for spawning an item
const int spawnEnergyCost = 10;

// A single Notifier for the whole PlayerStats object (better if stats often change together)
class PlayerStatsNotifier extends StateNotifier<PlayerStats> {
  // Initialize with a non-const PlayerStats instance
  PlayerStatsNotifier() : super(PlayerStats()); // Initial default stats

  void addXp(int amount) {
    state.xp += amount;
    // Add level up logic here later (Milestone 3)
    // Notify listeners after direct mutation
    state = PlayerStats(
      level: state.level,
      xp: state.xp,
      coins: state.coins,
      energy: state.energy,
    );
  }

  /// Attempts to spend energy. Returns true if successful, false otherwise.
  bool spendEnergy(int amount) {
    if (state.energy >= amount) {
      state.energy -= amount;
      // Notify listeners
      state = PlayerStats(
        level: state.level,
        xp: state.xp,
        coins: state.coins,
        energy: state.energy,
      );
      return true; // Energy spent successfully
    } else {
      // Handle insufficient energy (e.g., show message)
      print("Not enough energy!");
      return false; // Failed to spend energy
    }
  }

  void addCoins(int amount) {
    state.coins += amount;
    // Notify listeners
    state = PlayerStats(
      level: state.level,
      xp: state.xp,
      coins: state.coins,
      energy: state.energy,
    );
  }

  void spendCoins(int amount) {
    if (state.coins >= amount) {
      state.coins -= amount;
      // Notify listeners
      state = PlayerStats(
        level: state.level,
        xp: state.xp,
        coins: state.coins,
        energy: state.energy,
      );
    } else {
      print("Not enough coins!");
      // throw Exception("Not enough coins"); // Or throw
    }
  }

  void levelUp() {
    // Example level up logic
    state.level += 1;
    state.xp = 0; // Reset XP on level up?
    // Maybe refill energy?
    // state.energy = maxEnergy; // Assuming maxEnergy exists
    // Notify listeners
    state = PlayerStats(
      level: state.level,
      xp: state.xp,
      coins: state.coins,
      energy: state.energy,
    );
  }

  // Load/Save methods for Milestone 3
  void loadStats(PlayerStats loadedStats) {
    state = loadedStats;
  }
}

final playerStatsProvider =
    StateNotifierProvider<PlayerStatsNotifier, PlayerStats>((ref) {
      return PlayerStatsNotifier();
    });

// Choose EITHER individual providers OR the combined Notifier based on preference.
// The Notifier is generally better for related state and logic encapsulation.
