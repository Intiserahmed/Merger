// lib/widgets/game_grid_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merger/providers/order_provider.dart'; // Keep for debug save?
import 'package:merger/models/tile_unlock.dart';
import 'package:merger/providers/expansion_provider.dart';
import 'package:merger/main.dart'; // Import main to access global isar instance
import 'package:merger/persistence/game_service.dart';
import 'package:merger/widgets/info_popup.dart'; // Keep for _buildTile
import 'package:merger/widgets/game_grid/tile_content.dart'; // Import new helper
import 'package:merger/widgets/game_grid/game_grid_hud.dart'; // Import HUD
import 'package:merger/widgets/game_grid/game_grid_orders.dart'; // Import Orders
import 'package:merger/widgets/game_grid/game_grid_bottom_bar.dart'; // Import Bottom Bar
import 'package:merger/widgets/game_grid_components.dart'
    hide buildTileContent; // Import helper

import 'dart:math' as math;
import '../models/tile_data.dart';
import '../providers/grid_provider.dart' as grid;
import '../providers/player_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/merge_trees.dart'; // Keep for _buildTile merge logic
// GeneratorConfig needed only by Bottom Bar now
// import '../models/generator_config.dart';

// Define colors (keep here or move to a theme file)
final Color lightBrown = Colors.brown[300]!;
final Color darkBrown = Colors.brown[600]!;
final Color grassGreen = Colors.green[400]!;

// Convert to ConsumerStatefulWidget
class GameGridScreen extends ConsumerStatefulWidget {
  const GameGridScreen({super.key});

  @override
  ConsumerState<GameGridScreen> createState() => _GameGridScreenState();
}

// Create the State class
class _GameGridScreenState extends ConsumerState<GameGridScreen> {
  TileData? _selectedTile; // State variable for the selected tile

