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

  // --- New fields for order-based leveling ---
  int completedOrders; // Total orders completed
  int ordersForNextLevel; // Orders needed to reach the next level

  // Constructor with default values
  PlayerStats({
    this.level = 1,
    this.xp = 0,
    this.coins = 50,
    this.gems = 20, // Starting gems value
    this.energy = 100,
    this.maxEnergy = 100, // Default max energy
    List<String>? initialUnlockedZoneIds, // Make it optional
    this.completedOrders = 0, // Start with 0 completed orders
    this.ordersForNextLevel = 3, // Example: Need 3 orders for level 2
  }) : unlockedZoneIds =
           initialUnlockedZoneIds ?? []; // Initialize to empty list if null

  PlayerStats copyWith({
    int? level,
    int? xp,
    int? coins,
    int? gems,
    int? energy,
    int? maxEnergy,
    List<String>? unlockedZoneIds,
    int? completedOrders,
    int? ordersForNextLevel,
  }) {
    return PlayerStats(
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      energy: energy ?? this.energy,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      initialUnlockedZoneIds:
          unlockedZoneIds ?? List<String>.from(this.unlockedZoneIds),
      completedOrders: completedOrders ?? this.completedOrders,
      ordersForNextLevel: ordersForNextLevel ?? this.ordersForNextLevel,
    );
  }
}
