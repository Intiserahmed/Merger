// lib/providers/grid_provider.dart
import 'dart:math'; // For finding random empty tile later if needed
import 'dart:async'; // For Future/delay if needed for cooldown visuals

import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:collection/collection.dart'; // Not currently used
import '../models/tile_data.dart';
import '../models/tile_unlock.dart'; // Import TileUnlock
import '../models/merge_trees.dart'; // Import the new merge tree logic
import '../models/generator_config.dart'; // Import the new generator config
import 'player_provider.dart'; // Import player provider for energy checks
import 'expansion_provider.dart'; // Import expansion provider

// --- Constants ---
// Keep emojis/constants potentially used outside generator/merge logic
const String coinEmoji = '💰';
const String lockedEmoji = '🔒';
const String defaultEmptyBase = '🟫';
const String mineEmoji =
    '⛏️'; // Keep if Mine is used for non-sequence generation (e.g., coins)

// Grid dimensions
const int rowCount = 9; // New: 9 rows
const int colCount = 7; // New: 7 columns

// Generators that auto-place on the grid when the player reaches a given level.
// Each entry: level → list of (row, col, generatorEmoji).
const Map<int, List<(int, int, String)>> _generatorUnlocksByLevel = {
  4: [(1, 5, '💎')],  // Gem Grotto — in forest zone (unlocks level 3)
  6: [(8, 0, '🌾')],  // Farm — bottom-left, always accessible
  8: [(0, 1, '⚗️')],  // Alchemy Lab — in castle zone (unlocks level 5)
};

class GridNotifier extends StateNotifier<List<List<TileData>>> {
  final Ref ref; // Add ref to access other providers

