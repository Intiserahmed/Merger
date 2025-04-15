// lib/models/tile_data.dart
import 'package:isar/isar.dart';

part 'tile_data.g.dart'; // Isar generated code

@collection
class TileData {
  Id id = Isar.autoIncrement; // Isar requires an Id field

  late String baseImagePath; // Can be emoji or path
  String? itemImagePath; // Nullable if no item, can be emoji or path
  int overlayNumber; // 0 means no number

  // Default constructor for Isar
  TileData({
    required this.baseImagePath,
    this.itemImagePath,
    this.overlayNumber = 0,
  });

  // Note: Removed copyWith, ==, and hashCode as Isar manages object identity
  // and mutability is expected.
}

// Helper class for drag data - can stay here or move to grid provider/widget file
class TileDropData {
  final int row;
  final int col;
  final TileData tileData; // Pass the actual data being dragged

  TileDropData({required this.row, required this.col, required this.tileData});
}
