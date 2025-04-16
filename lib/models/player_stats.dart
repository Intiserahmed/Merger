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
  int gems; // Add gems field
  int energy;
  int maxEnergy; // Maximum energy capacity
  List<String> unlockedZoneIds; // Store IDs of unlocked zones

  // Constructor with default values
  PlayerStats({
    this.level = 1,
    this.xp = 0,
    this.coins = 50,
    this.gems = 20, // Starting gems value
    this.energy = 100,
    this.maxEnergy = 100, // Default max energy
    List<String>? initialUnlockedZoneIds, // Make it optional
  }) : unlockedZoneIds =
           initialUnlockedZoneIds ?? []; // Initialize to empty list if null

  // Note: Removed copyWith, ==, and hashCode
}
