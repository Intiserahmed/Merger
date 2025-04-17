import 'package:flutter/material.dart';
import '../models/merge_item.dart';
import '../models/merge_trees.dart';
import '../models/generator_config.dart';

/// A modal that displays info for either a MergeItem or a Generator.
class InfoPopup extends StatelessWidget {
  /// Provide [item] for merge item popup, or [generatorEmoji] + [generatorConfig] for generator popup.
  final MergeItem? item;
  final String? generatorEmoji;
  final GeneratorConfig? generatorConfig;

  const InfoPopup({
    super.key,
    this.item,
    this.generatorEmoji,
    this.generatorConfig,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGenerator =
        item == null && generatorEmoji != null && generatorConfig != null;
    final sequenceId =
        isGenerator ? generatorConfig!.sequenceId : item!.sequenceId;
    final sequence = mergeTrees[sequenceId] ?? [];
    final String title =
        isGenerator
            ? 'Generator'.toUpperCase()
            : item!.id.replaceAll('_', ' ').toUpperCase();
    final String displayEmoji = isGenerator ? generatorEmoji! : item!.emoji;
    final int? level = item?.level;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Banner
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 12.0,
              ),
              decoration: BoxDecoration(
                color:
                    isGenerator
                        ? Colors.blueGrey.shade700
                        : Colors.purple.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Level (only for merge items)
            if (!isGenerator && level != null) ...[
              Text(
                'Level $level${level >= sequence.length ? ' (Max Level!)' : ''}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Main Emoji/Image
            CircleAvatar(
              radius: 40,
              backgroundColor:
                  isGenerator
                      ? Colors.lightBlue.shade50
                      : Colors.orange.shade50,
              child: Text(displayEmoji, style: const TextStyle(fontSize: 36)),
            ),

            const SizedBox(height: 12),

            // Merge Sequence Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    sequence.map((e) {
                      final bool isCurrent = e == displayEmoji;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isCurrent ? Colors.green : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color:
                              isCurrent
                                  ? Colors.green.shade100
                                  : Colors.grey.shade100,
                        ),
                        child: Text(
                          e,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Details: for generator, show cooldown & energy; for items, show produces sequence
            if (isGenerator && generatorConfig != null) ...[
              Text(
                'Cooldown: ${generatorConfig!.cooldown}s   •   Energy Cost: ${generatorConfig!.energyCost}',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ] else ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Produces:',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    sequence.map((e) {
                      return CircleAvatar(
                        backgroundColor: Colors.grey.shade100,
                        child: Text(e, style: const TextStyle(fontSize: 22)),
                      );
                    }).toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Close Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