  // Initialize the grid in the constructor by calling the non-static helper
  GridNotifier(this.ref) : super([]) {
    state = _initializeGridData();
    _assertValidGrid();
    _watchUnlocks();
    _watchLevelForGenerators();
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
    const String coins = '💰'; // Using Money Bag for coins item
    // Starter items — must be in a merge chain
    const String plantBase = '🌱'; // plant chain tier 1
    const String pebbleBase = '🪨'; // pebble chain tier 1
    const String toolBase = '🔧'; // tool chain tier 1

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

        // --- Place Initial Generators ---
        const String campEmoji = '🏕️';
        const String mineEmoji = '⛏️'; // Re-declare here for clarity if needed
        const String workshopEmoji = '🏭';

        if (row == 4 && col == 1) {
          // Camp Location
          final config = generatorConfigs[campEmoji];
          if (config != null) {
            return TileData(
              row: row,
              col: col,
              type: TileType.generator,
              baseImagePath: campEmoji,
              generatesItemPath:
                  mergeTrees[config.sequenceId]?.first, // Get base item
              cooldownSeconds: config.cooldown,
              energyCost: config.energyCost,
            );
          }
        }
        if (row == 4 && col == 3) {
          // Mine Location
          final config = generatorConfigs[mineEmoji];
          if (config != null) {
            return TileData(
              row: row,
              col: col,
              type: TileType.generator,
              baseImagePath: mineEmoji,
              generatesItemPath:
                  mergeTrees[config.sequenceId]?.first, // Get base item
              cooldownSeconds: config.cooldown,
              energyCost: config.energyCost,
            );
          }
          // Fallback if config is missing (e.g., direct coin generation)
          // else if (mineEmoji == '⛏️') { ... handle coin mine ... }
        }
        if (row == 4 && col == 5) {
          // Workshop Location
          final config = generatorConfigs[workshopEmoji];
          if (config != null) {
            return TileData(
              row: row,
              col: col,
              type: TileType.generator,
              baseImagePath: workshopEmoji,
              generatesItemPath:
                  mergeTrees[config.sequenceId]?.first, // Get base item
              cooldownSeconds: config.cooldown,
              energyCost: config.energyCost,
            );
          }
        }

        // --- Starter Items (all in valid merge chains) ---
        // Two 🌱 near Camp (4,1) — player can merge them immediately
        if (row == 4 && col == 2)
          return TileData(
            row: row, col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: plantBase,
          );
        if (row == 5 && col == 1)
          return TileData(
            row: row, col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: plantBase,
          );
        // Two 🪨 near Mine (4,3) — player can merge them immediately
        // (4,4) left empty so Workshop at (4,5) can spawn 🔧 there)
        if (row == 5 && col == 2)
          return TileData(
            row: row, col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: pebbleBase,
          );
        if (row == 5 && col == 4)
          return TileData(
            row: row, col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: pebbleBase,
          );
        // Two 🔧 near Workshop (4,5) — (3,5)/(5,5)/(4,6) are locked by zone_mine_1
        // so (4,4) is Workshop's only free spawn tile — keep it empty above.
        // Place starters at (3,4) and (5,4) so player has tool items to work with.
        if (row == 3 && col == 4)
          return TileData(
            row: row, col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: toolBase,
          );
        if (row == 6 && col == 4)
          return TileData(
            row: row, col: col,
            type: TileType.item,
            baseImagePath: sand,
            itemImagePath: toolBase,
          );

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

  void _assertValidGrid() {
    assert(state.length == rowCount,
        'Grid row count mismatch: expected $rowCount, got ${state.length}');
    assert(
      state.every((row) => row.length == colCount),
      'Grid column count mismatch: expected $colCount cols in every row',
    );
    assert(
      state.every((row) => row.every((t) => t.row >= 0 && t.col >= 0)),
      'Tile found with unset row/col (-1)',
    );
    assert(
      state.every((row) => row.every((t) =>
          !t.isGenerator || t.generatesItemPath != null)),
      'Generator tile found with null generatesItemPath',
    );
    // Every generator must have at least one non-locked adjacent tile at init
    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        if (state[r][c].isGenerator) {
          final adjacents = [
            if (r > 0) state[r - 1][c],
            if (r < rowCount - 1) state[r + 1][c],
            if (c > 0) state[r][c - 1],
            if (c < colCount - 1) state[r][c + 1],
          ];
          assert(
            adjacents.any((t) => !t.isLocked && !t.isGenerator),
            'Generator at ($r,$c) has no unlocked adjacent tile — it can never spawn',
          );
        }
      }
    }
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
        // Re-check pending generators — some may have been skipped because
        // their tile was locked at the time the player reached the target level.
        final currentLevel = ref.read(playerStatsProvider).level;
        for (int lvl = 1; lvl <= currentLevel; lvl++) {
          _tryPlaceGeneratorsForLevel(lvl);
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

  // Place any generators scheduled for [level] whose tiles are now unlocked.
  // Called both on level-up and after a zone unlock, so generators whose zone
  // was locked at level-up time still get placed once the zone opens.
  void _tryPlaceGeneratorsForLevel(int level) {
    final toPlace = _generatorUnlocksByLevel[level];
    if (toPlace == null) return;
    final currentGrid = state;
    final newGrid = currentGrid.map((r) => List<TileData>.from(r)).toList();
    bool changed = false;
    for (final (row, col, emoji) in toPlace) {
      if (row < 0 || row >= rowCount || col < 0 || col >= colCount) continue;
      // Skip if already a generator (placed on a prior attempt)
      if (newGrid[row][col].type == TileType.generator) continue;
      // Skip if still locked
      if (newGrid[row][col].type == TileType.locked) continue;
      final config = generatorConfigs[emoji];
      if (config == null) continue;
      newGrid[row][col] = TileData(
        row: row,
        col: col,
        type: TileType.generator,
        baseImagePath: emoji,
        generatesItemPath: mergeTrees[config.sequenceId]?.first,
        cooldownSeconds: config.cooldown,
        energyCost: config.energyCost,
      );
      changed = true;
      print('Generator $emoji placed at ($row, $col).');
    }
    if (changed) state = newGrid;
  }

  // Auto-place generators when the player reaches the required level.
  void _watchLevelForGenerators() {
    ref.listen<int>(
      playerStatsProvider.select((s) => s.level),
      (previous, newLevel) => _tryPlaceGeneratorsForLevel(newLevel),
    );
  }

  // --- Methods to Modify State ---

  /// Merges the dragged item onto the target tile.
  void mergeTiles(int targetRow, int targetCol, int sourceRow, int sourceCol) {
    assert(targetRow >= 0 && targetRow < rowCount, 'targetRow out of bounds: $targetRow');
    assert(targetCol >= 0 && targetCol < colCount, 'targetCol out of bounds: $targetCol');
    assert(sourceRow >= 0 && sourceRow < rowCount, 'sourceRow out of bounds: $sourceRow');
    assert(sourceCol >= 0 && sourceCol < colCount, 'sourceCol out of bounds: $sourceCol');
    assert(
      !(targetRow == sourceRow && targetCol == sourceCol),
      'mergeTiles called with same source and target ($targetRow,$targetCol)',
    );

    final currentGrid = state;
    final targetTile = currentGrid[targetRow][targetCol];
    final sourceTile = currentGrid[sourceRow][sourceCol];

    assert(targetTile.itemImagePath != null,
        'mergeTiles: target ($targetRow,$targetCol) has no item');
    assert(sourceTile.itemImagePath != null,
        'mergeTiles: source ($sourceRow,$sourceCol) has no item');
    assert(targetTile.itemImagePath == sourceTile.itemImagePath,
        'mergeTiles: items do not match — ${targetTile.itemImagePath} vs ${sourceTile.itemImagePath}');

    if (targetTile.isLocked || sourceTile.isLocked) {
      print("Cannot merge with locked tiles.");
      return;
    }

    // --- Refactored Merge Logic using merge_trees.dart ---
    if (targetTile.itemImagePath != null &&
        targetTile.itemImagePath == sourceTile.itemImagePath) {
      // Check if these items can merge into a next-level item
      final nextItemPath = getNextItemInSequence(targetTile.itemImagePath!);

      if (nextItemPath != null) {
        // Merge is possible according to mergeTrees
        final newTargetData = TileData(
          row: targetRow,
          col: targetCol,
          type: TileType.item,
          baseImagePath: targetTile.baseImagePath,
          itemImagePath: nextItemPath,
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
        print("Merged $nextItemPath at ($targetRow, $targetCol).");
        return; // Merge handled, exit function
      }
    }

    // If no merge condition was met (either not same item, or max level, or not a specific merge)
    print(
      "Merge condition not met for ${sourceTile.itemImagePath ?? 'empty'} onto ${targetTile.itemImagePath ?? 'empty'}",
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

    // --- Refactored Generator Placement using Config ---
    final config = generatorConfigs[generatorEmoji];
    if (config == null) {
      // If config is missing, print error and do nothing.
      // Removed the fallback logic that incorrectly made the Mine generate coins.
      print(
        "Generator config missing for: $generatorEmoji. Cannot place generator.",
      );
      return;
    }

    // Find the base item for the sequence
    final sequence = mergeTrees[config.sequenceId];
    if (sequence == null || sequence.isEmpty) {
      print(
        "Generator config found for $generatorEmoji, but its sequence '${config.sequenceId}' is missing or empty in mergeTrees.",
      );
      return;
    }
    final baseItemEmoji = sequence.first; // The item the generator produces

    // Create the generator TileData using the config
    final generatorData = TileData(
      row: row,
      col: col,
      type: TileType.generator,
      baseImagePath: generatorEmoji, // The generator's own appearance
      generatesItemPath: baseItemEmoji, // The base item it generates
      cooldownSeconds: config.cooldown,
      energyCost: config.energyCost,
    );

    updateTile(row, col, generatorData);
    print(
      "Placed $generatorEmoji generator at ($row, $col), generates $baseItemEmoji.",
    );
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
      final remaining = generatorTile.remainingCooldown;
      print("Generator at ($row, $col) is on cooldown. ${remaining.inSeconds}s remaining.");
      return;
    }
    if (generatorTile.generatesItemPath == null) {
      print("Generator at ($row, $col) has nothing defined to generate.");
      return;
    }

    // 2. Find Adjacent Empty Tile BEFORE spending energy (atomicity fix:
    //    never spend energy if there's nowhere to place the item).
    int? targetRow, targetCol;
    final List<Point> neighbors = [
      Point(row - 1, col), Point(row + 1, col),
      Point(row, col - 1), Point(row, col + 1),
    ];

    for (final neighbor in neighbors) {
      final r = neighbor.row;
      final c = neighbor.col;
      if (r >= 0 &&
          r < rowCount &&
          c >= 0 &&
          c < colCount &&
          currentGrid[r][c].type == TileType.empty) {
        targetRow = r;
        targetCol = c;
        break;
      }
    }

    if (targetRow == null || targetCol == null) {
      print(
        "No empty, unlocked adjacent tile found for generator at ($row, $col).",
      );
      return; // No energy spent — nothing happened.
    }

    // 3. Spend energy only after confirming a spawn tile exists.
    final playerNotifier = ref.read(playerStatsProvider.notifier);
    final energyCost = generatorTile.energyCost.clamp(1, 999);
    if (!playerNotifier.spendEnergy(energyCost)) {
      print(
        "Not enough energy (cost $energyCost) to activate generator at ($row, $col).",
      );
      return;
    }

    // 4. Spawn Item
    final spawnedItemData = TileData(
      row: targetRow,
      col: targetCol,
      type: TileType.item,
      baseImagePath: currentGrid[targetRow][targetCol].baseImagePath,
      itemImagePath: generatorTile.generatesItemPath!,
      overlayNumber: 0,
    );

    final updatedGeneratorData = TileData(
      row: row,
      col: col,
      type: generatorTile.type,
      baseImagePath: generatorTile.baseImagePath,
      itemImagePath: generatorTile.itemImagePath,
      overlayNumber: generatorTile.overlayNumber,
      generatesItemPath: generatorTile.generatesItemPath,
      cooldownSeconds: generatorTile.cooldownSeconds,
      lastUsedTimestamp: DateTime.now(),
      energyCost: generatorTile.energyCost,
    );

    final newGrid = currentGrid.map((r) => List<TileData>.from(r)).toList();
    newGrid[targetRow][targetCol] = spawnedItemData;
    newGrid[row][col] = updatedGeneratorData;
    state = newGrid;

    print(
      "Generator at ($row, $col) activated, spawned ${generatorTile.generatesItemPath} at ($targetRow, $targetCol).",
    );
  }

  /// Moves an item from one tile to another.
  void moveItem(int sourceRow, int sourceCol, int targetRow, int targetCol) {
    if (sourceRow < 0 ||
        sourceRow >= rowCount ||
        sourceCol < 0 ||
        sourceCol >= colCount ||
        targetRow < 0 ||
        targetRow >= rowCount ||
        targetCol < 0 ||
        targetCol >= colCount) {
      return; // Bounds check
    }

    final currentGrid = state;
    final sourceTile = currentGrid[sourceRow][sourceCol];
    final targetTile = currentGrid[targetRow][targetCol];

    // Prevent moving to or from locked tiles
    if (targetTile.isLocked || sourceTile.isLocked) {
      print("Cannot move to or from locked tiles.");
      return;
    }

    // Ensure there's an item at the source and the target is empty
    if (sourceTile.itemImagePath == null || targetTile.itemImagePath != null) {
      print("Invalid move: source must have an item and target must be empty.");
      return;
    }

    // Create new tile data for source and target
    final newTargetData = TileData(
      row: targetRow,
      col: targetCol,
      type: TileType.item,
      baseImagePath: targetTile.baseImagePath,
      itemImagePath: sourceTile.itemImagePath,
    );
    final newSourceData = TileData(
      row: sourceRow,
      col: sourceCol,
      type: TileType.empty,
      baseImagePath: sourceTile.baseImagePath,
    );

    // Update the grid state
    final newGrid = currentGrid.map((row) => List<TileData>.from(row)).toList();
    newGrid[targetRow][targetCol] = newTargetData;
    newGrid[sourceRow][sourceCol] = newSourceData;
    state = newGrid;

    print(
      "Moved item from ($sourceRow, $sourceCol) to ($targetRow, $targetCol).",
    );
  }

  // ── Debug helpers (never call from prod code) ──────────────────────────────

  void debugFillGrid(List<String> items) {
    final newGrid = state.map((r) => List<TileData>.from(r)).toList();
    int itemIndex = 0;
    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        final tile = newGrid[r][c];
        if (!tile.isGenerator && !tile.isLocked) {
          newGrid[r][c] = TileData(
            row: r, col: c,
            type: TileType.item,
            baseImagePath: tile.baseImagePath,
            itemImagePath: items[itemIndex % items.length],
          );
          itemIndex++;
        }
      }
    }
    state = newGrid;
  }

