// lib/models/player_stats.dart
import 'package:flutter/foundation.dart';

@immutable
class PlayerStats {
  final int level;
  final int xp;
  final int coins;
  final int energy;
  // Add maxEnergy etc. as needed

  const PlayerStats({
    this.level = 1,
    this.xp = 0,
    this.coins = 50, // Starting values
    this.energy = 100,
  });

  PlayerStats copyWith({int? level, int? xp, int? coins, int? energy}) {
    return PlayerStats(
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      energy: energy ?? this.energy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerStats &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          xp == other.xp &&
          coins == other.coins &&
          energy == other.energy;

  @override
  int get hashCode =>
      level.hashCode ^ xp.hashCode ^ coins.hashCode ^ energy.hashCode;
}
