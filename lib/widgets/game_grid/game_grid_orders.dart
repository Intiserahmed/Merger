// TODO Implement this library.
// lib/widgets/game_grid/game_grid_orders.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merger/providers/order_provider.dart';
import 'package:merger/widgets/game_grid/tile_content.dart';
import 'package:merger/widgets/game_grid_components.dart'
    hide buildTileContent; // Import helper

class GameGridOrders extends ConsumerWidget {
  const GameGridOrders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);

    if (orders.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            "No active orders.",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    // Display only the first order for simplicity
    final order = orders.first;
    final rewardText = '+${order.rewardCoins}';

    return Container(
      height: 80,
      color: Colors.black.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content
        children: [
          // Placeholder for NPC CircleAvatar
          const CircleAvatar(
            backgroundColor: Colors.brown, // Placeholder color
            radius: 30,
            child: Text(
              '🧑',
              style: TextStyle(fontSize: 30),
            ), // Placeholder icon
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              ref.read(orderProvider.notifier).attemptDelivery(order);
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('GO', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rewardText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.yellowAccent, // Highlight reward
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              // Use the buildTileContent helper
              SizedBox(
                width: 35,
                height: 35,
                child: buildTileContent(order.requiredItemId, size: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
