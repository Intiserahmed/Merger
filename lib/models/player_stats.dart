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

  // --- New field for infrastructure-based leveling ---
  // Stores data like ["1:0", "2:0"] (level:upgradeLevel)
  List<String> infrastructureLevelsData;

  // Constructor with default values
  PlayerStats({
    this.level = 1,
    this.xp = 0,
    this.coins = 50,
    this.gems = 20, // Starting gems value
    this.energy = 100,
    this.maxEnergy = 100, // Default max energy
    List<String>? initialUnlockedZoneIds, // Make it optional
    List<String>? initialInfrastructureLevelsData, // Optional for loading
  }) : unlockedZoneIds = initialUnlockedZoneIds ?? [],
       // Initialize with level 1 infrastructure at upgrade 0 if not provided
       infrastructureLevelsData = initialInfrastructureLevelsData ?? ['1:0'];

  // Helper getter to parse the stored data into a usable map
  @ignore // Tell Isar to ignore this getter
  Map<int, int> get infrastructureLevels {
    final map = <int, int>{};
    for (final entry in infrastructureLevelsData) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        final levelKey = int.tryParse(parts[0]);
        final upgradeLevel = int.tryParse(parts[1]);
        if (levelKey != null && upgradeLevel != null) {
          map[levelKey] = upgradeLevel;
        }
      }
    }
    return map;
  }

  // Note: Removed copyWith, ==, and hashCode
}
