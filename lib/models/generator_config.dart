// lib/models/generator_config.dart

class GeneratorConfig {
  final String sequenceId;
  final int cooldown;    // seconds
  final int energyCost;

  const GeneratorConfig({
    required this.sequenceId,
    required this.cooldown,
    required this.energyCost,
  });
}

final Map<String, GeneratorConfig> generatorConfigs = {
  '🏕️': GeneratorConfig(sequenceId: 'plant',  cooldown: 10, energyCost: 2),
  '⛏️': GeneratorConfig(sequenceId: 'pebble', cooldown: 20, energyCost: 5),
  '🏭': GeneratorConfig(sequenceId: 'tool',   cooldown: 15, energyCost: 3),
  '💍': GeneratorConfig(sequenceId: 'gem',    cooldown: 30, energyCost: 8),
  // Legacy aliases kept so old save data doesn't break
  '🪣': GeneratorConfig(sequenceId: 'pebble', cooldown: 20, energyCost: 5),
};
