// lib/models/generator_config.dart

/// Represents the configuration for a specific type of generator.
class GeneratorConfig {
  final String
  sequenceId; // The ID of the merge sequence this generator starts (e.g., 'pebble', 'plant')
  final int cooldown; // Cooldown duration in seconds
  final int energyCost; // Energy cost to activate the generator

  const GeneratorConfig({
    required this.sequenceId,
    required this.cooldown,
    required this.energyCost,
  });
}

// Defines the configurations for each generator type, keyed by their emoji.
final Map<String, GeneratorConfig> generatorConfigs = {
  // Using different emojis for generators as suggested in feedback (Bucket, Factory, Camp)
  '🪣': GeneratorConfig(
    sequenceId: 'pebble',
    cooldown: 20,
    energyCost: 5,
  ), // Bucket for Pebble sequence
  '🏭': GeneratorConfig(
    sequenceId: 'tool',
    cooldown: 15,
    energyCost: 3,
  ), // Factory for Tool sequence
  '🏕️': GeneratorConfig(
    sequenceId: 'plant',
    cooldown: 10,
    energyCost: 2,
  ), // Camp for Plant sequence
  '⛏️': GeneratorConfig(
    sequenceId: 'pebble', // Mine generates pebbles
    cooldown: 20, // Cooldown similar to Bucket
    energyCost: 5, // Energy cost similar to Bucket
  ), // Mine for Pebble sequence
  // Add other generators here
};

// Helper to potentially get the base item emoji for a generator
// (Requires access to mergeTrees, so might be better placed elsewhere or passed mergeTrees)
// String? getBaseItemForGenerator(String generatorEmoji, Map<String, List<String>> mergeTrees) {
//   final config = generatorConfigs[generatorEmoji];
//   if (config != null) {
//     final sequence = mergeTrees[config.sequenceId];
//     if (sequence != null && sequence.isNotEmpty) {
//       return sequence.first;
//     }
//   }
//   return null;
// }
