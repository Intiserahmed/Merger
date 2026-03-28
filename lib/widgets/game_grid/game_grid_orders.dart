// lib/widgets/game_grid/game_grid_orders.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merger/providers/order_provider.dart';
import 'package:merger/models/order.dart';
import 'package:merger/widgets/game_grid/tile_content.dart';

class GameGridOrders extends ConsumerWidget {
  const GameGridOrders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);

    if (orders.isEmpty) {
      return Container(
        height: 88,
        color: Colors.black.withOpacity(0.2),
        child: const Center(
          child: Text('No active orders.', style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    return Container(
      height: 88,
      color: Colors.black.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: orders
            .map((order) => Expanded(child: _OrderCard(order: order)))
            .toList(),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(orderProvider.notifier).attemptDelivery(order),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.brown.shade700,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade600, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Required item
            SizedBox(
              width: 32,
              height: 32,
              child: buildTileContent(order.requiredItemId, size: 26),
            ),
            // Count
            Text(
              'x${order.requiredCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Reward
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 10)),
                Text(
                  '${order.rewardCoins}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
