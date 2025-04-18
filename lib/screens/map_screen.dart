// lib/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merger/providers/player_provider.dart'; // Import the main provider
import 'package:merger/providers/navigation_provider.dart'; // Import navigation provider

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  // --- Build Top Area (Level + Status Bars) - Duplicated from GameGridScreen ---
  // TODO: Refactor this into a shared widget
  Widget _buildTopArea(BuildContext context, WidgetRef ref) {
    // Watch the whole PlayerStats object
    final playerStats = ref.watch(playerStatsProvider);
    // Access individual stats from the object
    final level = playerStats.level;
    final energy = playerStats.energy;
    final maxEnergy = playerStats.maxEnergy;
    final coins = playerStats.coins;
    final gems = playerStats.gems;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ).copyWith(top: MediaQuery.of(context).padding.top + 8.0), // Safe area
      color: Colors.blue.shade700, // Example background color
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- Level Indicator ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.lightBlueAccent, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.yellowAccent, size: 20),
                const SizedBox(width: 6),
                Text(
                  '$level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // --- Resource Bars ---
          Row(
            children: [
              _buildResourceBar('⚡', '$energy/$maxEnergy', Colors.yellow),
              const SizedBox(width: 10),
              _buildResourceBar('💰', '$coins', Colors.amber),
              const SizedBox(width: 10),
              _buildResourceBar('💎', '$gems', Colors.purpleAccent),
            ],
          ),
        ],
      ),
    );
  }

  // Helper for individual resource bars - Duplicated from GameGridScreen
  // TODO: Refactor this into a shared widget
  Widget _buildResourceBar(String icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.8), width: 1),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // No AppBar needed as status is handled by _buildTopArea
      backgroundColor: Colors.lightBlue.shade100, // Light background for map
      body: Column(
        children: [
          // --- Top Status Bar ---
          _buildTopArea(context, ref),

          // --- Infrastructure Upgrade List ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              // Build items up to the max defined player level
              itemCount: maxPlayerLevel,
              itemBuilder: (context, index) {
                final infrastructureLevelKey = index + 1; // Level 1, 2, 3...
                final playerStats = ref.watch(playerStatsProvider);
                final currentUpgradeLevel =
                    playerStats.infrastructureLevels[infrastructureLevelKey] ??
                    0; // Default to 0 if not found
                final bool isMaxed =
                    currentUpgradeLevel >= maxInfrastructureUpgrade;
                final nextUpgradeCost =
                    isMaxed
                        ? null
                        : infrastructureUpgradeCost[currentUpgradeLevel + 1];
                final bool canAfford =
                    nextUpgradeCost != null &&
                    playerStats.coins >= nextUpgradeCost;
                final bool canUpgrade =
                    !isMaxed &&
                    nextUpgradeCost != null &&
                    playerStats.level >=
                        infrastructureLevelKey; // Can only upgrade current or past levels

                // Placeholder icons for different levels
                final icons = ['🏠', '🏭', '🏛️', '🏰', '🚀'];
                final icon = icons[index % icons.length];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 3,
                  child: ListTile(
                    leading: Text(icon, style: const TextStyle(fontSize: 30)),
                    title: Text(
                      'Level $infrastructureLevelKey Infrastructure',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upgrade: $currentUpgradeLevel / $maxInfrastructureUpgrade',
                        ),
                        if (!isMaxed && nextUpgradeCost != null)
                          Text(
                            'Next Cost: $nextUpgradeCost 💰',
                            style: TextStyle(
                              color: canAfford ? Colors.green : Colors.red,
                            ),
                          )
                        else if (isMaxed)
                          const Text(
                            'Max Level Reached',
                            style: TextStyle(color: Colors.blue),
                          )
                        else // Should not happen if costs are defined correctly
                          const Text(
                            'Error: Cost not found',
                            style: TextStyle(color: Colors.orange),
                          ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed:
                          (canUpgrade && canAfford)
                              ? () {
                                ref
                                    .read(playerStatsProvider.notifier)
                                    .upgradeInfrastructure(
                                      infrastructureLevelKey,
                                    );
                              }
                              : null, // Disable button if cannot upgrade/afford
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (canUpgrade && canAfford)
                                ? Colors.green
                                : Colors.grey,
                      ),
                      child: const Text('Upgrade'),
                    ),
                    enabled: canUpgrade, // Grey out tile if level not reached
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // --- Navigation Button ---
      floatingActionButton: FloatingActionButton(
        heroTag: 'navFabMap', // Unique heroTag for Map screen nav
        onPressed: () {
          // Set the active screen index to 0 (GameGridScreen)
          ref.read(activeScreenIndexProvider.notifier).state = 0;
        },
        tooltip: 'Go to Grid',
        backgroundColor: Colors.teal, // Match grid spawn button color?
        child: const Icon(Icons.grid_on), // Icon indicating grid view
      ),
    );
  }
}
