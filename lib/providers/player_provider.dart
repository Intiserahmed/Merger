// lib/providers/player_provider.dart
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_stats.dart';
import '../models/tile_unlock.dart';
import 'expansion_provider.dart';

final energyProvider = StateProvider<int>((ref) => 100);
final coinsProvider = StateProvider<int>((ref) => 50);
final gemsProvider = StateProvider<int>((ref) => 20);
final xpProvider = StateProvider<int>((ref) => 0);
final playerLevelProvider = StateProvider<int>((ref) => 1);

// --- Infrastructure upgrade system ---
const int maxInfrastructureUpgrade = 5;
const Map<int, int> infrastructureUpgradeCost = {
  1: 10,
  2: 15,
  3: 20,
  4: 25,
  5: 30,
};
const int maxPlayerLevel = 10;

// --- Order-based level thresholds (cumulative) ---
// Keys: the level being entered. Max key must equal maxPlayerLevel.
// No key beyond maxPlayerLevel — _checkOrderLevelUp guards against it.
const Map<int, int> _totalOrdersPerLevel = {
  2: 3,
  3: 8,
  4: 15,
  5: 25,
  6: 40,
  7: 60,
  8: 85,
  9: 115,
  10: 155,
};

class PlayerStatsNotifier extends StateNotifier<PlayerStats> {
  final Ref ref;
  Timer? _energyRegenTimer;
  late final AppLifecycleListener _lifecycleListener;

  bool _levelingUp = false;

