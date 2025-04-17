// TODO Implement this library.
// lib/widgets/game_grid/game_grid_hud.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merger/providers/player_provider.dart';

// Helper for individual resource display in the HUD
Widget buildTopResource({
  required String icon,
  required String value,
  String? cooldown, // Optional cooldown text
}) {
  return Row(
    children: [
      Text(icon, style: const TextStyle(fontSize: 20)), // Emoji icon
      const SizedBox(width: 4),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (cooldown != null)
            Text(
              cooldown,
              style: const TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 10,
              ),
            ),
        ],
      ),
    ],
  );
}

class GameGridHud extends ConsumerWidget {
  const GameGridHud({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerStats = ref.watch(playerStatsProvider);
    final level = playerStats.level;
    final energy = playerStats.energy;
    // final maxEnergy = playerStats.maxEnergy; // If needed later
    final coins = playerStats.coins;
    final gems = playerStats.gems;
    // TODO: Get energy cooldown timer if available from provider
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
                  '$level',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // Energy
          buildTopResource(
            icon: '⚡',
            value: '$energy',
            cooldown: energyCooldown, // Pass cooldown if available
          ),

          // Coins (Using coin emoji as placeholder for clover)
          buildTopResource(icon: '🪙', value: '$coins'),

          // Gems
          buildTopResource(icon: '💎', value: '$gems'),
        ],
      ),
    );
  }
}