  void debugClearItems() {
    final newGrid = state.map((r) => List<TileData>.from(r)).toList();
    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        final tile = newGrid[r][c];
        if (tile.isItem) {
          newGrid[r][c] = TileData(
            row: r, col: c,
            type: TileType.empty,
            baseImagePath: tile.baseImagePath,
          );
        }
      }
    }
    state = newGrid;
  }

  void debugZeroCooldowns() {
    final newGrid = state.map((r) => List<TileData>.from(r)).toList();
    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        final tile = newGrid[r][c];
        if (tile.isGenerator) {
          newGrid[r][c] = TileData(
            row: r, col: c,
            type: tile.type,
            baseImagePath: tile.baseImagePath,
            generatesItemPath: tile.generatesItemPath,
            cooldownSeconds: tile.cooldownSeconds,
            lastUsedTimestamp: DateTime.fromMillisecondsSinceEpoch(0),
            energyCost: tile.energyCost,
          );
        }
      }
    }
    state = newGrid;
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  /// Load a previously saved grid. Runs the same invariant checks as init
  /// so corrupt saves are caught immediately in debug builds.
  void loadGrid(List<List<TileData>> loadedGrid) {
    state = loadedGrid;
    _assertValidGrid();
  }

  void debugReset() => state = _initializeGridData();

  // Add more methods as needed: fulfillOrderRequirement, etc.
}

// --- The Provider Definition ---
final gridProvider = StateNotifierProvider<GridNotifier, List<List<TileData>>>((
  ref,
) {
  return GridNotifier(ref); // Pass the ref to the constructor
});
