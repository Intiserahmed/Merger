// lib/providers/player_provider.dart
import 'dart:async';
import 'package:flutter/widgets.dart'; // AppLifecycleListener
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_stats.dart';
import '../models/tile_unlock.dart';
import 'expansion_provider.dart';

// Individual providers kept for backwards-compatibility with any watchers.
final energyProvider = StateProvider<int>((ref) => 100);
final coinsProvider = StateProvider<int>((ref) => 50);
final gemsProvider = StateProvider<int>((ref) => 20);
final xpProvider = StateProvider<int>((ref) => 0);
final playerLevelProvider = StateProvider<int>((ref) => 1);

// --- Orders needed (cumulative) to reach each level ---
const Map<int, int> _totalOrdersPerLevel = {
  2: 3,
  3: 8,
  4: 15,
  5: 25,
  6: 40,
};

class PlayerStatsNotifier extends StateNotifier<PlayerStats> {
  final Ref ref;
  Timer? _energyRegenTimer;
  // Pauses the regen timer while the app is backgrounded so the countdown
  // only advances while the player is actually in the game.
  late final AppLifecycleListener _lifecycleListener;

  PlayerStatsNotifier(this.ref)
      : super(PlayerStats(ordersForNextLevel: _totalOrdersPerLevel[2] ?? 3)) {
    _startEnergyRegeneration();
    _lifecycleListener = AppLifecycleListener(
      onResume: _startEnergyRegeneration,
      onHide: _stopEnergyRegeneration,
    );
  }

  // ── Energy regeneration ────────────────────────────────────────────────────

  void _startEnergyRegeneration() {
    _energyRegenTimer?.cancel();
    _energyRegenTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (state.energy < state.maxEnergy) {
        state = state.copyWith(energy: state.energy + 1);
      }
    });
  }

  void _stopEnergyRegeneration() {
    _energyRegenTimer?.cancel();
    _energyRegenTimer = null;
  }

  @override
  void dispose() {
    _energyRegenTimer?.cancel();
    _lifecycleListener.dispose();
    super.dispose();
  }

  // ── Stat mutations ─────────────────────────────────────────────────────────

  void addXp(int amount) {
    state = state.copyWith(xp: state.xp + amount);
  }

  /// Returns true if energy was spent, false if insufficient.
  bool spendEnergy(int amount) {
    if (state.energy < amount) {
      print('Not enough energy!');
      return false;
    }
    state = state.copyWith(energy: state.energy - amount);
    return true;
  }

  void addEnergy(int amount) {
    state = state.copyWith(
      energy: (state.energy + amount).clamp(0, state.maxEnergy),
    );
  }

  void addCoins(int amount) {
    state = state.copyWith(coins: state.coins + amount);
  }

  void spendCoins(int amount) {
    if (state.coins < amount) {
      print('Not enough coins!');
      return;
    }
    state = state.copyWith(coins: state.coins - amount);
  }

  void addGems(int amount) {
    state = state.copyWith(gems: state.gems + amount);
  }

  bool spendGems(int amount) {
    if (state.gems < amount) {
      print('Not enough gems!');
      return false;
    }
    state = state.copyWith(gems: state.gems - amount);
    return true;
  }

  // ── Order-based levelling ──────────────────────────────────────────────────

  void orderCompleted() {
    state = state.copyWith(completedOrders: state.completedOrders + 1);
    _checkLevelUp();
  }

  void _checkLevelUp() {
    if (state.completedOrders >= state.ordersForNextLevel &&
        _totalOrdersPerLevel.containsKey(state.level + 1)) {
      levelUp();
    } else if (state.completedOrders >= state.ordersForNextLevel) {
      print('Max level reached.');
    }
  }

  void levelUp() {
    final nextLevel = state.level + 1;
    final nextTarget = _totalOrdersPerLevel[nextLevel + 1] ?? 999999;
    final newMaxEnergy = state.maxEnergy + 10;
    state = state.copyWith(
      level: nextLevel,
      maxEnergy: newMaxEnergy,
      energy: newMaxEnergy, // refill on level-up
      ordersForNextLevel: nextTarget,
    );
    print(
      'Level Up! Reached level ${state.level}. '
      'Max energy: ${state.maxEnergy}. '
      'Next level at ${state.ordersForNextLevel} total orders.',
    );
  }

  // ── Zone unlocking ─────────────────────────────────────────────────────────

  /// Returns true if the zone was successfully unlocked.
  bool unlockZone(TileUnlock zone) {
    if (state.level < zone.requiredLevel) {
      print(
        "Cannot unlock '${zone.id}'. "
        'Requires level ${zone.requiredLevel}, player is level ${state.level}.',
      );
      return false;
    }
    if (state.coins < zone.unlockCostCoins) {
      print(
        "Cannot unlock '${zone.id}'. "
        'Requires ${zone.unlockCostCoins} coins, player has ${state.coins}.',
      );
      return false;
    }
    spendCoins(zone.unlockCostCoins);
    final newIds = List<String>.from(state.unlockedZoneIds)..add(zone.id);
    state = state.copyWith(unlockedZoneIds: newIds);
    print("Zone '${zone.id}' unlocked for ${zone.unlockCostCoins} coins!");
    return true;
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  void loadStats(PlayerStats loaded) {
    state = loaded.copyWith(); // copy so we don't mutate the Isar object
    _startEnergyRegeneration();
  }
}

final playerStatsProvider =
    StateNotifierProvider<PlayerStatsNotifier, PlayerStats>(
  (ref) => PlayerStatsNotifier(ref),
);
