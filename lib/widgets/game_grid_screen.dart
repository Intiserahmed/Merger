// lib/widgets/game_grid_screen.dart (or wherever your screen is)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tile_data.dart';
import '../providers/grid_provider.dart';
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
    final int row = index ~/ colCount;
    final int col = index % colCount;
    final gridData = ref.watch(gridProvider);

    if (row >= gridData.length || col >= gridData[row].length) {
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
            .read(gridProvider.notifier)
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
          return content; // Not draggable
        }
      },
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rowCount * colCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: colCount,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) => _buildTile(context, ref, index),
        ),
      ),
      // --- Add Item Spawner Button ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Get notifiers
          final playerNotifier = ref.read(playerStatsProvider.notifier);
          final gridNotifier = ref.read(gridProvider.notifier);

          // 1. Try to spend energy
          final bool energySpent = playerNotifier.spendEnergy(spawnEnergyCost);

          if (energySpent) {
            // 2. If energy spent, try to spawn an item (e.g., Shell)
            final bool itemSpawned = gridNotifier.spawnItem(
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
}
