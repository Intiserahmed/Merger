// lib/providers/grid_provider.dart
import 'dart:math'; // For finding random empty tile later if needed
import 'dart:async'; // For Future/delay if needed for cooldown visuals

import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:collection/collection.dart'; // Not currently used
import '../models/tile_data.dart';
import '../models/tile_unlock.dart'; // Import TileUnlock
import 'player_provider.dart'; // Import player provider for energy checks
import 'expansion_provider.dart'; // Import expansion provider

// --- Generator Definitions ---
const String barracksEmoji = '🏕️';
const String mineEmoji = '⛏️';
const String swordEmoji = '⚔️'; // Keep for potential other uses/orders
const String coinEmoji = '💰';
const String lockedEmoji = '🔒'; // Emoji for locked tiles
const String defaultEmptyBase = '🟫'; // Default base for empty/unlocked tiles

// --- Plant Merge Sequence ---
const List<String> plantSequence = [
  '🌱',
  '🌿',
  '🌳',
  '🌲',
  '🌴',
  '🌵',
]; // Seedling -> Herb -> Tree -> Evergreen -> Palm -> Cactus

// --- Tool Merge Sequence ---
const List<String> toolSequence = [
  '🔧', // Wrench
  '🔨', // Hammer
  '🔩', // Nut and Bolt
  '⚙️', // Gear
  '🔗', // Link
];

// --- Generator Definitions ---
const String workshopEmoji = '🏭'; // New Workshop Generator

const int barracksCooldown = 15; // seconds
const int mineCooldown = 30; // seconds
const int workshopCooldown = 20; // seconds
const int barracksEnergyCost = 5;
const int mineEnergyCost = 2;
const int workshopEnergyCost = 3;

// Constants moved from expansion_provider to be central here
const int rowCount = 11; // Keep existing grid size for now
const int colCount = 6;

class GridNotifier extends StateNotifier<List<List<TileData>>> {
  final Ref ref; // Add ref to access other providers

  // Initialize the grid in the constructor by calling the non-static helper
  GridNotifier(this.ref) : super([]) {
    // Initialize state after construction to access ref
    state = _initializeGridData();
    _watchUnlocks(); // Start listening for zone unlocks
  }

  // --- Initialization Logic (Now Non-Static) ---
  List<List<TileData>> _initializeGridData() {
    // Read unlock status needed for initialization
    final allUnlocks = ref.read(allUnlocksProvider);
    final unlockedIds = ref.read(unlockedStatusProvider);

    // Determine which tiles are initially locked
    final lockedTiles = <Point>{};
    for (final unlock in allUnlocks) {
      if (!unlockedIds.contains(unlock.id)) {
        for (final point in unlock.coveredTiles) {
          // Add Point directly, assuming Point has == and hashCode
          lockedTiles.add(point);
        }
      }
    }

    // Define Emojis (Makes it easy to change later)
    const String sand = '🟫'; // Brown Square for Sand
    const String grass = '🟩'; // Green Square for Grass
    const String shell = '🐚';
    const String castle = '🏰';
    const String coins = '💰'; // Using Money Bag for coins item
    const String photo = '🖼️';
    const String star = '⭐';
    const String sword = '⚔️'; // Keeping sword as per previous code

    return List.generate(rowCount, (row) {
      return List.generate(colCount, (col) {
        final currentPoint = Point(row, col); // Create Point for lookup

        // --- Check if tile is locked first ---
        if (lockedTiles.contains(currentPoint)) {
          return TileData(
            row: row, // Add row
            col: col, // Add col
            type: TileType.locked,
            baseImagePath: lockedEmoji, // Use lock emoji for base
          );
        }

        // --- Existing Map layout ---
        // (Keep the existing layout logic for unlocked tiles, but remove numbered items)
        // Add row/col to all TileData instantiations

        // Example: Keep some specific items if needed
        if (row == 3 && col == 2)
          return TileData(
            row: row,
            col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: photo,
          ); // Photo item
        if (row == 4 && col == 1)
          return TileData(
            row: row,
            col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: castle,
          ); // Castle item
        if (row == 4 && col == 2)
          return TileData(
            row: row,
            col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: sword,
          ); // Sword item
        if (row == 4 && col == 3)
          return TileData(
            row: row,
            col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: star,
          ); // Star item
        if (row == 4 && col == 4)
          return TileData(
            row: row,
            col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: castle,
          ); // Castle item
        if (row == 5 && col == 1)
          return TileData(
            row: row,
            col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: shell,
          ); // Shell item
        if (row == 5 && col == 2)
          return TileData(
            row: row,
            col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: shell,
          ); // Shell item
        if (row == 6 && col == 1)
          return TileData(
            row: row,
            col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: castle,
          ); // Castle item
        if (row == 6 && col == 2)
          return TileData(
            row: row,
            col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: castle,
          ); // Castle item
        if (row == 7 && col == 0)
          return TileData(
            row: row,
            col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: photo,
          ); // Photo item

        // Define grassy areas
        if ((row == 1 && col == 3) ||
            (row == 2 && col == 3) ||
            (row < 2 && col < 4))
          return TileData(
            row: row,
            col: col,
            type: TileType.empty,
            baseImagePath: grass,
          ); // Grass tile

        // Default: Plain empty tile (sand/brown)
        return TileData(
          row: row,
          col: col,
          type: TileType.empty,
          baseImagePath: defaultEmptyBase,
        );
      });
    });
  }

