// TODO Implement this library.
// lib/widgets/game_grid/game_grid_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:merger/models/tile_data.dart';
import 'package:merger/models/merge_trees.dart';
import 'package:merger/models/generator_config.dart';
import 'package:merger/widgets/info_popup.dart'; // Import InfoPopup

class GameGridBottomBar extends StatelessWidget {
  final TileData? selectedTile; // Receive selected tile data

  const GameGridBottomBar({super.key, required this.selectedTile});

  @override
  Widget build(BuildContext context) {
    if (selectedTile == null || selectedTile!.isLocked) {
      // Show placeholder or default message if no valid tile is selected
      return Container(
        height: 50, // Match height
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Select an item or generator.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    final selectedTileData = selectedTile!; // Guaranteed non-null here
    final emoji = selectedTileData.itemImagePath;
    final isGenerator = selectedTileData.isGenerator;
    final mergeItem = emoji != null ? mergeItemsByEmoji[emoji] : null;
    final generatorConfig = generatorConfigs[selectedTileData.baseImagePath];

    String infoText = 'Select an item or generator.'; // Default text
    Widget? popupToShow; // Widget to show on tap

    if (isGenerator && generatorConfig != null) {
      infoText =
          'Generator: Produces ${selectedTileData.generatesItemPath ?? '??'}, '
          'Cooldown: ${generatorConfig.cooldown}s';
      popupToShow = InfoPopup(
        generatorEmoji: selectedTileData.baseImagePath,
        generatorConfig: generatorConfig,
      );
    } else if (mergeItem != null) {
      infoText =
          '${mergeItem.id.replaceAll("_", " ")} (Lvl ${mergeItem.level}). '
          'Merge to reach next level.';
      popupToShow = InfoPopup(item: mergeItem);
    } else if (emoji != null) {
      // Handle case where it's an item but not in mergeItemsByEmoji
      infoText = 'Item: $emoji';
      // Optionally create a generic InfoPopup for unknown items if needed
    } else {
      // Empty tile selected
      infoText = 'Empty Tile';
    }

    return Container(
      height: 50,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (popupToShow != null) {
                showDialog(context: context, builder: (_) => popupToShow!);
              }
            },
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