  PlayerStatsNotifier(this.ref) : super(PlayerStats()) {
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

  void _assertValidState() {
    assert(state.level >= 1 && state.level <= maxPlayerLevel,
        'Level out of bounds: ${state.level}');
    assert(state.energy >= 0, 'Energy went negative: ${state.energy}');
    assert(state.energy <= state.maxEnergy,
        'Energy ${state.energy} exceeds maxEnergy ${state.maxEnergy}');
    assert(state.coins >= 0, 'Coins went negative: ${state.coins}');
    assert(state.gems >= 0, 'Gems went negative: ${state.gems}');
    assert(state.completedOrders >= 0,
        'completedOrders went negative: ${state.completedOrders}');
    assert(state.maxEnergy >= 20,
        'maxEnergy dropped below starting value: ${state.maxEnergy}');
  }

  void addXp(int amount) {
    assert(amount >= 0, 'addXp called with negative amount: $amount');
    state = state.copyWith(xp: state.xp + amount);
  }

  bool spendEnergy(int amount) {
    assert(amount > 0, 'spendEnergy called with non-positive amount: $amount');
    if (state.energy < amount) {
      print('Not enough energy!');
      return false;
    }
    state = state.copyWith(energy: state.energy - amount);
    assert(state.energy >= 0, 'Energy went negative after spend');
    return true;
  }

  void addEnergy(int amount) {
    assert(amount >= 0, 'addEnergy called with negative amount: $amount');
    state = state.copyWith(
      energy: (state.energy + amount).clamp(0, state.maxEnergy),
    );
  }

  void addCoins(int amount) {
    assert(amount >= 0, 'addCoins called with negative amount: $amount');
    state = state.copyWith(coins: state.coins + amount);
  }

  void spendCoins(int amount) {
    assert(amount > 0, 'spendCoins called with non-positive amount: $amount');
    if (state.coins < amount) {
      print('Not enough coins!');
      return;
    }
    state = state.copyWith(coins: state.coins - amount);
    assert(state.coins >= 0, 'Coins went negative after spend');
  }

  void addGems(int amount) {
    assert(amount >= 0, 'addGems called with negative amount: $amount');
    state = state.copyWith(gems: state.gems + amount);
  }

  bool spendGems(int amount) {
    assert(amount > 0, 'spendGems called with non-positive amount: $amount');
    if (state.gems < amount) {
      print('Not enough gems!');
      return false;
    }
    state = state.copyWith(gems: state.gems - amount);
    assert(state.gems >= 0, 'Gems went negative after spend');
    return true;
  }

  // ── Infrastructure upgrade system ──────────────────────────────────────────

  bool upgradeInfrastructure(int levelToUpgrade) {
    final currentInfrastructures = state.infrastructureLevels;
    final currentUpgradeLevel = currentInfrastructures[levelToUpgrade] ?? 0;

    if (currentUpgradeLevel >= maxInfrastructureUpgrade) {
      print('Infrastructure for level $levelToUpgrade already maxed out.');
      return false;
    }

    final cost = infrastructureUpgradeCost[currentUpgradeLevel + 1];
    if (cost == null) {
      print('Error: No cost defined for upgrade.');
      return false;
    }

    if (state.coins < cost) {
      print('Not enough coins to upgrade. Need $cost, have ${state.coins}');
      return false;
    }

    spendCoins(cost);

    final newUpgradeLevel = currentUpgradeLevel + 1;
    final newInfrastructureData = List<String>.from(state.infrastructureLevelsData);
    final index = newInfrastructureData.indexWhere(
      (s) => s.startsWith('$levelToUpgrade:'),
    );
    if (index != -1) {
      newInfrastructureData[index] = '$levelToUpgrade:$newUpgradeLevel';
    } else {
      newInfrastructureData.add('$levelToUpgrade:$newUpgradeLevel');
    }

    state = state.copyWith(infrastructureLevelsData: newInfrastructureData);
    print('Upgraded infrastructure for level $levelToUpgrade to $newUpgradeLevel for $cost coins.');
    // Fix 3: Infrastructure no longer triggers level-up.
    //        Single level-up path: order completion only (_checkOrderLevelUp).
    return true;
  }

  // ── Order-based levelling ──────────────────────────────────────────────────

  void orderCompleted() {
    assert(state.level >= 1, 'orderCompleted called with invalid level');
    state = state.copyWith(completedOrders: state.completedOrders + 1);
    _assertValidState();
    _checkOrderLevelUp();
  }

  void _checkOrderLevelUp() {
    if (state.completedOrders >= state.ordersForNextLevel &&
        _totalOrdersPerLevel.containsKey(state.level + 1)) {
      levelUp();
    } else if (state.completedOrders >= state.ordersForNextLevel) {
      print('Max level reached.');
    }
  }

  // ── Level up ───────────────────────────────────────────────────────────────

  void levelUp() {
    assert(!_levelingUp, 'levelUp called while already leveling up — two systems racing');
    final currentLevel = state.level;
    if (currentLevel >= maxPlayerLevel) {
      print('Already at max player level ($maxPlayerLevel).');
      return;
    }
    _levelingUp = true;

    final nextLevel = currentLevel + 1;
    final newMaxEnergy = state.maxEnergy + 10;
    final newInfrastructureData = List<String>.from(state.infrastructureLevelsData);
    if (!newInfrastructureData.any((s) => s.startsWith('$nextLevel:'))) {
      newInfrastructureData.add('$nextLevel:0');
    }
    final nextTarget = _totalOrdersPerLevel[nextLevel + 1] ?? 999999;

    state = state.copyWith(
      level: nextLevel,
      maxEnergy: newMaxEnergy,
      energy: newMaxEnergy,
      infrastructureLevelsData: newInfrastructureData,
      ordersForNextLevel: nextTarget,
    );
    _levelingUp = false;
    _assertValidState();
    assert(state.level == currentLevel + 1,
        'Level did not increment correctly: was $currentLevel, now ${state.level}');
    print('Level Up! Reached level ${state.level}. Max energy: ${state.maxEnergy}.');
  }

  // ── Debug helpers (never call from prod code) ──────────────────────────────

  void debugLevelUp() => levelUp();

  void debugReset() {
    state = PlayerStats(
      level: 1,
      xp: 0,
      energy: 20,
      maxEnergy: 20,
      coins: 0,
      gems: 0,
    );
  }

  // ── Zone unlocking ─────────────────────────────────────────────────────────

  bool unlockZone(TileUnlock zone) {
    if (state.level < zone.requiredLevel) {
      print("Cannot unlock '${zone.id}'. Requires level ${zone.requiredLevel}.");
      return false;
    }
    if (state.coins < zone.unlockCostCoins) {
      print("Cannot unlock '${zone.id}'. Need ${zone.unlockCostCoins} coins.");
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
    state = loaded.copyWith();
    _startEnergyRegeneration();
  }
}

final playerStatsProvider =
    StateNotifierProvider<PlayerStatsNotifier, PlayerStats>(
  (ref) => PlayerStatsNotifier(ref),
);
