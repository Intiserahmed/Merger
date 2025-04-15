// lib/models/tile_unlock.dart (or zone.dart)
import 'package:flutter/foundation.dart';

@immutable
class TileUnlock {
  // Or ZoneData
  final String id; // e.g., 'zone_beach_1'
  final int requiredLevel;
  final int unlockCostCoins; // Or 0 if reward-based
  final List<Point> coveredTiles; // Optional: define area precisely
  // final bool isUnlocked; // State might live elsewhere (e.g., PlayerData)

  const TileUnlock({
    required this.id,
    required this.requiredLevel,
    this.unlockCostCoins = 0,
    this.coveredTiles = const [],
  });

  // ==, hashCode...
  // No copyWith needed if unlock status isn't stored here
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileUnlock &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          requiredLevel == other.requiredLevel &&
          unlockCostCoins == other.unlockCostCoins &&
          listEquals(coveredTiles, other.coveredTiles); // Need listEquals

  @override
  int get hashCode =>
      id.hashCode ^
      requiredLevel.hashCode ^
      unlockCostCoins.hashCode ^
      Object.hashAll(coveredTiles); // Need Object.hashAll for list
}

// Simple Point class if needed, or use a package
@immutable
class Point {
  final int row;
  final int col;
  const Point(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}
