// lib/providers/order_provider.dart
import 'dart:math'; // For random selection

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../models/tile_data.dart'; // Need TileData
import 'grid_provider.dart'; // Need GridProvider
import 'player_provider.dart'; // Need PlayerStatsProvider

// --- Level-Based Order Definitions ---
// Define potential orders grouped by the player level they become available at.
// Keep orders simple for early levels, using items from initial generators.
final Map<int, List<Order>> _ordersByLevel = {
  1: [
    // Orders available at Level 1
    Order(
      id: 'lvl1_plant_1',
      requiredItemId: '🌱',
      requiredCount: 2,
      rewardCoins: 10,
      rewardXp: 5,
    ),
    Order(
      id: 'lvl1_pebble_1',
      requiredItemId: '🪨',
      requiredCount: 2,
      rewardCoins: 10,
      rewardXp: 5,
    ),
    Order(
      id: 'lvl1_tool_1',
      requiredItemId: '🔧',
      requiredCount: 1,
      rewardCoins: 15,
      rewardXp: 8,
    ),
  ],
  2: [
    // Orders available at Level 2 (includes Level 1 orders + new ones)
    Order(
      id: 'lvl2_plant_2',
      requiredItemId: '🌿',
      requiredCount: 1,
      rewardCoins: 25,
      rewardXp: 12,
    ),
    Order(
      id: 'lvl2_pebble_2',
      requiredItemId: '🪵',
      requiredCount: 1,
      rewardCoins: 25,
      rewardXp: 12,
    ),
    Order(
      id: 'lvl2_tool_2',
      requiredItemId: '🔨',
      requiredCount: 1,
      rewardCoins: 35,
      rewardXp: 18,
    ),
    Order(
      id: 'lvl2_plant_1_many',
      requiredItemId: '🌱',
      requiredCount: 4,
      rewardCoins: 20,
      rewardXp: 10,
    ), // More base items
  ],
  3: [
    // Orders available at Level 3
    Order(
      id: 'lvl3_plant_3',
      requiredItemId: '🌳',
      requiredCount: 1,
      rewardCoins: 50,
      rewardXp: 25,
    ),
    Order(
      id: 'lvl3_pebble_3',
      requiredItemId: '🐚',
      requiredCount: 1,
      rewardCoins: 50,
      rewardXp: 25,
    ),
    Order(
      id: 'lvl3_tool_3',
      requiredItemId: '🔩',
      requiredCount: 1,
      rewardCoins: 60,
      rewardXp: 30,
    ),
    Order(
      id: 'lvl3_plant_2_many',
      requiredItemId: '🌿',
      requiredCount: 2,
      rewardCoins: 45,
      rewardXp: 20,
    ),
  ],
  4: [
    // Orders available at Level 4
    Order(
      id: 'lvl4_plant_4',
      requiredItemId: '🌲',
      requiredCount: 1,
      rewardCoins: 100,
      rewardXp: 50,
    ),
    Order(
      id: 'lvl4_pebble_4',
      requiredItemId: '🐌',
      requiredCount: 1,
      rewardCoins: 100,
      rewardXp: 50,
    ),
    Order(
      id: 'lvl4_tool_4',
      requiredItemId: '⚙️',
      requiredCount: 1,
      rewardCoins: 120,
      rewardXp: 60,
    ),
    Order(
      id: 'lvl4_plant_3_many',
      requiredItemId: '🌳',
      requiredCount: 2,
      rewardCoins: 90,
      rewardXp: 45,
    ),
  ],
  5: [
    // Orders available at Level 5
    Order(
      id: 'lvl5_tool_5',
      requiredItemId: '🔗',
      requiredCount: 1,
      rewardCoins: 200,
      rewardXp: 100,
    ),
    Order(
      id: 'lvl5_plant_4_many',
      requiredItemId: '🌲',
      requiredCount: 2,
      rewardCoins: 180,
      rewardXp: 90,
    ),
    Order(
      id: 'lvl5_pebble_4_many',
      requiredItemId: '🐌',
      requiredCount: 2,
      rewardCoins: 180,
      rewardXp: 90,
    ),
    // Add more complex/higher reward orders for level 5+
  ],
  // Add more levels as needed
};

class OrderNotifier extends StateNotifier<List<Order>> {
  final Ref ref;

  OrderNotifier(this.ref) : super([]) {
    // Generate initial orders based on starting level (1)
    _generateInitialOrders(3);

    // Listen for level changes and potentially add new orders
    ref.listen<int>(playerStatsProvider.select((stats) => stats.level), (
      previousLevel,
      newLevel,
    ) {
      print(
        "[OrderNotifier] Detected level change from $previousLevel to $newLevel",
      );
      if (newLevel > (previousLevel ?? 0)) {
        // Level up occurred, try to fill order slots with potentially new available orders
        _fillOrderSlots();
      }
    });
  }

  // Generate initial orders based on the player's current level
  void _generateInitialOrders(int count) {
    final playerLevel = ref.read(playerStatsProvider).level;
    final availableOrders = _getAvailableOrdersForLevel(playerLevel);
    final random = Random();
    final initialOrders = <Order>[];

    for (int i = 0; i < count && availableOrders.isNotEmpty; i++) {
      final randomIndex = random.nextInt(availableOrders.length);
      initialOrders.add(availableOrders.removeAt(randomIndex));
    }
    state = initialOrders; // Set the initial state
  }

