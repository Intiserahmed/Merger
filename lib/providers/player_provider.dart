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
  PlayerStatsNotifier() : super(const PlayerStats()); // Initial default stats

  void addXp(int amount) {
    final newXp = state.xp + amount;
    // Add level up logic here later (Milestone 3)
    state = state.copyWith(xp: newXp);
  }

  /// Attempts to spend energy. Returns true if successful, false otherwise.
  bool spendEnergy(int amount) {
    if (state.energy >= amount) {
      state = state.copyWith(energy: state.energy - amount);
      return true; // Energy spent successfully
    } else {
      // Handle insufficient energy (e.g., show message)
      print("Not enough energy!");
      return false; // Failed to spend energy
    }
  }

  void addCoins(int amount) {
    state = state.copyWith(coins: state.coins + amount);
  }

  void spendCoins(int amount) {
    if (state.coins >= amount) {
      state = state.copyWith(coins: state.coins - amount);
    } else {
      print("Not enough coins!");
      // throw Exception("Not enough coins"); // Or throw
    }
  }

  void levelUp() {
    // Example level up logic
    state = state.copyWith(
      level: state.level + 1,
      xp: 0,
    ); // Reset XP on level up?
    // Maybe refill energy?
    // state = state.copyWith(energy: maxEnergy);
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
