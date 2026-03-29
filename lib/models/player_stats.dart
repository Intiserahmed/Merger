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
  int gems;
  int energy;
  int maxEnergy;
  int completedOrders;
  int ordersForNextLevel;
  List<String> unlockedZoneIds;

  // --- New field for infrastructure-based leveling ---
  // Stores data like ["1:0", "2:0"] (level:upgradeLevel)
  List<String> infrastructureLevelsData;

  // Constructor with default values
  PlayerStats({
    this.level = 1,
    this.xp = 0,
    this.coins = 50,
    this.gems = 20,
    this.energy = 100,
    this.maxEnergy = 100,
    this.completedOrders = 0,
    this.ordersForNextLevel = 3,
    List<String>? initialUnlockedZoneIds,
    List<String>? initialInfrastructureLevelsData,
  }) : unlockedZoneIds = initialUnlockedZoneIds ?? ['zone_starter'],
       infrastructureLevelsData =
           initialInfrastructureLevelsData ?? ['1:0'];

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
        } else {
          print('Warning: malformed infrastructureLevelsData entry: "$entry" — skipped.');
        }
      } else {
        print('Warning: malformed infrastructureLevelsData entry: "$entry" — skipped.');
      }
    }
    return map;
  }

  PlayerStats copyWith({
    int? level,
    int? xp,
    int? coins,
    int? gems,
    int? energy,
    int? maxEnergy,
    int? completedOrders,
    int? ordersForNextLevel,
    List<String>? unlockedZoneIds,
    List<String>? infrastructureLevelsData,
  }) {
    return PlayerStats(
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      energy: energy ?? this.energy,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      completedOrders: completedOrders ?? this.completedOrders,
      ordersForNextLevel: ordersForNextLevel ?? this.ordersForNextLevel,
      initialUnlockedZoneIds:
          unlockedZoneIds ?? List<String>.from(this.unlockedZoneIds),
      initialInfrastructureLevelsData:
          infrastructureLevelsData ??
          List<String>.from(this.infrastructureLevelsData),
    );
  }
}