  // --- Build Tile Method (Remains in State due to complexity and state access) ---
  Widget _buildTile(int index) {
    final int row = index ~/ grid.colCount;
    final int col = index % grid.colCount;
    final gridData = ref.watch(grid.gridProvider);

    // Bounds check (important!)
    if (row >= gridData.length || col >= gridData[0].length) {
      // Handle potential out-of-bounds during grid resize/init
      return Container(
        color: Colors.red.withOpacity(0.2),
        margin: const EdgeInsets.all(1.0),
      ); // Placeholder for error/loading
    }
    final TileData tileData = gridData[row][col];

    Color backgroundColor;
    if (tileData.baseImagePath == '🟩') {
      backgroundColor = grassGreen;
    } else if (tileData.isLocked) {
      backgroundColor = Colors.grey.shade500;
    } else {
      backgroundColor = (row + col) % 2 == 0 ? lightBrown : darkBrown;
    }

    return DragTarget<TileDropData>(
      onWillAccept: (dragData) {
        if (dragData == null || (dragData.row == row && dragData.col == col)) {
          return false;
        }
        final targetTile = tileData;
        final sourceTile = dragData.tileData;

        if (targetTile.isLocked) return false;

        // Allow dropping item onto empty tile
        if (targetTile.itemImagePath == null && sourceTile.isItem) {
          return true; // Accept dropping item onto empty tile
        }

        // Existing merge logic
        if (targetTile.itemImagePath != null &&
            sourceTile.itemImagePath != null && // Ensure source has an item
            targetTile.itemImagePath == sourceTile.itemImagePath) {
          final nextItem = getNextItemInSequence(targetTile.itemImagePath!);
          // Allow merging final items of specific types if needed (adjust condition)
          if (nextItem != null ||
              targetTile.itemImagePath == '🐚' ||
              targetTile.itemImagePath == '⚔️') {
            return true;
          }
        }

        return false; // Default deny
      },
      onAccept: (dragData) {
        final targetTile = gridData[row][col]; // Re-fetch target tile data
        final sourceTile = dragData.tileData;

        if (targetTile.itemImagePath == null && sourceTile.isItem) {
          // Move item to empty tile
          ref
              .read(grid.gridProvider.notifier)
              .moveItem(dragData.row, dragData.col, row, col);
        } else if (targetTile.itemImagePath != null &&
            targetTile.itemImagePath == sourceTile.itemImagePath) {
          // Perform merge
          ref
              .read(grid.gridProvider.notifier)
              .mergeTiles(row, col, dragData.row, dragData.col);
        }
      },
      builder: (context, candidateData, rejectedData) {
        Widget content = Container(
          key: ValueKey(
            'tile_${row}_${col}_${tileData.type}_${tileData.itemImagePath ?? 'base'}_${tileData.isReady}', // More specific key
          ),
          margin: const EdgeInsets.all(1.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: Colors.black.withOpacity(0.2),
              width: 0.5,
            ),
            boxShadow:
                tileData.isItem
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 3.0,
                        offset: const Offset(1, 1),
                      ),
                    ]
                    : null,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              // Base Layer (Generator/Locked) - Use helper
              if (tileData.isGenerator || tileData.isLocked)
                buildTileContent(
                  tileData.baseImagePath,
                  fit: BoxFit.contain,
                  size: 30,
                ),
              // Item Layer (Conditional) - Use helper
              if (tileData.itemImagePath != null)
                buildTileContent(
                  tileData.itemImagePath!,
                  fit: BoxFit.contain,
                  size: 28,
                ),
              // Cooldown Overlay
              if (tileData.isGenerator && !tileData.isReady)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Center(
                      child: Text(
                        '${tileData.remainingCooldown.inSeconds}s',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );

        content = SizedBox(width: 50, height: 50, child: content);

        // Draggable Logic
        bool isDraggable = tileData.isItem;
        if (isDraggable) {
          return Draggable<TileDropData>(
            data: TileDropData(row: row, col: col, tileData: tileData),
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 45,
                height: 45,
                // Use helper for feedback
                child: buildTileContent(tileData.itemImagePath!, size: 40),
              ),
            ),
            childWhenDragging: SizedBox(
              width: 50,
              height: 50,
              child: Container(
                key: ValueKey('dragging_${row}_$col'),
                margin: const EdgeInsets.all(1.0),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.2),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                // Only show base if it exists (generator)
                child:
                    tileData.isGenerator
                        ? buildTileContent(
                          tileData.baseImagePath,
                          fit: BoxFit.contain,
                          size: 30,
                        )
                        : null, // Empty when dragging item from non-generator tile
              ),
            ),
            child: content,
          );
        } else {
          // GestureDetector for Taps
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTile = (_selectedTile == tileData) ? null : tileData;
              });

              // Tap Logic for Non-Draggable Tiles
              if (tileData.isLocked) {
                _handleLockedTileTap(row, col); // Extracted tap logic
              } else if (tileData.isGenerator) {
                ref
                    .read(grid.gridProvider.notifier)
                    .activateGenerator(row, col);
              }
              // Handle tapping empty tiles if needed
              else if (tileData.itemImagePath == null &&
                  !tileData.isGenerator) {
                // Optionally deselect or handle tap on empty tile
                setState(() {
                  _selectedTile = null; // Deselect on tapping empty tile
                });
              }
            },
            child: content,
          );
        }
      },
    );
  }

  // --- Helper for Locked Tile Tap Logic ---
  void _handleLockedTileTap(int row, int col) {
    final availableUnlocks = ref.read(availableUnlocksProvider);
    final mathPoint = math.Point<int>(
      col,
      row,
    ); // Using math.Point (x, y) -> (col, row)
    TileUnlock? targetUnlock;

    // Find the unlock zone covering this tile
    for (final unlock in availableUnlocks) {
      // Assuming coveredTiles in TileUnlock uses a custom Point or similar structure {row, col}
      if (unlock.coveredTiles.any((p) => p.row == row && p.col == col)) {
        targetUnlock = unlock;
        break;
      }
      // If TileUnlock uses math.Point:
      // if (unlock.coveredTiles.any((p) => p.x == col && p.y == row)) {
      //      targetUnlock = unlock;
      //      break;
      // }
    }

    if (targetUnlock != null) {
      final success = ref
          .read(playerStatsProvider.notifier)
          .unlockZone(targetUnlock);
      if (mounted) {
        // Check if the widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? "Zone '${targetUnlock.id}' unlocked!"
                  : "Failed to unlock zone. Check level (${targetUnlock.requiredLevel}) and coins (${targetUnlock.unlockCostCoins}).",
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Tile is locked, but not part of an *available* unlock
      final allUnlocks = ref.read(allUnlocksProvider);
      final actualZone = allUnlocks.firstWhere(
        (u) => u.coveredTiles.any((p) => p.row == row && p.col == col),
        // Provide a default/fallback TileUnlock if not found (adjust defaults)
        orElse:
            () => TileUnlock(
              id: 'unknown',
              requiredLevel: 999,
              unlockCostCoins: 0,
              coveredTiles: [],
            ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              actualZone.id != 'unknown'
                  ? "Zone locked. Requires Level ${actualZone.requiredLevel}."
                  : "Locked tile (Unknown zone).",
            ), // Handle case where zone isn't found
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  // --- Build Method (Simplified) ---
  @override
  Widget build(BuildContext context) {
    // `ref` is available via the `ConsumerState`
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Column(
        children: [
          // --- Top HUD ---
          const GameGridHud(), // Use the new widget
          // --- Debug Buttons Row Removed ---

          // --- Order Display ---
          const GameGridOrders(), // Use the new widget
          // --- Game Grid ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: grid.rowCount * grid.colCount, // Use constants
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: grid.colCount,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 1.0,
                    crossAxisSpacing: 1.0,
                  ),
                  // Use the _buildTile method defined within this State class
                  itemBuilder: (context, index) => _buildTile(index),
                ),
              ),
            ),
          ),

          // --- Bottom Info Bar ---
          // Pass the selected tile state to the bottom bar widget
          GameGridBottomBar(selectedTile: _selectedTile),
        ],
      ),

      // --- Floating Action Buttons ---
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'navFabGrid',
            onPressed: () {
              ref.read(activeScreenIndexProvider.notifier).state =
                  1; // Navigate to Map
            },
            tooltip: 'Go to Map',
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.map),
          ),
        ],
      ),
    );
  }
}

// Define TileDropData class (can be moved to models/tile_data.dart if preferred)
class TileDropData {
  final int row;
  final int col;
  final TileData tileData;

  TileDropData({required this.row, required this.col, required this.tileData});
}
