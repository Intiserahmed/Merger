// lib/providers/order_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';

class OrderNotifier extends StateNotifier<List<Order>> {
  OrderNotifier() : super(_generateInitialOrders()); // Start with some orders

  static List<Order> _generateInitialOrders() {
    // TODO: Replace with actual order generation logic
    return [
      Order(
        id: 'order1',
        requiredItemId: 'item_shell_level_3',
        requiredCount: 2,
        rewardCoins: 50,
        rewardXp: 10,
      ),
      Order(
        id: 'order2',
        requiredItemId: 'item_castle_level_1',
        requiredCount: 1,
        rewardCoins: 100,
        rewardXp: 25,
      ),
    ];
  }

  void fulfillOrder(String orderId, String itemId) {
    // Logic to find the order, update its currentCount
    // If order complete, remove it and generate a new one, grant rewards
    state =
        state
            .map((order) {
              if (order.id == orderId &&
                  order.requiredItemId == itemId &&
                  order.currentCount < order.requiredCount) {
                final newCount = order.currentCount + 1;
                if (newCount == order.requiredCount) {
                  // Order Complete! - Handled by maybe removing/replacing
                  print("Order ${order.id} complete!");
                  // Grant rewards (handled via player provider later)
                  return null; // Mark for removal
                } else {
                  return order.copyWith(currentCount: newCount);
                }
              }
              return order;
            })
            .whereType<Order>()
            .toList(); // Filter out nulls (completed orders)

    // Maybe add a new order if list is short
    _maybeAddNewOrder();
  }

  void _maybeAddNewOrder() {
    // Logic to add new orders if needed
  }

  // Method to potentially remove/complete an order fully
  void completeOrder(String orderId /*, WidgetRef ref */) {
    // Grant rewards by calling player provider methods
    // final playerNotifier = ref.read(playerStatsProvider.notifier);
    // playerNotifier.addCoins(completedOrder.rewardCoins);
    // playerNotifier.addXp(completedOrder.rewardXp);

    state = state.where((order) => order.id != orderId).toList();
    _maybeAddNewOrder();
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<Order>>((ref) {
  return OrderNotifier();
});