  // --- Watch for Unlocks ---
  void _watchUnlocks() {
    ref.listen<Set<String>>(unlockedStatusProvider, (previous, next) {
      final previouslyUnlocked = previous ?? <String>{};
      final newlyUnlockedIds = next.difference(previouslyUnlocked);

      if (newlyUnlockedIds.isNotEmpty) {
        print("Detected new unlocks: $newlyUnlockedIds");
        final allUnlocks = ref.read(allUnlocksProvider);
        for (final zoneId in newlyUnlockedIds) {
          final zone = allUnlocks.firstWhere(
            (u) => u.id == zoneId,
            orElse:
                () => TileUnlock(
                  id: 'not_found',
                  requiredLevel: 0,
                ), // Should not happen
          );
          if (zone.id != 'not_found') {
            _unlockTilesForZone(zone);
          }
        }
      }
    });
  }

  // --- Unlock Tiles Method ---
  void _unlockTilesForZone(TileUnlock zone) {
    print("Unlocking tiles for zone: ${zone.id}");
    final currentGrid = state;
    final newGrid = currentGrid.map((r) => List<TileData>.from(r)).toList();
    bool changed = false;

    for (final point in zone.coveredTiles) {
      if (point.row >= 0 &&
          point.row < rowCount &&
          point.col >= 0 &&
          point.col < colCount) {
        // Check if the tile is currently locked before changing it
        if (newGrid[point.row][point.col].type == TileType.locked) {
          // Replace locked tile with a default empty tile
          newGrid[point.row][point.col] = TileData(
            row: point.row, // Add row
            col: point.col, // Add col
            type: TileType.empty,
            baseImagePath: defaultEmptyBase, // Use default sand/dirt base
            // TODO: Could potentially use a different base image based on zone type
          );
          changed = true;
        }
      }
    }

    if (changed) {
      state = newGrid;
      print("Grid updated for unlocked zone: ${zone.id}");
    }
  }

  // --- Methods to Modify State ---

