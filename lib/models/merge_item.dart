// lib/models/merge_item.dart

class MergeItem {
  final String id; // Unique item ID, e.g., "pebble_1"
  final String
  emoji; // Placeholder emoji for now, later replaced with image asset
  final int level; // Level in merge sequence, starts at 1
  final String
  generatorEmoji; // Emoji or asset representing the generator (e.g., 🪣)
  final String sequenceId; // e.g., "pebble", "plant", "tool"
  final String? imagePath; // Optional PNG asset path for future UI usage

  const MergeItem({
    required this.id,
    required this.emoji,
    required this.level,
    required this.generatorEmoji,
    required this.sequenceId,
    this.imagePath,
  });
}

// Optional: Helper to convert emoji to image asset once assets are ready
// String getImageForMergeItem(MergeItem item) {
//   return item.imagePath ?? 'assets/placeholder/${item.emoji}.png';
// }

// Example usage for plant sequence (Illustrative - actual data will be centralized)
// final List<MergeItem> plantItems = [
//   MergeItem(
//     id: 'plant_1',
//     emoji: '🌱',
//     level: 1,
//     generatorEmoji: '🏕', // camp emoji
//     sequenceId: 'plant',
//     imagePath: 'assets/items/plant_1.png',
//   ),
//   MergeItem(
//     id: 'plant_2',
//     emoji: '🌿',
//     level: 2,
//     generatorEmoji: '🏕',
//     sequenceId: 'plant',
//     imagePath: 'assets/items/plant_2.png',
//   ),
//   // ...continue for higher levels
// ];
