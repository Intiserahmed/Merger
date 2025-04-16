// lib/widgets/game_grid_screen.dart (or wherever your screen is)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merger/models/order.dart'; // Import Order model
import 'package:merger/providers/order_provider.dart'; // Import Order provider
import 'package:merger/models/tile_unlock.dart'; // Import TileUnlock and Point
import 'package:merger/providers/expansion_provider.dart'; // Import expansion providers
import 'package:merger/main.dart'; // Import main to access global isar instance
import 'package:merger/persistence/game_service.dart'; // Import GameService

import '../models/tile_data.dart';
import '../providers/grid_provider.dart' as grid; // Use prefix
import '../providers/player_provider.dart'; // Example for showing coins

class GameGridScreen extends ConsumerWidget {
  const GameGridScreen({super.key});

  // --- Helper to build Tile Content (Emoji or Image) ---
  Widget _buildTileContent(
    String pathOrEmoji, {
    BoxFit fit = BoxFit.contain,
    double size = 28,
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

    // --- Drag Target Logic (Remains the same) ---
    return DragTarget<TileDropData>(
      onWillAccept: (dragData) {
        if (dragData == null || (dragData.row == row && dragData.col == col)) {
          return false;
        }
        final targetTile = tileData; // Use data already watched
        final sourceTile = dragData.tileData;
        // --- Merge Logic ---
        // Rule 1: Merge identical overlay numbers > 0
        if (targetTile.overlayNumber > 0 &&
            targetTile.overlayNumber == sourceTile.overlayNumber) {
          return true;
        }
        // Rule 2: Merge specific identical items (emojis)
        else if (targetTile.itemImagePath !=
                null && // Ensure target has an item
            targetTile.itemImagePath ==
                sourceTile.itemImagePath && // Items must match
            (targetTile.itemImagePath == '🐚' ||
                targetTile.itemImagePath ==
                    '⚔️')) // Only allow shell or sword merges for now
        {
          return true;
        }
        // Otherwise, don't allow the drop
        return false;
      },
      onAccept: (dragData) {
        ref
            .read(grid.gridProvider.notifier) // Use prefix
            .mergeTiles(row, col, dragData.row, dragData.col);
      },
      builder: (context, candidateData, rejectedData) {
        Widget content;

        // --- Visual Representation ---
        if (tileData.overlayNumber > 0) {
          // --- Number Overlay ---
          content = Container(
            key: ValueKey('overlay_${row}_${col}_${tileData.overlayNumber}'),
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              // Light background for number overlay (can be themed)
              color: Colors.grey.shade300.withOpacity(0.8),
              // Use emoji as subtle background texture?
              // Faded base emoji behind number:
              // image: DecorationImage(
              //   image: TextAsImage(tileData.baseImagePath), // Hypothetical TextAsImage
              //   opacity: 0.1
              // ),
              border: Border.all(color: Colors.black54, width: 0.5),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder:
                    (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                child: Text(
                  '${tileData.overlayNumber}',
                  key: ValueKey<int>(tileData.overlayNumber),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87, // Darker text on light background
                    shadows: [
                      Shadow(
                        blurRadius: 1.0,
                        color: Colors.white,
                        offset: Offset(0.5, 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          // --- Base Tile + Item (Using Emojis/Images) ---
          content = Container(
            key: ValueKey(
              'item_${row}_${col}_${tileData.itemImagePath ?? 'empty'}',
            ),
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              // Optional: Add a subtle border to empty tiles too
              border: Border.all(color: Colors.grey.shade400, width: 0.5),
              borderRadius: BorderRadius.circular(4.0),
              // Optional: slight background color if base image is transparent emoji
              // color: Colors.brown.shade100.withOpacity(0.3),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // --- Base Layer ---
                // Use helper, provide appropriate fit and size
                _buildTileContent(
                  tileData.baseImagePath,
                  fit: BoxFit.fill,
                  size: 30,
                ), // Base fills more
                // --- Item Layer (Conditional) ---
                if (tileData.itemImagePath != null)
                  // Use helper, maybe slightly smaller size for item
                  _buildTileContent(
                    tileData.itemImagePath!,
                    fit: BoxFit.contain,
                    size: 26,
                  ),
              ],
            ),
          );
        }

        // --- Draggable Logic (Remains the same) ---
        bool isDraggable =
            tileData.overlayNumber > 0 || tileData.itemImagePath != null;
        if (isDraggable) {
          return Draggable<TileDropData>(
            data: TileDropData(row: row, col: col, tileData: tileData),
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 60,
                height: 60,
                // Apply styling to feedback if needed (e.g., different background)
                child: Opacity(opacity: 0.7, child: content),
              ),
            ),
            childWhenDragging: Container(
              margin: const EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.3),
                border: Border.all(color: Colors.brown.shade300, width: 0.5),
                borderRadius: BorderRadius.circular(4.0),
              ),
              // Optional: show base emoji faintly in empty spot
              // child: Center(child: Text(tileData.baseImagePath, style: TextStyle(fontSize: 20, color: Colors.black.withOpacity(0.2)))),
            ),
            child: content,
          );
        } else {
          return GestureDetector(
            onTap: () {
              // --- Tap Logic for Non-Draggable Tiles ---
              if (tileData.isLocked) {
                // --- Handle Tapping Locked Tile ---
                final availableUnlocks = ref.read(availableUnlocksProvider);
                final tappedPoint = Point(
                  row,
                  col,
                ); // Point from tile_unlock.dart
                TileUnlock? targetUnlock;

                // Find which available unlock this tile belongs to
                for (final unlock in availableUnlocks) {
                  if (unlock.coveredTiles.contains(tappedPoint)) {
                    targetUnlock = unlock;
                    break;
                  }
                }

                if (targetUnlock != null) {
                  // Attempt to unlock the zone
                  final success = ref
                      .read(playerStatsProvider.notifier)
                      .unlockZone(targetUnlock);

                  // Show feedback
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
                  // (Could be level too low, or already unlocked but grid hasn't updated yet)
                  // Find the zone it *does* belong to for info message
                  final allUnlocks = ref.read(allUnlocksProvider);
                  final actualZone = allUnlocks.firstWhere(
                    (u) => u.coveredTiles.contains(tappedPoint),
                    orElse:
                        () => TileUnlock(
                          id: 'unknown_zone',
                          requiredLevel: 999,
                        ), // Default if somehow not found
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Zone locked. Requires Level ${actualZone.requiredLevel}.",
                      ), // Simple message
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              } else if (tileData.isGenerator) {
                // --- Handle Tapping Generator ---
                ref
                    .read(grid.gridProvider.notifier)
                    .activateGenerator(row, col); // Use prefix
              }
              // Add other tap actions for empty tiles if needed later
            },
            child: content, // Wrap content in GestureDetector
          ); // Not draggable
        }
      }, // End builder
    );
  }

  // --- Main Build Method (Remains mostly the same) ---
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merger Game (Emoji Placeholders)'),
        actions: [
          // Example: Show Coins
          Consumer(
            builder: (context, ref, child) {
              final coins = ref.watch(coinsProvider);
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(child: Text('💰: $coins')), // Use coin emoji
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.build), // Or any other icon
            tooltip: 'Place Barracks (Debug)',
            onPressed: () {
              ref
                  .read(grid.gridProvider.notifier) // Use prefix
                  .placeGenerator(1, 1, grid.barracksEmoji); // Use prefix
            },
          ),
          IconButton(
            icon: const Icon(Icons.agriculture), // Or any other icon
            tooltip: 'Place Mine (Debug)',
            onPressed: () {
              ref
                  .read(grid.gridProvider.notifier) // Use prefix
                  .placeGenerator(2, 2, grid.mineEmoji); // Use prefix
            },
          ),
          // Add Save Button (Debug)
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Game State (Debug)',
            onPressed: () async {
              // Access the GameService via the global Isar instance and the ref's container
              // This is not ideal, but works for now. A better approach would use a dedicated provider for GameService.
              final container = ProviderScope.containerOf(context);
              await GameService(
                isar,
                container,
              ).saveGame(); // Use global isar from main.dart
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
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          // Use prefixed constants
          itemCount: grid.rowCount * grid.colCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: grid.colCount, // Use prefix
            childAspectRatio: 1.0, // Keep aspect ratio 1 for square tiles
          ),
          itemBuilder: (context, index) => _buildTile(context, ref, index),
        ),
      ),
      // --- Order Display Area ---
      bottomNavigationBar: _buildOrderDisplay(
        context,
        ref,
      ), // Add order display
      // --- Add Item Spawner Button ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Get notifiers
          final playerNotifier = ref.read(playerStatsProvider.notifier);
          final gridNotifier = ref.read(
            grid.gridProvider.notifier,
          ); // Use prefix

          // 1. Try to spend energy
          final bool energySpent = playerNotifier.spendEnergy(spawnEnergyCost);

          if (energySpent) {
            // 2. If energy spent, try to spawn an item (e.g., Shell)
            final bool itemSpawned = gridNotifier.spawnItemOnFirstEmpty(
              '🐚',
            ); // Spawn a shell

            if (!itemSpawned) {
              // Optional: Show feedback if no empty tile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("No empty space to spawn an item!"),
                  duration: Duration(seconds: 1),
                ),
              );
              // Consider refunding energy if spawn fails? Depends on game design.
              // playerNotifier.addEnergy(spawnEnergyCost); // Example refund
            }
          } else {
            // Optional: Show feedback if not enough energy
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Not enough energy to spawn an item!"),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        label: const Text('Spawn Item'),
        icon: const Icon(Icons.add_circle_outline),
        tooltip: 'Costs $spawnEnergyCost energy',
      ),
    );
  }

  // --- Helper Widget to Display Orders ---
  Widget _buildOrderDisplay(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider); // Watch the list of orders

    if (orders.isEmpty) {
      return const SizedBox(
        height: 60, // Placeholder height
        child: Center(child: Text("No active orders.")),
      );
    }

    return Container(
      height: 100, // Adjust height as needed
      color: Colors.blueGrey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Display orders horizontally
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display required item (using the tile content helper)
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: _buildTileContent(order.requiredItemId, size: 24),
                  ),
                  const SizedBox(height: 4),
                  // Display required count
                  Text(
                    "x ${order.requiredCount}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // Delivery Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(60, 25), // Smaller button
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      // Call the provider method to attempt delivery
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
