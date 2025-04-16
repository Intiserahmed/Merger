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

          // --- Map Content Placeholder ---
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined, size: 80, color: Colors.blueGrey),
                    SizedBox(height: 15),
                    Text(
                      'Map Area Placeholder',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '(Implement map graphics and logic here)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
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
