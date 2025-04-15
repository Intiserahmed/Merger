// lib/models/player_stats.dart
import 'package:isar/isar.dart';

part 'player_stats.g.dart'; // Isar generated code

@collection
class PlayerStats {
  Id id =
      Isar.autoIncrement; // Use autoIncrement for a single player stats object

  int level;
  int xp;
  int coins;
  int energy;
  int maxEnergy; // Maximum energy capacity

  // Constructor with default values
  PlayerStats({
    this.level = 1,
    this.xp = 0,
    this.coins = 50, // Starting values
    this.energy = 100,
    this.maxEnergy = 100, // Default max energy
  });

  // Note: Removed copyWith, ==, and hashCode
}
