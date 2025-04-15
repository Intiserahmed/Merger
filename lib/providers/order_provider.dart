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

  void fulfillOrder(String orderId, String itemId /*, WidgetRef ref */) {
    final List<Order> updatedOrders = [];
    bool orderCompleted = false;
    Order? completedOrderData;

    for (var order in state) {
      if (order.id == orderId &&
          order.requiredItemId == itemId &&
          order.currentCount < order.requiredCount) {
        // Directly modify the mutable order object
        order.currentCount++;
        if (order.currentCount == order.requiredCount) {
          // Order Complete!
          print("Order ${order.id} complete!");
          orderCompleted = true;
          completedOrderData = order;
          // Don't add the completed order back to the list
        } else {
          // Order updated but not complete, add the modified order
          updatedOrders.add(order);
        }
      } else {
        // Keep other orders as they are
        updatedOrders.add(order);
      }
    }

    // Update the state with the new list
    state = updatedOrders;

    if (orderCompleted && completedOrderData != null) {
      // Optional: Immediately grant rewards here or call completeOrder
      // final playerNotifier = ref.read(playerStatsProvider.notifier);
      // playerNotifier.addCoins(completedOrderData.rewardCoins);
      // playerNotifier.addXp(completedOrderData.rewardXp);

      // Or just rely on completeOrder being called elsewhere if needed
      _maybeAddNewOrder(); // Add a new order to replace the completed one
    }
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