  // Helper to get all possible orders up to the player's current level
  List<Order> _getAvailableOrdersForLevel(int playerLevel) {
    final possibleOrders = <Order>[];
    for (int level = 1; level <= playerLevel; level++) {
      if (_ordersByLevel.containsKey(level)) {
        possibleOrders.addAll(_ordersByLevel[level]!);
      }
    }
    // Remove duplicates if orders are redefined at higher levels (optional, depends on design)
    // For now, assumes orders are additive or unique IDs prevent issues.
    return possibleOrders;
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
      // playerNotifier.addXp(orderToDeliver.rewardXp); // Keep XP separate for now
      print(
        "Order '${orderToDeliver.id}' delivered! Rewarded ${orderToDeliver.rewardCoins} coins.", // Removed XP from log
      );

      // --- Player level up is now handled by infrastructure upgrades ---
      // playerNotifier.orderCompleted(); // REMOVED

      // 5. Remove the completed order
      state = state.where((order) => order.id != orderToDeliver.id).toList();

      // 6. Add a new order immediately to replace the completed one
      _maybeAddNewOrder(); // Tries to add one order using the current level pool
    } else {
      print(
        "Not enough items for order '${orderToDeliver.id}'. Found $foundCount, need ${orderToDeliver.requiredCount}.",
      );
      // Optional: Show feedback to the user (e.g., SnackBar)
    }
  }

  // Tries to add *one* new random order if slots are available, using the current level.
  void _maybeAddNewOrder() {
    const int maxActiveOrders = 3;
    if (state.length < maxActiveOrders) {
      // Read the current level synchronously. This might be the old level if called
      // immediately after completion, but the listener handles level-up cases.
      final playerLevel = ref.read(playerStatsProvider).level;
      print(
        "[OrderNotifier] _maybeAddNewOrder: Trying to add. Current Level: $playerLevel",
      );
      final availableOrders = _getAvailableOrdersForLevel(playerLevel);
      print(
        "[OrderNotifier] _maybeAddNewOrder: Available for level $playerLevel (before filter): ${availableOrders.map((o) => o.id).toList()}",
      );
      final random = Random();

      // Remove orders already active to avoid duplicates
      final activeOrderIds = state.map((o) => o.id).toSet();
      availableOrders.removeWhere((o) => activeOrderIds.contains(o.id));
      print(
        "[OrderNotifier] _maybeAddNewOrder: Available for level $playerLevel (after filter): ${availableOrders.map((o) => o.id).toList()}",
      );

      if (availableOrders.isNotEmpty) {
        final randomIndex = random.nextInt(availableOrders.length);
        final newOrder = availableOrders[randomIndex];
        state = [...state, newOrder];
        print(
          "[OrderNotifier] _maybeAddNewOrder: Added new order ${newOrder.id} for level $playerLevel",
        );
      } else {
        print(
          "[OrderNotifier] _maybeAddNewOrder: No more unique orders available for level $playerLevel.",
        );
      }
    } else {
      print(
        "[OrderNotifier] _maybeAddNewOrder: Order slots full (${state.length}/$maxActiveOrders).",
      );
    }
  }

  // Fills empty order slots, typically called after a level up detected by the listener.
  void _fillOrderSlots() {
    const int maxActiveOrders = 3;
    int ordersToAdd = maxActiveOrders - state.length;
    print(
      "[OrderNotifier] _fillOrderSlots: Current orders: ${state.length}, Need to add: $ordersToAdd",
    );

    if (ordersToAdd <= 0) return; // No slots to fill

    final playerLevel =
        ref.read(playerStatsProvider).level; // Read the latest level
    print("[OrderNotifier] _fillOrderSlots: Filling for level $playerLevel");
    final availableOrders = _getAvailableOrdersForLevel(playerLevel);
    final random = Random();
    final activeOrderIds = state.map((o) => o.id).toSet();
    availableOrders.removeWhere((o) => activeOrderIds.contains(o.id));

    final List<Order> newlyAddedOrders = [];
    for (int i = 0; i < ordersToAdd && availableOrders.isNotEmpty; i++) {
      final randomIndex = random.nextInt(availableOrders.length);
      final newOrder = availableOrders.removeAt(
        randomIndex,
      ); // Remove to ensure uniqueness
      newlyAddedOrders.add(newOrder);
      print(
        "[OrderNotifier] _fillOrderSlots: Adding new order ${newOrder.id} for level $playerLevel",
      );
    }

    if (newlyAddedOrders.isNotEmpty) {
      state = [...state, ...newlyAddedOrders];
    } else {
      print(
        "[OrderNotifier] _fillOrderSlots: No more unique orders available for level $playerLevel.",
      );
    }
  }
}

// Update the provider definition to pass the ref
final orderProvider = StateNotifierProvider<OrderNotifier, List<Order>>((ref) {
  return OrderNotifier(ref); // Pass ref here
});
