// lib/models/tile_data.dart
import 'package:flutter/foundation.dart'; // For immutable

@immutable // Good practice for state classes
class TileData {
  final String baseImagePath; // Can be emoji or path
  final String? itemImagePath; // Nullable if no item, can be emoji or path
  final int overlayNumber; // 0 means no number
  // Add an optional ID or key if needed for animations/diffing later
  // final String id;

  const TileData({
    required this.baseImagePath,
    this.itemImagePath,
    this.overlayNumber = 0,
    // required this.id, // Example if adding ID
  });

  // Optional: Add copyWith for easier immutable updates if needed
  TileData copyWith({
    String? baseImagePath,
    // Use Object() to allow explicitly setting itemImagePath to null
    Object? itemImagePath = const Object(),
    int? overlayNumber,
  }) {
    return TileData(
      baseImagePath: baseImagePath ?? this.baseImagePath,
      itemImagePath:
          identical(itemImagePath, const Object())
              ? this.itemImagePath
              : itemImagePath as String?,
      overlayNumber: overlayNumber ?? this.overlayNumber,
      // id: this.id // Keep original id
    );
  }

  // Optional: Equality and hashCode for comparisons if using Sets or Maps
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileData &&
          runtimeType == other.runtimeType &&
          baseImagePath == other.baseImagePath &&
          itemImagePath == other.itemImagePath &&
          overlayNumber == other.overlayNumber;

  @override
  int get hashCode =>
      baseImagePath.hashCode ^ itemImagePath.hashCode ^ overlayNumber.hashCode;
}

// Helper class for drag data - can stay here or move to grid provider/widget file
class TileDropData {
  final int row;
  final int col;
  final TileData tileData; // Pass the actual data being dragged

  TileDropData({required this.row, required this.col, required this.tileData});
}