  /// Merges the dragged item onto the target tile.
  void mergeTiles(int targetRow, int targetCol, int sourceRow, int sourceCol) {
    final currentGrid = state; // Get the current state

    // Ensure tiles are valid for merging (using current state)
    final targetTile = currentGrid[targetRow][targetCol];
    final sourceTile = currentGrid[sourceRow][sourceCol];

    // Prevent merging onto or dragging from locked tiles
    if (targetTile.isLocked || sourceTile.isLocked) {
      print("Cannot merge with locked tiles.");
      return;
    }

    // --- NEW Plant Merge Logic ---
    if (targetTile.itemImagePath != null &&
        targetTile.itemImagePath == sourceTile.itemImagePath &&
        plantSequence.contains(targetTile.itemImagePath)) {
      final currentIndex = plantSequence.indexOf(targetTile.itemImagePath!);
      if (currentIndex < plantSequence.length - 1) {
        // Check if there's a next level
        final nextItemPath = plantSequence[currentIndex + 1];
        final newTargetData = TileData(
          row: targetRow,
          col: targetCol,
          type: TileType.item,
          baseImagePath: targetTile.baseImagePath,
          itemImagePath: nextItemPath,
          overlayNumber: 0, // No numbers for emoji merges
        );
        final newSourceData = TileData(
          row: sourceRow,
          col: sourceCol,
          type: TileType.empty,
          baseImagePath: defaultEmptyBase,
        );

        final newGrid =
            currentGrid.map((row) => List<TileData>.from(row)).toList();
        newGrid[targetRow][targetCol] = newTargetData;
        newGrid[sourceRow][sourceCol] = newSourceData;
        state = newGrid;

        // --- Add XP for Plant Merge ---
        final xpGained =
            (currentIndex + 1) *
            5; // Example: 5 XP for 🌱->🌿, 10 for 🌿->🌳 etc.
        ref.read(playerStatsProvider.notifier).addXp(xpGained);
        print("Gained $xpGained XP for merging into $nextItemPath");
        return; // Merge handled, exit function
      } else {
        print("Already at max plant level: ${targetTile.itemImagePath}");
        // Optional: Add feedback if trying to merge max level items
        return;
      }
    }
    // --- NEW Tool Merge Logic ---
    else if (targetTile.itemImagePath != null &&
        targetTile.itemImagePath == sourceTile.itemImagePath &&
        toolSequence.contains(targetTile.itemImagePath)) {
      final currentIndex = toolSequence.indexOf(targetTile.itemImagePath!);
      if (currentIndex < toolSequence.length - 1) {
        // Check if there's a next level
        final nextItemPath = toolSequence[currentIndex + 1];
        final newTargetData = TileData(
          row: targetRow,
          col: targetCol,
          type: TileType.item,
          baseImagePath: targetTile.baseImagePath,
          itemImagePath: nextItemPath,
          overlayNumber: 0,
        );
        final newSourceData = TileData(
          row: sourceRow,
          col: sourceCol,
          type: TileType.empty,
          baseImagePath: defaultEmptyBase,
        );

        final newGrid =
            currentGrid.map((row) => List<TileData>.from(row)).toList();
        newGrid[targetRow][targetCol] = newTargetData;
        newGrid[sourceRow][sourceCol] = newSourceData;
        state = newGrid;

        // --- Add XP for Tool Merge ---
        final xpGained =
            (currentIndex + 1) * 6; // Example: 6 XP, 12 XP, 18 XP etc.
        ref.read(playerStatsProvider.notifier).addXp(xpGained);
        print("Gained $xpGained XP for merging into $nextItemPath");
        return; // Merge handled, exit function
      } else {
        print("Already at max tool level: ${targetTile.itemImagePath}");
        return;
      }
    }
    // --- Existing Item Merge Logic (Shell, Sword) ---
    else if (targetTile.itemImagePath != null && // Target must have an item
        targetTile.itemImagePath ==
            sourceTile.itemImagePath) // Items must match
    {
      String? mergedItemPath; // The result of the merge
      int xpGained = 0;

      // Rule: Shell + Shell -> Star
      if (targetTile.itemImagePath == '🐚') {
        mergedItemPath = '⭐';
        xpGained = 15; // XP for creating a Star
      }
      // Rule: Sword + Sword -> Shield
      else if (targetTile.itemImagePath == '⚔️') {
        mergedItemPath = '🛡️'; // Shield emoji
        xpGained = 25; // XP for creating a Shield
      }
      // Add more specific item merge rules here if needed

      // If a merge rule was found:
      if (mergedItemPath != null) {
        final newTargetData = TileData(
          row: targetRow,
          col: targetCol,
          type: TileType.item,
          baseImagePath: targetTile.baseImagePath,
          itemImagePath: mergedItemPath,
          overlayNumber: 0, // Merged items don't have numbers
        );
        final newSourceData = TileData(
          row: sourceRow,
          col: sourceCol,
          type: TileType.empty,
          baseImagePath: defaultEmptyBase,
        );

        final newGrid =
            currentGrid.map((row) => List<TileData>.from(row)).toList();
        newGrid[targetRow][targetCol] = newTargetData;
        newGrid[sourceRow][sourceCol] = newSourceData;
        state = newGrid;

        if (xpGained > 0) {
          ref.read(playerStatsProvider.notifier).addXp(xpGained);
          print("Gained $xpGained XP for merging into $mergedItemPath");
        }
        return; // Merge handled
      }
    }
    // If no merge condition was met
    print(
      "Merge condition not met for ${sourceTile.itemImagePath ?? sourceTile.overlayNumber} onto ${targetTile.itemImagePath ?? targetTile.overlayNumber}",
    );
  }

