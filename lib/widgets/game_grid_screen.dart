// lib/widgets/game_grid_screen.dart (or wherever your screen is)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merger/models/order.dart'; // Import Order model
import 'package:merger/providers/order_provider.dart'; // Import Order provider
import 'package:merger/models/tile_unlock.dart'; // Import TileUnlock and Point
import 'package:merger/providers/expansion_provider.dart'; // Import expansion providers
import 'package:merger/main.dart'; // Import main to access global isar instance
import 'package:merger/persistence/game_service.dart'; // Import GameService

import 'dart:math' as math; // For Point class if needed elsewhere
import '../models/tile_data.dart';
import '../providers/grid_provider.dart' as grid; // Use prefix
import '../providers/player_provider.dart';
import '../providers/navigation_provider.dart'; // Import navigation provider

// Define colors for the chessboard pattern
final Color lightBrown = Colors.brown[300]!;
final Color darkBrown = Colors.brown[600]!;
final Color grassGreen = Colors.green[400]!; // For grass base tiles

class GameGridScreen extends ConsumerWidget {
  const GameGridScreen({super.key});

  // --- Helper to build Tile Content (Emoji or Image) ---
  Widget _buildTileContent(
    String pathOrEmoji, {
    BoxFit fit = BoxFit.contain,
    double size = 28, // Default size, can be overridden
  }) {
    // Simple check: if it contains '/', assume it's a path
    if (pathOrEmoji.contains('/')) {
      return Image.asset(
        pathOrEmoji,
        fit: fit,
        errorBuilder:
            (context, error, stackTrace) => Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.red.shade300,
                size: size * 0.8,
              ),
            ),
      );
    } else {
      // Assume it's an emoji
      return Center(
        child: Text(
          pathOrEmoji,
          style: TextStyle(fontSize: size), // Adjust emoji size via parameter
        ),
      );
    }
  }

  // --- Build Tile Widget ---
  Widget _buildTile(BuildContext context, WidgetRef ref, int index) {
    // Use prefixed constants
    final int row = index ~/ grid.colCount;
    final int col = index % grid.colCount;
    final gridData = ref.watch(grid.gridProvider); // Use prefixed provider

    // Use gridData dimensions for safety, though constants should match
    if (row >= gridData.length || col >= gridData[0].length) {
      // Assuming grid is not empty
      return Container(color: Colors.red.withOpacity(0.2)); // Error indicator
    }
    final TileData tileData = gridData[row][col];

    // Determine background color based on chessboard pattern and base image
    Color backgroundColor;
    if (tileData.baseImagePath == '🟩') {
      // Grass tiles are always green
      backgroundColor = grassGreen;
    } else if (tileData.isLocked) {
      backgroundColor = Colors.grey.shade500; // Locked tiles are grey
    } else {
      // Chessboard pattern for non-grass, unlocked tiles
      backgroundColor = (row + col) % 2 == 0 ? lightBrown : darkBrown;
    }

    // --- Drag Target Logic ---
    return DragTarget<TileDropData>(
      onWillAccept: (dragData) {
        if (dragData == null || (dragData.row == row && dragData.col == col)) {
          return false;
        }
        final targetTile = tileData;
        final sourceTile = dragData.tileData;

        // Prevent dropping onto locked tiles
        if (targetTile.isLocked) return false;

        // --- NEW Merge Logic Check (based on provider logic) ---
        // Check if items are identical and part of the plant sequence
        if (targetTile.itemImagePath != null &&
            targetTile.itemImagePath == sourceTile.itemImagePath &&
            grid.plantSequence.contains(targetTile.itemImagePath)) {
          // Check if it's not the max level
          final currentIndex = grid.plantSequence.indexOf(
            targetTile.itemImagePath!,
          );
          return currentIndex < grid.plantSequence.length - 1;
        }
        // Check for other specific item merges (e.g., Shell, Sword)
        else if (targetTile.itemImagePath != null &&
            targetTile.itemImagePath == sourceTile.itemImagePath &&
            (targetTile.itemImagePath == '🐚' ||
                targetTile.itemImagePath == '⚔️')) {
          // Add specific checks if needed (e.g., prevent merging sword into shield if shield exists)
          return true;
        }
        // Allow dropping onto an empty tile (if needed for placement logic later)
        // else if (targetTile.isEmpty) {
        //   return true; // Or add specific placement rules
        // }

        return false; // Default: don't accept drop
      },
      onAccept: (dragData) {
        // Only call merge if it's a valid merge target based on onWillAccept logic
        // (We assume onWillAccept correctly filtered)
        ref
            .read(grid.gridProvider.notifier) // Use prefix
            .mergeTiles(row, col, dragData.row, dragData.col);
      },
      builder: (context, candidateData, rejectedData) {
        // --- Visual Representation (No more number overlay) ---
        Widget content = Container(
          key: ValueKey(
            'tile_${row}_${col}_${tileData.type}_${tileData.itemImagePath ?? 'base'}',
          ),
          margin: const EdgeInsets.all(1.0), // Small margin between tiles
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: Colors.black.withOpacity(0.2),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              // --- Base Layer (Only show if different from background, e.g., generator) ---
              if (tileData.isGenerator || tileData.isLocked)
                _buildTileContent(
                  tileData.baseImagePath,
                  fit: BoxFit.contain, // Generators might not fill
                  size: 30,
                ),
              // --- Item Layer (Conditional) ---
              if (tileData.itemImagePath != null)
                _buildTileContent(
                  tileData.itemImagePath!,
                  fit: BoxFit.contain,
                  size: 28, // Slightly smaller for item
                ),
              // --- Cooldown Overlay for Generators ---
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

        // Wrap content in SizedBox for consistent sizing
        content = SizedBox(
          width: 55, // Adjust size as needed
          height: 55,
          child: content,
        );

        // --- Draggable Logic ---
        bool isDraggable = tileData.isItem; // Only items are draggable now
        if (isDraggable) {
          return Draggable<TileDropData>(
            data: TileDropData(row: row, col: col, tileData: tileData),
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 60, // Feedback slightly larger
                height: 60,
                child: Opacity(opacity: 0.75, child: content),
              ),
            ),
            childWhenDragging: SizedBox(
              width: 55,
              height: 55,
              child: Container(
                margin: const EdgeInsets.all(1.0),
                decoration: BoxDecoration(
                  color: backgroundColor.withOpacity(0.5), // Dimmed background
                  border: Border.all(
                    color: Colors.black.withOpacity(0.4),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
            child: content,
          );
        } else {
          // --- GestureDetector for Taps (Locked, Generators, Empty) ---
          return GestureDetector(
            onTap: () {
              // --- Tap Logic for Non-Draggable Tiles ---
              if (tileData.isLocked) {
                // --- Handle Tapping Locked Tile ---
                final availableUnlocks = ref.read(availableUnlocksProvider);
                // Use math.Point for consistency if TileUnlock uses it
                final tappedPoint = math.Point(row, col);
                TileUnlock? targetUnlock;

                for (final unlock in availableUnlocks) {
                  // Ensure unlock.coveredTiles contains math.Point objects
                  // dart:math Point uses x/y, TileUnlock Point uses row/col.
                  // Assuming coveredTiles uses the TileUnlock Point definition.
                  if (unlock.coveredTiles.any(
                    (p) =>
                        p.row == row &&
                        p.col == col, // Compare with tile's row/col
                  )) {
                    targetUnlock = unlock;
                    break;
                  }
                }

                if (targetUnlock != null) {
                  // Attempt to unlock the zone
                  final success = ref
                      .read(playerStatsProvider.notifier)
                      .unlockZone(targetUnlock);

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
                } else {
                  // Tile is locked, but not part of an AVAILABLE unlock
                  final allUnlocks = ref.read(allUnlocksProvider);
                  final actualZone = allUnlocks.firstWhere(
                    (u) => u.coveredTiles.any(
                      (p) =>
                          p.row == row &&
                          p.col == col, // Compare with tile's row/col
                    ),
                    orElse:
                        () =>
                            TileUnlock(id: 'unknown_zone', requiredLevel: 999),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Zone locked. Requires Level ${actualZone.requiredLevel}.",
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              } else if (tileData.isGenerator) {
                // --- Handle Tapping Generator ---
                ref
                    .read(grid.gridProvider.notifier)
                    .activateGenerator(row, col);
              }
              // Add other tap actions for empty tiles if needed later
            },
            child: content, // Wrap content in GestureDetector
          ); // Not draggable
        }
      }, // End builder
    );
  }

  // --- Build Top Area (Level + Status Bars) ---
  Widget _buildTopArea(BuildContext context, WidgetRef ref) {
    // Watch the whole PlayerStats object
    final playerStats = ref.watch(playerStatsProvider);
    // Access individual stats from the object
    final level = playerStats.level;
    final energy = playerStats.energy;
    final maxEnergy = playerStats.maxEnergy; // Get maxEnergy from PlayerStats
    final coins = playerStats.coins;
    final gems =
        playerStats.gems; // Assuming gems is added to PlayerStats model

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ).copyWith(top: MediaQuery.of(context).padding.top + 8.0), // Safe area
      color: Colors.blue.shade700, // Example background color
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- Level Indicator ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.lightBlueAccent, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.yellowAccent, size: 20),
                const SizedBox(width: 6),
                Text(
                  '$level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // --- Resource Bars ---
          Row(
            children: [
              _buildResourceBar('⚡', '$energy/$maxEnergy', Colors.yellow),
              const SizedBox(width: 10),
              _buildResourceBar('💰', '$coins', Colors.amber),
              const SizedBox(width: 10),
              _buildResourceBar('💎', '$gems', Colors.purpleAccent),
            ],
          ),
        ],
      ),
    );
  }

  // Helper for individual resource bars in the status bar
  Widget _buildResourceBar(String icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.8), width: 1),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // --- Build Bottom Info Bar Placeholder ---
  Widget _buildBottomInfoBarPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.blueGrey.shade700,
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white70, size: 20),
          SizedBox(width: 10),
          Text(
            "Placeholder: Merge items to reach next level.", // Placeholder text
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get screen size for potential adjustments
    // final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // Remove AppBar
      // appBar: AppBar(...),
      backgroundColor: Colors.blueGrey.shade900, // Darker background overall
      body: Column(
        // Use Column for layout
        children: [
          // --- Top Area (Status Bar + Level) ---
          _buildTopArea(context, ref),

          // --- Debug Buttons (Optional, keep for now) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.build, color: Colors.white54),
                tooltip: 'Place Barracks (Debug)',
                onPressed: () {
                  ref
                      .read(grid.gridProvider.notifier)
                      .placeGenerator(1, 1, grid.barracksEmoji);
                },
              ),
              IconButton(
                icon: const Icon(Icons.agriculture, color: Colors.white54),
                tooltip: 'Place Mine (Debug)',
                onPressed: () {
                  ref
                      .read(grid.gridProvider.notifier)
                      .placeGenerator(2, 2, grid.mineEmoji);
                },
              ),
              IconButton(
                icon: const Icon(Icons.save, color: Colors.white54),
                tooltip: 'Save Game State (Debug)',
                onPressed: () async {
                  final container = ProviderScope.containerOf(context);
                  await GameService(isar, container).saveGame();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Game state saved!"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),

          // --- Game Grid ---
          Expanded(
            // Grid takes remaining space
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Padding around the grid
              child: Center(
                // Center the grid if it doesn't fill width
                child: GridView.builder(
                  shrinkWrap: true, // Important if grid is centered or smaller
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: grid.rowCount * grid.colCount,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: grid.colCount,
                    childAspectRatio: 1.0, // Keep square tiles
                    mainAxisSpacing: 2.0, // Spacing between rows
                    crossAxisSpacing: 2.0, // Spacing between columns
                  ),
                  itemBuilder:
                      (context, index) => _buildTile(context, ref, index),
                ),
              ),
            ),
          ),

          // --- Order Display Area ---
          _buildOrderDisplay(context, ref),

          // --- Bottom Info Bar ---
          _buildBottomInfoBarPlaceholder(),
        ],
      ),
      // --- Floating Action Buttons ---
      floatingActionButton: Row(
        // Use a Row to place buttons side-by-side
        mainAxisAlignment: MainAxisAlignment.end, // Align to the end
        children: [
          // --- Spawn Button ---
          FloatingActionButton.extended(
            heroTag: 'spawnFabGrid', // Unique heroTag for Grid screen spawn
            onPressed: () {
              final playerNotifier = ref.read(playerStatsProvider.notifier);
              final gridNotifier = ref.read(grid.gridProvider.notifier);
              final bool energySpent = playerNotifier.spendEnergy(
                spawnEnergyCost,
              );

              if (energySpent) {
                // Spawn the base plant item
                final bool itemSpawned = gridNotifier.spawnItemOnFirstEmpty(
                  grid.plantSequence[0],
                );

                if (!itemSpawned) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("No empty space to spawn an item!"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  // Optional refund
                  // playerNotifier.addEnergy(spawnEnergyCost);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Not enough energy to spawn an item!"),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            label: const Text('Spawn 🌱'), // Update label
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Costs $spawnEnergyCost energy',
            backgroundColor: Colors.teal, // Example color
          ),
          const SizedBox(width: 10), // Spacing between FABs
          // --- Navigation Button ---
          FloatingActionButton(
            heroTag: 'navFabGrid', // Unique heroTag for Grid screen nav
            onPressed: () {
              // Set the active screen index to 1 (MapScreen)
              ref.read(activeScreenIndexProvider.notifier).state = 1;
            },
            tooltip: 'Go to Map',
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.map),
          ),
        ],
      ),
      /* // Original FAB code:
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final playerNotifier = ref.read(playerStatsProvider.notifier);
          final gridNotifier = ref.read(grid.gridProvider.notifier);
          final bool energySpent = playerNotifier.spendEnergy(spawnEnergyCost);

          if (energySpent) {
            // Spawn the base plant item
            final bool itemSpawned = gridNotifier.spawnItemOnFirstEmpty(
              grid.plantSequence[0],
            );

            if (!itemSpawned) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("No empty space to spawn an item!"),
                  duration: Duration(seconds: 1),
                ),
              );
              // Optional refund
              // playerNotifier.addEnergy(spawnEnergyCost);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Not enough energy to spawn an item!"),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        label: const Text('Spawn 🌱'), // Update label
        icon: const Icon(Icons.add_circle_outline),
        tooltip: 'Costs $spawnEnergyCost energy',
        backgroundColor: Colors.teal, // Example color
      ),
      */
    );
  }

  // --- Helper Widget to Display Orders (Keep as is for now) ---
  Widget _buildOrderDisplay(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);

    if (orders.isEmpty) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: Text(
            "No active orders.",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Container(
      height: 100,
      color: Colors.black.withOpacity(0.2), // Darker background
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            color: Colors.blueGrey.shade800, // Darker card
            margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: _buildTileContent(order.requiredItemId, size: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "x ${order.requiredCount}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text
                    ),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600, // Button color
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(60, 25),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      ref.read(orderProvider.notifier).attemptDelivery(order);
                    },
                    child: const Text("Deliver"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
