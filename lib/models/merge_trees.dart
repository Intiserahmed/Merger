// lib/models/merge_trees.dart
import 'package:merger/models/generator_config.dart';
import 'merge_item.dart';

// Merge sequences — each list goes from base item to highest tier
final Map<String, List<String>> mergeTrees = {
  'plant':  ['🌱', '🌿', '🌳', '🌲', '🌴', '🎋'],
  'tool':   ['🔧', '🔨', '🔩', '⚙️', '🔗', '⚒️'],
  'pebble': ['🪨', '🪵', '🐚', '🐌', '🦋', '🌸'],
  'gem':    ['💎', '🔮', '✨', '🌟', '👑'],
};

/// Build a MergeItem for each emoji in every sequence
final Map<String, MergeItem> mergeItemsByEmoji = {
  for (final entry in mergeTrees.entries)
    for (var i = 0; i < entry.value.length; i++)
      entry.value[i]: MergeItem(
        id: '${entry.key}_${i + 1}',
        emoji: entry.value[i],
        level: i + 1,
        sequenceId: entry.key,
        generatorEmoji: generatorConfigs.entries
            .firstWhere(
              (e) => e.value.sequenceId == entry.key,
              orElse: () => MapEntry('❓', GeneratorConfig(sequenceId: entry.key, cooldown: 0, energyCost: 0)),
            )
            .key,
      ),
};

/// Returns the next emoji in the merge sequence, or null if at the top.
String? getNextItemInSequence(String currentItemEmoji) {
  for (final sequence in mergeTrees.values) {
    final index = sequence.indexOf(currentItemEmoji);
    if (index != -1 && index < sequence.length - 1) {
      return sequence[index + 1];
    }
  }
  return null;
}
