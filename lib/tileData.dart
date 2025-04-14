// Simple class to hold tile data
class TileData {
  final String baseImagePath;
  final String? itemImagePath; // Nullable if no item
  final int overlayNumber;

  const TileData({
    required this.baseImagePath,
    this.itemImagePath,
    this.overlayNumber = 0, // Default to 0 (no overlay)
  });
}
