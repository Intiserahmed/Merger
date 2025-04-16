// lib/models/tile_data.dart
import 'package:isar/isar.dart';

part 'tile_data.g.dart'; // Isar generated code

enum TileType {
  empty, // Represents an empty, placeable tile
  item, // Represents a standard mergeable item
  generator, // Represents an item generator
  locked, // Represents a tile not yet unlocked
}

@collection
class TileData {
  Id id = Isar.autoIncrement; // Isar requires an Id field

  // Add row and column for persistence
  @Index() // Index for potentially faster lookups by position
  late int row;
  @Index()
  late int col;

  @enumerated
  late TileType type;

  late String
  baseImagePath; // Emoji or path for the base tile (e.g., grass, generator building)
  String?
  itemImagePath; // Emoji or path for the item on the tile (if type is item)
  int overlayNumber; // Tier number for mergeable items

  // --- Generator Specific Fields ---
  String? generatesItemPath; // Item this generator produces (e.g., '⚔️')
  int cooldownSeconds; // Cooldown duration in seconds
  DateTime? lastUsedTimestamp; // When the generator was last activated
  int energyCost; // Energy required to activate

  // Default constructor for Isar & general use
  TileData({
    this.id = Isar.autoIncrement,
    required this.row, // Make row/col required
    required this.col,
    this.type = TileType.empty, // Default to empty
    required this.baseImagePath,
    this.itemImagePath,
    this.overlayNumber = 0,
    this.generatesItemPath,
    this.cooldownSeconds = 0, // Default to no cooldown unless specified
    this.lastUsedTimestamp,
    this.energyCost = 0, // Default to free activation
  });

  // --- Convenience Getters ---
  bool get isGenerator => type == TileType.generator;
  bool get isItem => type == TileType.item;
  bool get isEmpty => type == TileType.empty;
  bool get isLocked => type == TileType.locked;

  @ignore
  Duration get cooldownDuration => Duration(seconds: cooldownSeconds);

  @ignore
  bool get isReady {
    if (!isGenerator) return false; // Only generators have readiness state
    if (lastUsedTimestamp == null) return true; // Never used, so ready
    return DateTime.now().difference(lastUsedTimestamp!) >= cooldownDuration;
  }

  @ignore
  Duration get remainingCooldown {
    if (!isGenerator || isReady) return Duration.zero;
    final elapsed = DateTime.now().difference(lastUsedTimestamp!);
    return cooldownDuration - elapsed;
  }

  // Note: Removed copyWith, ==, and hashCode as Isar manages object identity
  // and mutability is expected. We might need custom copy logic later if needed.
}

// Helper class for drag data - can stay here or move to grid provider/widget file
class TileDropData {
  final int row;
  final int col;
  final TileData tileData; // Pass the actual data being dragged

  TileDropData({required this.row, required this.col, required this.tileData});
}
