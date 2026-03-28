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
const int maxPlayerLevel = 5;

// --- Order-based level thresholds (cumulative) ---
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
  late final AppLifecycleListener _lifecycleListener;

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

  void addXp(int amount) {
    state = state.copyWith(xp: state.xp + amount);
  }

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
    _checkPlayerLevelUp();
    return true;
  }

  void _checkPlayerLevelUp() {
    final currentLevel = state.level;
    if (currentLevel >= maxPlayerLevel) return;
    final currentLevelInfraUpgrade = state.infrastructureLevels[currentLevel] ?? 0;
    if (currentLevelInfraUpgrade >= maxInfrastructureUpgrade) {
      levelUp();
    }
  }

  // ── Order-based levelling ──────────────────────────────────────────────────

  void orderCompleted() {
    state = state.copyWith(completedOrders: state.completedOrders + 1);
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
    final currentLevel = state.level;
    if (currentLevel >= maxPlayerLevel) {
      print('Already at max player level ($maxPlayerLevel).');
      return;
    }

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
    print('Level Up! Reached level ${state.level}. Max energy: ${state.maxEnergy}.');
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
