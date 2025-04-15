// lib/providers/grid_provider.dart
import 'dart:math'; // For finding random empty tile later if needed

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart'; // For deep map equality if needed
import '../models/tile_data.dart';

const int rowCount = 11;
const int colCount = 6;

class GridNotifier extends StateNotifier<List<List<TileData>>> {
  // Initialize the grid in the constructor by calling a helper
  GridNotifier() : super(_initializeGridData());

  // --- Initialization Logic (using Emojis) ---
  static List<List<TileData>> _initializeGridData() {
    // Define Emojis (Makes it easy to change later)
    const String sand = '🟫'; // Brown Square for Sand
    const String grass = '🟩'; // Green Square for Grass
    const String shell = '🐚';
    const String castle = '🏰';
    const String coins = '💰'; // Using Money Bag for coins item
    const String photo = '🖼️';
    const String star = '⭐';
    const String sword = '⚔️'; // Keeping sword as per previous code
    const String defaultEmpty = sand; // Default base tile

    return List.generate(rowCount, (row) {
      return List.generate(colCount, (col) {
        // --- Map layout using Emojis ---
        // Overlay numbers still take precedence visually, but define base emoji
        if (row == 0 && col == 4)
          return TileData(baseImagePath: sand, overlayNumber: 11);
        if (row == 0 && col == 5)
          return TileData(baseImagePath: sand, overlayNumber: 11);
        if (row == 1 && col == 3)
          return TileData(baseImagePath: grass); // Grass tile
        if (row == 1 && col == 4)
          return TileData(baseImagePath: sand, overlayNumber: 10);
        if (row == 1 && col == 5)
          return TileData(baseImagePath: sand, overlayNumber: 10);
        if (row == 1 && col == 2)
          return TileData(baseImagePath: sand, overlayNumber: 9);

        if (row == 2 && col == 0)
          return TileData(baseImagePath: sand, overlayNumber: 8);
        if (row == 2 && col == 1)
          return TileData(baseImagePath: sand, overlayNumber: 8);
        if (row == 2 && col == 3)
          return TileData(baseImagePath: grass); // Grass tile

        if (row == 3 && col == 0)
          return TileData(baseImagePath: sand, overlayNumber: 8);
        if (row == 3 && col == 1)
          return TileData(baseImagePath: sand, overlayNumber: 7);
        if (row == 3 && col == 2)
          return TileData(
            baseImagePath: sand,
            itemImagePath: photo,
          ); // Photo item
        if (row == 3 && col == 5)
          return TileData(baseImagePath: sand, overlayNumber: 6);
        if (row == 3 && col == 4)
          return TileData(baseImagePath: sand, overlayNumber: 6);

        if (row == 4 && col == 0)
          return TileData(baseImagePath: sand, overlayNumber: 8);
        if (row == 4 && col == 1)
          return TileData(
            baseImagePath: sand,
            itemImagePath: castle,
          ); // Castle item
        if (row == 4 && col == 2)
          return TileData(
            baseImagePath: sand,
            itemImagePath: sword,
          ); // Sword item
        if (row == 4 && col == 3)
          return TileData(
            baseImagePath: sand,
            itemImagePath: star,
          ); // Star item
        if (row == 4 && col == 4)
          return TileData(
            baseImagePath: sand,
            itemImagePath: castle,
          ); // Castle item
        if (row == 4 && col == 5)
          return TileData(baseImagePath: sand, overlayNumber: 6);

        if (row == 5 && col == 0)
          return TileData(baseImagePath: sand, overlayNumber: 8);
        if (row == 5 && col == 1)
          return TileData(
            baseImagePath: sand,
            itemImagePath: shell,
          ); // Shell item
        if (row == 5 && col == 2)
          return TileData(
            baseImagePath: sand,
            itemImagePath: shell,
          ); // Shell item

        if (row == 6 && col == 0)
          return TileData(baseImagePath: sand, overlayNumber: 8);
        if (row == 6 && col == 1)
          return TileData(
            baseImagePath: sand,
            itemImagePath: castle,
          ); // Castle item
        if (row == 6 && col == 2)
          return TileData(
            baseImagePath: sand,
            itemImagePath: castle,
          ); // Castle item

        if (row == 7 && col == 0)
          return TileData(
            baseImagePath: sand,
            itemImagePath: photo,
          ); // Photo item

        if (row < 2 && col < 4)
          return TileData(baseImagePath: grass); // Top left grassy area

        // Default: Plain sand tile
        return TileData(baseImagePath: defaultEmpty);
      });
    });
  }

  // --- Methods to Modify State ---

