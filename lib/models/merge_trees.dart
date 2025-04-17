// lib/models/merge_trees.dart
import 'package:merger/models/generator_config.dart';

import 'merge_item.dart'; // Import MergeItem

// Defines the sequence of items for each merge tree.
// The key is the sequence ID (e.g., 'pebble'), and the value is a list of item emojis
// in the order they merge.
final Map<String, List<String>> mergeTrees = {
  'pebble': ['🪨', '🪵', '🐚', '🐌'], // Example: Pebble sequence
  'plant': ['🌱', '🌿', '🌳', '🌲'], // Plant sequence
  'tool': [
    '🔧',
    '🔨',
    '🔩',
    '⚙️',
    '🔗',
  ], // Tool sequence (added '🔗' based on recent changes)
  // Add other sequences here, e.g., 'shell', 'sword' if they have multiple levels
};

/// Build a MergeItem for each emoji in every sequence
final Map<String, MergeItem> mergeItemsByEmoji = {
  for (final entry in mergeTrees.entries) // each sequence
    for (var i = 0; i < entry.value.length; i++) // each emoji in it
      entry.value[i]: MergeItem(
        id: '${entry.key}_${i + 1}', // e.g. "pebble_1"
        emoji: entry.value[i],
        level: i + 1,
        sequenceId: entry.key,
        generatorEmoji:
            generatorConfigs
                .entries // find which generator produces this sequence
                .firstWhere((e) => e.value.sequenceId == entry.key)
                .key,
      ),
};

/// Finds the next item in a merge sequence.
///
/// Given the emoji of the current item (`currentItemEmoji`), this function searches
/// through all defined `mergeTrees` to find the sequence it belongs to.
/// If found and it's not the last item in the sequence, it returns the emoji
/// of the next item. Otherwise, it returns null.
String? getNextItemInSequence(String currentItemEmoji) {
  for (final sequence in mergeTrees.values) {
    final index = sequence.indexOf(currentItemEmoji);
    // Check if the item exists in the sequence and is not the last item
    if (index != -1 && index < sequence.length - 1) {
      return sequence[index + 1]; // Return the next item's emoji
    }
  }
  return null; // Item not found in any sequence or is the last item
}
