// lib/providers/grid_provider.dart
import 'dart:math'; // For finding random empty tile later if needed
import 'dart:async'; // For Future/delay if needed for cooldown visuals

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart'; // For deep map equality if needed
import '../models/tile_data.dart';
import 'player_provider.dart'; // Import player provider for energy checks

// --- Generator Definitions ---
const String barracksEmoji = '🏕️';
const String mineEmoji = '⛏️';
const String swordEmoji = '⚔️';
const String coinEmoji = '💰';

const int barracksCooldown = 15; // seconds
const int mineCooldown = 30; // seconds
const int barracksEnergyCost = 5;
const int mineEnergyCost = 2;

const int rowCount = 11;
const int colCount = 6;

class GridNotifier extends StateNotifier<List<List<TileData>>> {
  final Ref ref; // Add ref to access other providers

  // Initialize the grid in the constructor by calling a helper
  GridNotifier(this.ref) : super(_initializeGridData());

  // --- Initialization Logic (using Emojis & TileType) ---
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
        // --- Map layout using Emojis & TileType ---
        // Most tiles are items or empty. Generators will be placed later.
        if (row == 0 && col == 4)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            overlayNumber: 11,
          );
        if (row == 0 && col == 5)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            overlayNumber: 11,
          );
        if (row == 1 && col == 3)
          return TileData(
            type: TileType.empty,
            baseImagePath: grass,
          ); // Grass tile
        if (row == 1 && col == 4)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            overlayNumber: 10,
          );
        if (row == 1 && col == 5)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            overlayNumber: 10,
          );
        if (row == 1 && col == 2)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            overlayNumber: 9,
          );

        if (row == 2 && col == 0)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            overlayNumber: 8,
          );
        if (row == 2 && col == 1)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            overlayNumber: 8,
          );
        if (row == 2 && col == 3)
          return TileData(
            type: TileType.empty,
            baseImagePath: grass,
          ); // Grass tile

        if (row == 3 && col == 0)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            overlayNumber: 8,
          );
        if (row == 3 && col == 1)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            overlayNumber: 7,
          );
        if (row == 3 && col == 2)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: photo,
          ); // Photo item
        if (row == 3 && col == 5)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            overlayNumber: 6,
          );
        if (row == 3 && col == 4)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            overlayNumber: 6,
          );

        if (row == 4 && col == 0)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            overlayNumber: 8,
          );
        if (row == 4 && col == 1)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: castle,
          ); // Castle item
        if (row == 4 && col == 2)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: sword,
          ); // Sword item
        if (row == 4 && col == 3)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: star,
          ); // Star item
        if (row == 4 && col == 4)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: castle,
          ); // Castle item
        if (row == 4 && col == 5)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            overlayNumber: 6,
          );

        if (row == 5 && col == 0)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            overlayNumber: 8,
          );
        if (row == 5 && col == 1)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: shell,
          ); // Shell item
        if (row == 5 && col == 2)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: shell,
          ); // Shell item

        if (row == 6 && col == 0)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            overlayNumber: 8,
          );
        if (row == 6 && col == 1)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: castle,
          ); // Castle item
        if (row == 6 && col == 2)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: castle,
          ); // Castle item

        if (row == 7 && col == 0)
          return TileData(
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: photo,
          ); // Photo item

        if (row < 2 && col < 4)
          return TileData(
            type: TileType.empty,
            baseImagePath: grass,
          ); // Top left grassy area

        // Default: Plain empty tile
        return TileData(type: TileType.empty, baseImagePath: defaultEmpty);
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

  /// Updates a single tile's data. Use this for placing items, generators, etc.
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
      // Create a new TileData instance with updated values
      newGrid[row][col] = TileData(
        baseImagePath: tile.baseImagePath, // Keep existing base image
        itemImagePath: tile.itemImagePath, // Keep existing item image
        overlayNumber: newNumber,
        // If number reaches 0, potentially reveal an item or just empty tile
        // itemImagePath: newNumber == 0 ? getRevealedItem(...) : null, // Example: clear item if number is 0
      );
      state = newGrid;
    }
  }

  /// Finds the first empty tile (type == TileType.empty) and places the specified item there.
  /// Returns true if successful, false if no empty tile is found.
  bool spawnItemOnFirstEmpty(String itemEmoji) {
    final currentGrid = state;
    int? emptyRow, emptyCol;

    // Find the first empty tile
    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        if (currentGrid[r][c].type == TileType.empty) {
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
        type: TileType.item, // It's now an item tile
        baseImagePath: currentTile.baseImagePath, // Keep the base
        itemImagePath: itemEmoji,
        overlayNumber: 0, // Default for spawned base items
      );

      // Update the grid state using the existing method
      updateTile(emptyRow, emptyCol, newTileData);
      return true; // Item spawned successfully
    } else {
      print("No empty tile found to spawn item.");
      return false; // No empty tile found
    }
  }

  /// Places a specific generator type at the given coordinates.
  /// Overwrites whatever is currently there. (For testing/debug)
  void placeGenerator(int row, int col, String generatorEmoji) {
    if (row < 0 || row >= rowCount || col < 0 || col >= colCount) return;

    TileData generatorData;
    if (generatorEmoji == barracksEmoji) {
      generatorData = TileData(
        type: TileType.generator,
        baseImagePath: generatorEmoji, // Use emoji as base image
        generatesItemPath: swordEmoji,
        cooldownSeconds: barracksCooldown,
        energyCost: barracksEnergyCost,
      );
    } else if (generatorEmoji == mineEmoji) {
      generatorData = TileData(
        type: TileType.generator,
        baseImagePath: generatorEmoji,
        generatesItemPath: coinEmoji,
        cooldownSeconds: mineCooldown,
        energyCost: mineEnergyCost,
      );
    } else {
      print("Unknown generator type: $generatorEmoji");
      return; // Don't place anything if unknown
    }

    updateTile(row, col, generatorData);
  }

  // --- Generator Activation Logic ---
  /// Attempts to activate a generator at the given coordinates.
  void activateGenerator(int row, int col) {
    if (row < 0 || row >= rowCount || col < 0 || col >= colCount) return;

    final currentGrid = state;
    final TileData generatorTile = currentGrid[row][col];

    // 1. Check if it's actually a ready generator
    if (!generatorTile.isGenerator) {
      print("Tile at ($row, $col) is not a generator.");
      return;
    }
    if (!generatorTile.isReady) {
      print("Generator at ($row, $col) is on cooldown.");
      // Optional: Show feedback to user (e.g., SnackBar)
      return;
    }
    if (generatorTile.generatesItemPath == null) {
      print("Generator at ($row, $col) has nothing defined to generate.");
      return;
    }

    // 2. Check Energy Cost
    final playerNotifier = ref.read(playerStatsProvider.notifier);
    if (!playerNotifier.spendEnergy(generatorTile.energyCost)) {
      print("Not enough energy to activate generator at ($row, $col).");
      // Optional: Show feedback to user
      return;
    }

    // 3. Find Adjacent Empty Tile
    int? targetRow, targetCol;
    final List<Point<int>> neighbors = [
      Point(row - 1, col), Point(row + 1, col),
      Point(row, col - 1), Point(row, col + 1),
      // Optional: Add diagonals if desired
      // Point(row - 1, col - 1), Point(row - 1, col + 1),
      // Point(row + 1, col - 1), Point(row + 1, col + 1),
    ];

    for (final neighbor in neighbors) {
      final r = neighbor.x;
      final c = neighbor.y;
      // Check bounds and if the tile is empty
      if (r >= 0 &&
          r < rowCount &&
          c >= 0 &&
          c < colCount &&
          currentGrid[r][c].type == TileType.empty) {
        targetRow = r;
        targetCol = c;
        break; // Found the first empty neighbor
      }
    }

    // 4. Spawn Item if Empty Neighbor Found
    if (targetRow != null && targetCol != null) {
      // Create the spawned item tile data
      final spawnedItemData = TileData(
        type: TileType.item,
        baseImagePath:
            currentGrid[targetRow][targetCol].baseImagePath, // Keep base
        itemImagePath: generatorTile.generatesItemPath!,
        overlayNumber: 0, // Base items usually start at 0 or 1
      );

      // Create updated generator tile data (with new timestamp)
      final updatedGeneratorData = TileData(
        type: generatorTile.type,
        baseImagePath: generatorTile.baseImagePath,
        itemImagePath: generatorTile.itemImagePath,
        overlayNumber: generatorTile.overlayNumber,
        generatesItemPath: generatorTile.generatesItemPath,
        cooldownSeconds: generatorTile.cooldownSeconds,
        lastUsedTimestamp: DateTime.now(), // Set activation time
        energyCost: generatorTile.energyCost,
      );

      // Update the grid state
      final newGrid = currentGrid.map((r) => List<TileData>.from(r)).toList();
      newGrid[targetRow][targetCol] = spawnedItemData; // Place the item
      newGrid[row][col] =
          updatedGeneratorData; // Update the generator timestamp
      state = newGrid;

      print(
        "Generator at ($row, $col) activated, spawned ${generatorTile.generatesItemPath} at ($targetRow, $targetCol).",
      );
    } else {
      print("No empty adjacent tile found for generator at ($row, $col).");
      // Refund energy since item couldn't be placed
      playerNotifier.addEnergy(
        generatorTile.energyCost,
      ); // Call the correct addEnergy method
      print("Energy refunded.");
      // Optional: Show feedback to user
    }
  }

  // Add more methods as needed: fulfillOrderRequirement, etc.
}

// --- The Provider Definition ---
final gridProvider = StateNotifierProvider<GridNotifier, List<List<TileData>>>((
  ref,
) {
  return GridNotifier(ref); // Pass the ref to the constructor
});