  /// Merges the dragged item onto the target tile.
  void mergeTiles(int targetRow, int targetCol, int sourceRow, int sourceCol) {
    final currentGrid = state; // Get the current state

    // Ensure tiles are valid for merging (using current state)
    final targetTile = currentGrid[targetRow][targetCol];
    final sourceTile = currentGrid[sourceRow][sourceCol];

    // Example merge rule: Only merge identical overlay numbers > 0
    if (targetTile.overlayNumber > 0 &&
        targetTile.overlayNumber == sourceTile.overlayNumber) {
      // Create the new data for the target and source tiles
      final mergedValue = targetTile.overlayNumber + 1; // Or your merge logic
      final newTargetData = TileData(
        baseImagePath: targetTile.baseImagePath, // Keep base
        overlayNumber: mergedValue,
      );

      // Clear the source tile (replace with default empty tile)
      const String defaultBase = '🟫'; // Use emoji default
      final newSourceData = TileData(baseImagePath: defaultBase); // Empty tile

      // --- Create a NEW grid state (Immutability!) ---
      final newGrid =
          currentGrid.map((row) => List<TileData>.from(row)).toList();

      // Update the new grid
      newGrid[targetRow][targetCol] = newTargetData;
      newGrid[sourceRow][sourceCol] = newSourceData;

      // Assign the new grid to the state
      state = newGrid;
    }
    // --- Add Item Merge Logic ---
    else if (targetTile.itemImagePath != null && // Target must have an item
        targetTile.itemImagePath ==
            sourceTile.itemImagePath) // Items must match
    {
      String? mergedItemPath; // The result of the merge

      // Rule: Shell + Shell -> Star
      if (targetTile.itemImagePath == '🐚') {
        mergedItemPath = '⭐';
      }
      // Rule: Sword + Sword -> Shield
      else if (targetTile.itemImagePath == '⚔️') {
        mergedItemPath = '🛡️'; // Shield emoji
      }

      // If a merge rule was found:
      if (mergedItemPath != null) {
        // Create new data for target and source
        final newTargetData = TileData(
          baseImagePath: targetTile.baseImagePath, // Keep base
          itemImagePath: mergedItemPath, // Set the new merged item
          overlayNumber: 0, // Merged items usually don't have numbers
        );

        const String defaultBase = '🟫'; // Use emoji default for empty
        final newSourceData = TileData(
          baseImagePath: defaultBase,
        ); // Clear source

        // Create a NEW grid state
        final newGrid =
            currentGrid.map((row) => List<TileData>.from(row)).toList();

        // Update the new grid
        newGrid[targetRow][targetCol] = newTargetData;
        newGrid[sourceRow][sourceCol] = newSourceData;

        // Assign the new grid to the state
        state = newGrid;
      }
    }
    // Add more item merge rules with 'else if' blocks as needed
  }

  /// Example method: Updates a single tile (useful for spawning items etc.)
  void updateTile(int row, int col, TileData newTileData) {
    if (row < 0 || row >= rowCount || col < 0 || col >= colCount)
      return; // Bounds check

    final currentGrid = state;
    final newGrid = currentGrid.map((r) => List<TileData>.from(r)).toList();
    newGrid[row][col] = newTileData;
    state = newGrid;
  }

  /// Example: Clears an overlay by reducing its number
  void reduceOverlay(int row, int col) {
    if (row < 0 || row >= rowCount || col < 0 || col >= colCount) return;

    final currentGrid = state;
    final tile = currentGrid[row][col];

    if (tile.overlayNumber > 0) {
      final newGrid = currentGrid.map((r) => List<TileData>.from(r)).toList();
      final newNumber = tile.overlayNumber - 1;
      newGrid[row][col] = tile.copyWith(
        overlayNumber: newNumber,
        // If number reaches 0, potentially reveal an item or just empty tile
        // itemImagePath: newNumber == 0 ? getRevealedItem(...) : tile.itemImagePath,
      );
      state = newGrid;
    }
  }

  /// Finds the first empty tile and places the specified item there.
  /// Returns true if successful, false if no empty tile is found.
  bool spawnItem(String itemEmoji) {
    final currentGrid = state;
    int? emptyRow, emptyCol;

    // Find the first empty tile (no overlay number, no item)
    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        if (currentGrid[r][c].overlayNumber == 0 &&
            currentGrid[r][c].itemImagePath == null) {
          emptyRow = r;
          emptyCol = c;
          break; // Found the first one
        }
      }
      if (emptyRow != null) break; // Exit outer loop too
    }

    if (emptyRow != null && emptyCol != null) {
      // Create new tile data with the item
      final currentTile = currentGrid[emptyRow][emptyCol];
      final newTileData = TileData(
        baseImagePath: currentTile.baseImagePath, // Keep the base
        itemImagePath: itemEmoji,
      );

      // Update the grid state
      final newGrid = currentGrid.map((r) => List<TileData>.from(r)).toList();
      newGrid[emptyRow][emptyCol] = newTileData;
      state = newGrid;
      return true; // Item spawned successfully
    } else {
      print("No empty tile found to spawn item.");
      return false; // No empty tile found
    }
  }

  // Add more methods as needed: fulfillOrderRequirement, etc.
}

// --- The Provider Definition ---
final gridProvider = StateNotifierProvider<GridNotifier, List<List<TileData>>>((
  ref,
) {
  return GridNotifier();
});
