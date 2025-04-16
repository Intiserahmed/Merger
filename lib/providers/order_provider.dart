// lib/providers/order_provider.dart
import 'dart:math'; // For random selection

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/tile_data.dart'; // Need TileData
import 'grid_provider.dart'; // Need GridProvider
import 'player_provider.dart'; // Need PlayerStatsProvider

// --- Possible Orders ---
// Define a list of potential orders the game can generate
final List<Order> _possibleOrders = [
  Order(
    id: 'order_star_1',
    requiredItemId: '⭐',
    requiredCount: 1,
    rewardCoins: 50,
    rewardXp: 10,
  ),
  Order(
    id: 'order_shield_1',
    requiredItemId: '🛡️',
    requiredCount: 1,
    rewardCoins: 100,
    rewardXp: 25,
  ),
  Order(
    id: 'order_star_3',
    requiredItemId: '⭐',
    requiredCount: 3,
    rewardCoins: 200,
    rewardXp: 50,
  ),
  Order(
    id: 'order_sword_5', // Example: Order for base items
    requiredItemId: '⚔️',
    requiredCount: 5,
    rewardCoins: 30,
    rewardXp: 5,
  ),
  // Add more diverse orders
];

class OrderNotifier extends StateNotifier<List<Order>> {
  final Ref ref; // Inject Ref

  OrderNotifier(this.ref)
    : super(_generateInitialOrders(3)); // Start with 3 orders

  // Generate a specified number of unique initial orders
  static List<Order> _generateInitialOrders(int count) {
    final random = Random();
    final availableOrders = List<Order>.from(_possibleOrders); // Copy the list
    final initialOrders = <Order>[];

    for (int i = 0; i < count && availableOrders.isNotEmpty; i++) {
      final randomIndex = random.nextInt(availableOrders.length);
      initialOrders.add(availableOrders.removeAt(randomIndex));
    }
    return initialOrders;
  }

  /// Attempts to deliver items for a specific order.
  /// Checks the grid for required items and consumes them if found.
  /// Grants rewards and replaces the order if successful.
  void attemptDelivery(Order orderToDeliver) {
    final gridState = ref.read(gridProvider);
    final gridNotifier = ref.read(gridProvider.notifier);
    final playerNotifier = ref.read(playerStatsProvider.notifier);

    // 1. Count how many of the required item exist on the grid
    int foundCount = 0;
    List<Point<int>> itemLocations = []; // Store locations to remove later

    for (int r = 0; r < gridState.length; r++) {
      for (int c = 0; c < gridState[r].length; c++) {
        final tile = gridState[r][c];
        if (tile.itemImagePath == orderToDeliver.requiredItemId) {
          foundCount++;
          itemLocations.add(Point(r, c));
        }
        // Optional: Check overlayNumber if orders require specific tiers
        // else if (tile.overlayNumber == orderToDeliver.requiredTier && tile.baseImagePath == orderToDeliver.requiredBase) { ... }
      }
    }

    // 2. Check if enough items were found
    if (foundCount >= orderToDeliver.requiredCount) {
      print(
        "Found $foundCount ${orderToDeliver.requiredItemId}(s). Delivering ${orderToDeliver.requiredCount}.",
      );

      // 3. Consume the required number of items from the grid
      int consumedCount = 0;
      for (final location in itemLocations) {
        if (consumedCount < orderToDeliver.requiredCount) {
          // Replace the item tile with an empty tile
          const String defaultBase = '🟫'; // Default empty tile base
          gridNotifier.updateTile(
            location.x,
            location.y,
            // Add row/col to the empty tile data
            TileData(
              row: location.x,
              col: location.y,
              baseImagePath: defaultBase,
            ),
          );
          consumedCount++;
        } else {
          break; // Stop consuming once requirement is met
        }
      }

      // 4. Grant Rewards
      playerNotifier.addCoins(orderToDeliver.rewardCoins);
      playerNotifier.addXp(orderToDeliver.rewardXp);
      print(
        "Order '${orderToDeliver.id}' delivered! Rewarded ${orderToDeliver.rewardCoins} coins and ${orderToDeliver.rewardXp} XP.",
      );

      // 5. Remove the completed order and add a new one
      state = state.where((order) => order.id != orderToDeliver.id).toList();
      _maybeAddNewOrder();
    } else {
      print(
        "Not enough items for order '${orderToDeliver.id}'. Found $foundCount, need ${orderToDeliver.requiredCount}.",
      );
      // Optional: Show feedback to the user (e.g., SnackBar)
    }
  }

  // Adds a new random order if the current number of orders is below a threshold
  void _maybeAddNewOrder() {
    const int maxActiveOrders = 3; // Keep 3 active orders
    if (state.length < maxActiveOrders) {
      final random = Random();
      final availableOrders = List<Order>.from(_possibleOrders);
      // Remove orders already active
      final activeOrderIds = state.map((o) => o.id).toSet();
      availableOrders.removeWhere((o) => activeOrderIds.contains(o.id));

      if (availableOrders.isNotEmpty) {
        final randomIndex = random.nextInt(availableOrders.length);
        final newOrder = availableOrders[randomIndex];
        state = [...state, newOrder]; // Add the new order to the list
        print("Added new order: ${newOrder.id}");
      } else {
        print("No more unique orders available to add.");
      }
    }
  }
}

// Update the provider definition to pass the ref
final orderProvider = StateNotifierProvider<OrderNotifier, List<Order>>((ref) {
  return OrderNotifier(ref); // Pass ref here
});
