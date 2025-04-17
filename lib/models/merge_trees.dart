// lib/models/merge_trees.dart
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

// --- Map of all merge items keyed by their emoji ---
// TODO: Populate this map with all items from all sequences
final Map<String, MergeItem> mergeItemsByEmoji = {
  '🐚': const MergeItem(
    id: 'pebble_3', // Assuming seashell is level 3 of pebble sequence
    emoji: '🐚',
    level: 3,
    generatorEmoji: '⛏️', // Assuming pebbles come from the mine
    sequenceId: 'pebble',
  ),
  // Add all other items here...
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