  /// Updates a single tile's data. Use this for placing items, generators, etc.
  void updateTile(int row, int col, TileData newTileData) {
    if (row < 0 || row >= rowCount || col < 0 || col >= colCount) {
      return; // Bounds check
    }
    // Prevent updating locked tiles directly unless it's an unlock operation
    if (state[row][col].isLocked && newTileData.type != TileType.empty) {
      print("Cannot update a locked tile directly.");
      return;
    }

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

    // Prevent interacting with locked tiles
    if (tile.isLocked) return;

    if (tile.overlayNumber > 0) {
      final newGrid = currentGrid.map((r) => List<TileData>.from(r)).toList();
      final newNumber = tile.overlayNumber - 1;
      // Create a new TileData instance with updated values
      newGrid[row][col] = TileData(
        row: row,
        col: col, // Add row/col
        baseImagePath: tile.baseImagePath, // Keep existing base image
        itemImagePath: tile.itemImagePath, // Keep existing item image
        overlayNumber: newNumber,
        // Copy other relevant fields if necessary (like generator info if applicable)
        generatesItemPath: tile.generatesItemPath,
        cooldownSeconds: tile.cooldownSeconds,
        lastUsedTimestamp: tile.lastUsedTimestamp,
        energyCost: tile.energyCost,
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

    // Find the first empty tile (that isn't locked)
    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        // Check for empty AND not locked
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
        row: emptyRow,
        col: emptyCol, // Add row/col
        type: TileType.item, // It's now an item tile
        baseImagePath: currentTile.baseImagePath, // Keep the base
        itemImagePath: itemEmoji,
        overlayNumber: 0, // Default for spawned base items
      );

      // Update the grid state using the existing method
      updateTile(emptyRow, emptyCol, newTileData);
      return true; // Item spawned successfully
    } else {
      print("No empty, unlocked tile found to spawn item.");
      return false; // No suitable empty tile found
    }
  }

  /// Places a specific generator type at the given coordinates.
  /// Overwrites whatever is currently there. (For testing/debug)
  void placeGenerator(int row, int col, String generatorEmoji) {
    if (row < 0 || row >= rowCount || col < 0 || col >= colCount) return;

    // Prevent placing on locked tiles
    if (state[row][col].isLocked) {
      print("Cannot place generator on a locked tile.");
      return;
    }

    TileData generatorData;
    if (generatorEmoji == barracksEmoji) {
      generatorData = TileData(
        row: row,
        col: col, // Add row/col
        type: TileType.generator,
        baseImagePath: generatorEmoji, // Use emoji as base image
        generatesItemPath: plantSequence[0], // Generate base plant 🌱
        cooldownSeconds: barracksCooldown,
        energyCost: barracksEnergyCost,
      );
    } else if (generatorEmoji == mineEmoji) {
      generatorData = TileData(
        row: row,
        col: col, // Add row/col
        type: TileType.generator,
        baseImagePath: generatorEmoji,
        generatesItemPath: coinEmoji,
        cooldownSeconds: mineCooldown,
        energyCost: mineEnergyCost,
      );
    } else if (generatorEmoji == workshopEmoji) {
      generatorData = TileData(
        row: row,
        col: col,
        type: TileType.generator,
        baseImagePath: generatorEmoji,
        generatesItemPath: toolSequence[0], // Generate base tool 🔧
        cooldownSeconds: workshopCooldown,
        energyCost: workshopEnergyCost,
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

    // Prevent activating locked tiles (shouldn't happen if placement is blocked)
    if (generatorTile.isLocked) return;

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

    // 3. Find Adjacent Empty Tile (that isn't locked)
    int? targetRow, targetCol;
    // Use the Point class from tile_unlock.dart (no type arguments)
    final List<Point> neighbors = [
      Point(row - 1, col), Point(row + 1, col),
      Point(row, col - 1), Point(row, col + 1),
      // Optional: Add diagonals if desired
      // Point(row - 1, col - 1), Point(row - 1, col + 1),
      // Point(row + 1, col - 1), Point(row + 1, col + 1),
    ];

    for (final neighbor in neighbors) {
      // Use .row and .col instead of .x and .y
      final r = neighbor.row;
      final c = neighbor.col;
      // Check bounds and if the tile is empty AND not locked
      if (r >= 0 &&
          r < rowCount &&
          c >= 0 &&
          c < colCount &&
          currentGrid[r][c].type == TileType.empty) {
        targetRow = r;
        targetCol = c;
        break; // Found the first suitable neighbor
      }
    }

    // 4. Spawn Item if Empty Neighbor Found
    if (targetRow != null && targetCol != null) {
      // Create the spawned item tile data
      final spawnedItemData = TileData(
        row: targetRow,
        col: targetCol, // Add row/col
        type: TileType.item,
        baseImagePath:
            currentGrid[targetRow][targetCol].baseImagePath, // Keep base
        itemImagePath: generatorTile.generatesItemPath!,
        overlayNumber: 0, // Base items usually start at 0 or 1
      );

      // Create updated generator tile data (with new timestamp)
      final updatedGeneratorData = TileData(
        row: row,
        col: col, // Add row/col
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
      print(
        "No empty, unlocked adjacent tile found for generator at ($row, $col).",
      );
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
