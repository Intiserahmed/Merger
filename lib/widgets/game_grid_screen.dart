// lib/widgets/game_grid_screen.dart (or wherever your screen is)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merger/models/order.dart';
import 'package:merger/providers/order_provider.dart';
import 'package:merger/models/tile_unlock.dart';
import 'package:merger/providers/expansion_provider.dart';
import 'package:merger/main.dart'; // Import main to access global isar instance
import 'package:merger/persistence/game_service.dart';
import 'package:merger/widgets/info_popup.dart'; // Import the InfoPopup
// No longer need merge_item.dart directly, mergeItemsByEmoji is in merge_trees.dart

import 'dart:math' as math;
import '../models/tile_data.dart';
import '../providers/grid_provider.dart' as grid;
import '../providers/player_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/merge_trees.dart';
import '../models/generator_config.dart';

// Define colors for the chessboard pattern
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

  // --- Helper Methods moved into State class ---
  Widget _buildTileContent(
    String pathOrEmoji, {
    BoxFit fit = BoxFit.contain,
    double size = 28,
  }) {
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
      return Center(child: Text(pathOrEmoji, style: TextStyle(fontSize: size)));
    }
  }

  // Method now belongs to _GameGridScreenState, uses `ref` directly
  Widget _buildTile(int index) {
    final int row = index ~/ grid.colCount;
    final int col = index % grid.colCount;
    final gridData = ref.watch(grid.gridProvider); // Use `ref` from State

    if (row >= gridData.length || col >= gridData[0].length) {
      return Container(color: Colors.red.withOpacity(0.2));
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

        if (targetTile.itemImagePath != null &&
            targetTile.itemImagePath == sourceTile.itemImagePath) {
          final nextItem = getNextItemInSequence(targetTile.itemImagePath!);
          if (nextItem != null) {
            return true;
          } else if (targetTile.itemImagePath == '🐚' ||
              targetTile.itemImagePath == '⚔️') {
            return true;
          }
        }

        return false;
      },
      onAccept: (dragData) {
        ref
            .read(grid.gridProvider.notifier)
            .mergeTiles(row, col, dragData.row, dragData.col);
      },
      builder: (context, candidateData, rejectedData) {
        Widget content = Container(
          key: ValueKey(
            'tile_${row}_${col}_${tileData.type}_${tileData.itemImagePath ?? 'base'}', // Corrected interpolation
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
              // --- Base Layer (Generator/Locked) ---
              if (tileData.isGenerator || tileData.isLocked)
                _buildTileContent(
                  tileData.baseImagePath,
                  fit: BoxFit.contain,
                  size: 30,
                ),
              // --- Item Background (Star concept for items) --- REMOVED
              // --- Item Layer (Conditional) ---
              if (tileData.itemImagePath != null)
                _buildTileContent(
                  tileData.itemImagePath!,
                  fit: BoxFit.contain,
                  size: 28, // Slightly smaller for item on top of star
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
                        '${tileData.remainingCooldown.inSeconds}s', // Corrected interpolation
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
          width: 50, // New smaller size
          height: 50, // New smaller size
          child: content,
        );

        // --- Draggable Logic ---
        bool isDraggable = tileData.isItem; // Only items are draggable now
        if (isDraggable) {
          return Draggable<TileDropData>(
            data: TileDropData(row: row, col: col, tileData: tileData),
            // Feedback: Only the item image/emoji
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 45, // Slightly smaller feedback visual
                height: 45,
                child: _buildTileContent(
                  tileData
                      .itemImagePath!, // Assured to be non-null by isDraggable check
                  size: 40, // Make dragged item slightly larger
                ),
              ),
            ),
            // ChildWhenDragging: The original tile without the item
            childWhenDragging: SizedBox(
              width: 50, // Match new smaller size
              height: 50, // Match new smaller size
              child: Container(
                // Rebuild the tile content *without* the item layer
                key: ValueKey(
                  'dragging_${row}_$col',
                ), // Corrected interpolation
                margin: const EdgeInsets.all(1.0),
                decoration: BoxDecoration(
                  color: backgroundColor, // Keep original background
                  border: Border.all(
                    color: Colors.black.withOpacity(0.2),
                    width: 0.5,
                  ),
                  boxShadow: null, // No shadow when item is being dragged away
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    // Base Layer (Generator/Locked) - Should not be draggable anyway, but include for completeness
                    if (tileData.isGenerator || tileData.isLocked)
                      _buildTileContent(
                        tileData.baseImagePath,
                        fit: BoxFit.contain,
                        size: 30,
                      ),
                    // Item Background (Star concept) - REMOVED
                    // --- Item Layer is intentionally OMITTED here ---
                  ],
                ),
              ),
            ),
            child: content, // The original full tile content
          );
        } else {
          // --- GestureDetector for Taps (Locked, Generators, Empty) ---
          return GestureDetector(
            onTap: () {
              // --- Update Selected Tile State ---
              setState(() {
                // Toggle selection: if same tile tapped, deselect; otherwise select new tile.
                _selectedTile = (_selectedTile == tileData) ? null : tileData;
              });

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
                            : "Failed to unlock zone. Check level (${targetUnlock.requiredLevel}) and coins (${targetUnlock.unlockCostCoins}).", // Corrected interpolation
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
                        "Zone locked. Requires Level ${actualZone.requiredLevel}.", // Corrected interpolation
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

  // --- NEW Build Top Area (HUD) ---
  // Method now belongs to _GameGridScreenState, uses `ref` directly
  Widget _buildTopArea() {
    final playerStats = ref.watch(playerStatsProvider); // Use `ref` from State
    final level = playerStats.level;
    final energy = playerStats.energy;
    // final maxEnergy = playerStats.maxEnergy; // Not used in new design directly
    final coins = playerStats.coins;
    final gems = playerStats.gems;
    // TODO: Get energy cooldown timer if available
    final energyCooldown = null; // Placeholder

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ).copyWith(top: MediaQuery.of(context).padding.top + 8.0), // Safe area
      color: Colors.blue.shade700, // Example background color
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile icon with level
          Row(
            children: [
              // Placeholder for CircleAvatar with AssetImage
              const CircleAvatar(
                backgroundColor: Colors.grey, // Placeholder color
                radius: 20,
                child: Text(
                  '👤',
                  style: TextStyle(fontSize: 24),
                ), // Placeholder icon
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
                child: Text(
                  '$level', // Corrected interpolation
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // Energy
          _buildTopResource(
            icon: '⚡',
            value: '$energy', // Corrected interpolation
            cooldown: energyCooldown, // Pass cooldown if available
          ),

          // Coins (Using coin emoji as placeholder for clover)
          _buildTopResource(
            icon: '🪙',
            value: '$coins',
          ), // Corrected interpolation
          // Gems
          _buildTopResource(
            icon: '💎',
            value: '$gems',
          ), // Corrected interpolation
        ],
      ),
    );
  }

  // --- NEW Helper for Top HUD Resources ---
  Widget _buildTopResource({
    required String icon,
    required String value,
    String? cooldown,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Prevent column taking too much space
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (cooldown != null)
          Text(
            cooldown,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ), // Adjusted color
          ),
      ],
    );
  }

  // --- NEW Build Bottom Info Bar ---
  // Method now belongs to _GameGridScreenState, uses `context` and `_selectedTile`
  Widget _buildBottomInfoBar() {
    // Use the _selectedTile state
    if (_selectedTile == null || _selectedTile!.isLocked) {
      // Show nothing or a default message if no valid tile is selected
      return const SizedBox(height: 50); // Placeholder height
    }

    final selectedTileData = _selectedTile!; // Guaranteed non-null here
    final emoji = selectedTileData.itemImagePath;
    final isGenerator = selectedTileData.isGenerator;
    final mergeItem = emoji != null ? mergeItemsByEmoji[emoji] : null;
    final generatorConfig = generatorConfigs[selectedTileData.baseImagePath];

    String infoText = 'Select an item or generator.'; // Default text
    Widget? popupToShow; // Widget to show on tap

    if (isGenerator && generatorConfig != null) {
      infoText =
          'Generator: Produces ${selectedTileData.generatesItemPath ?? '??'}, ' // Added null check
          'Cooldown: ${generatorConfig.cooldown}s';
      popupToShow = InfoPopup(
        generatorEmoji: selectedTileData.baseImagePath,
        generatorConfig: generatorConfig,
      );
    } else if (mergeItem != null) {
      infoText =
          '${mergeItem.id.replaceAll("_", " ")} (Lvl ${mergeItem.level}). ' // Added level
          'Merge to reach next level.';
      popupToShow = InfoPopup(item: mergeItem);
    } else if (emoji != null) {
      // Handle case where it's an item but not in mergeItemsByEmoji (e.g., special items)
      infoText = 'Item: $emoji';
    } else {
      // Empty tile selected (if tap logic allows selecting empty tiles)
      infoText = 'Empty Tile';
    }

    return Container(
      height: 50, // Give it a fixed height
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (popupToShow != null) {
                showDialog(
                  context: context, // Use context from State
                  builder: (_) => popupToShow!,
                );
              }
            },
            // Show info icon only if there's something to show info about
            child: Icon(
              Icons.info_outline,
              color:
                  popupToShow != null ? Colors.black54 : Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              infoText,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.ellipsis, // Prevent overflow
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW Helper Widget to Display Orders ---
  // Method now belongs to _GameGridScreenState, uses `ref` directly
  Widget _buildOrderDisplay() {
    final orders = ref.watch(orderProvider); // Use `ref` from State

    if (orders.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            "No active orders.",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    // Display only the first order for simplicity, matching the new design
    final order = orders.first;
    // Placeholder for reward text (assuming coins)
    final rewardText = '+${order.rewardCoins}'; // Corrected interpolation

    return Container(
      height: 80,
      color: Colors.black.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content
        children: [
          // Placeholder for NPC CircleAvatar
          const CircleAvatar(
            backgroundColor: Colors.brown, // Placeholder color
            radius: 30,
            child: Text(
              '🧑',
              style: TextStyle(fontSize: 30),
            ), // Placeholder icon
          ),
          const SizedBox(width: 8), // Adjusted spacing
          ElevatedButton(
            onPressed: () {
              ref
                  .read(orderProvider.notifier)
                  .attemptDelivery(order); // Use `ref` from State
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('GO', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 8), // Adjusted spacing
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rewardText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.yellowAccent, // Highlight reward
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              // Placeholder for Item Image
              SizedBox(
                width: 35,
                height: 35,
                child: _buildTileContent(
                  order.requiredItemId,
                  size: 30,
                ), // Call helper directly
              ),
              // Text( // Optional: Show required count if needed
              //   'x ${order.requiredCount}',
              //   style: const TextStyle(color: Colors.white70, fontSize: 10),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  // Correct build signature for State
  Widget build(BuildContext context) {
    // Get screen size for potential adjustments
    // final screenSize = MediaQuery.of(context).size;
    // `ref` is now accessed directly as a property of ConsumerState

    return Scaffold(
      // Remove AppBar
      // appBar: AppBar(...),
      backgroundColor: Colors.blueGrey.shade900, // Darker background overall
      body: Column(
        // Use Column for layout
        children: [
          // --- Top Area (Status Bar + Level) ---
          _buildTopArea(), // Call helper directly
          // --- Debug Buttons (Optional, keep for now) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.build, color: Colors.white54),
                tooltip: 'Place Camp (Debug)',
                onPressed: () {
                  ref
                      .read(grid.gridProvider.notifier)
                      .placeGenerator(1, 1, '🏕️');
                },
              ),
              IconButton(
                icon: const Icon(Icons.agriculture, color: Colors.white54),
                tooltip: 'Place Mine (Debug)',
                onPressed: () {
                  ref
                      .read(grid.gridProvider.notifier)
                      .placeGenerator(2, 2, '⛏️');
                },
              ),
              IconButton(
                icon: const Icon(Icons.factory, color: Colors.white54),
                tooltip: 'Place Workshop (Debug)',
                onPressed: () {
                  ref
                      .read(grid.gridProvider.notifier)
                      .placeGenerator(3, 3, '🏭');
                },
              ),
              IconButton(
                icon: const Icon(Icons.save, color: Colors.white54),
                tooltip: 'Save Game State (Debug)',
                onPressed: () async {
                  // Corrected way to access container for GameService
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
          // --- Order Display Area ---
          _buildOrderDisplay(), // Call helper directly
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
                    mainAxisSpacing: 1.0, // Spacing between rows
                    crossAxisSpacing: 1.0, // Spacing between columns
                  ),
                  itemBuilder: (context, index) {
                    // Context is implicitly available
                    return _buildTile(index); // Call helper directly
                  },
                ),
              ),
            ),
          ),

          // --- Bottom Info Bar ---
          _buildBottomInfoBar(), // Call helper directly
        ],
      ),
      // --- Floating Action Buttons ---
      floatingActionButton: Row(
        // Use a Row to place buttons side-by-side
        mainAxisAlignment: MainAxisAlignment.end, // Align to the end
        children: [
          // --- Spawn Button Removed ---

          // --- Navigation Button ---
          FloatingActionButton(
            // Keep only the navigation button
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
    );
  }
} // End of _GameGridScreenState class
