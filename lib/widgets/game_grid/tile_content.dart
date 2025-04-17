// TODO Implement this library.
// lib/widgets/game_grid/tile_content.dart
import 'package:flutter/material.dart';

// Helper to build the visual content (emoji/image) of a tile
Widget buildTileContent(
  String? contentPath, {
  double size = 30, // Default size
  BoxFit fit = BoxFit.contain,
}) {
  if (contentPath == null) {
    return const SizedBox.shrink(); // Return empty if no path
  }

  // Basic check: if it's a single character, assume emoji
  if (contentPath.length == 1 ||
      (contentPath.length == 2 && contentPath.runes.length == 1)) {
    // Handle multi-byte emojis
    return Center(
      child: Text(
        contentPath,
        style: TextStyle(fontSize: size * 0.9), // Adjust emoji size slightly
      ),
    );
  } else {
    // Otherwise, assume it's an asset path (modify if needed)
    // Example: return Image.asset(contentPath, width: size, height: size, fit: fit);
    // For now, fallback to Text if not an emoji (adjust as per your assets)
    return Center(
      child: Text(
        contentPath, // Display path as text if not an emoji
        style: TextStyle(fontSize: size * 0.5, color: Colors.black54),
        textAlign: TextAlign.center,
      ),
    );
  }
}
