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
    Order(id: 'lvl1_plant_1',   requiredItemId: '🌱', requiredCount: 2,  rewardCoins: 10,  rewardXp: 5),
    Order(id: 'lvl1_plant_2',   requiredItemId: '🌱', requiredCount: 3,  rewardCoins: 15,  rewardXp: 7),
    Order(id: 'lvl1_pebble_1',  requiredItemId: '🪨', requiredCount: 2,  rewardCoins: 10,  rewardXp: 5),
  ],
  2: [
    Order(id: 'lvl2_plant_1',   requiredItemId: '🌿', requiredCount: 1,  rewardCoins: 25,  rewardXp: 12),
    Order(id: 'lvl2_pebble_1',  requiredItemId: '🪵', requiredCount: 1,  rewardCoins: 25,  rewardXp: 12),
    Order(id: 'lvl2_tool_1',    requiredItemId: '🔧', requiredCount: 2,  rewardCoins: 30,  rewardXp: 15),
    Order(id: 'lvl2_plant_many',requiredItemId: '🌱', requiredCount: 4,  rewardCoins: 20,  rewardXp: 10),
  ],
  3: [
    Order(id: 'lvl3_plant_1',   requiredItemId: '🌳', requiredCount: 1,  rewardCoins: 50,  rewardXp: 25),
    Order(id: 'lvl3_pebble_1',  requiredItemId: '🐚', requiredCount: 1,  rewardCoins: 50,  rewardXp: 25),
    Order(id: 'lvl3_tool_1',    requiredItemId: '🔩', requiredCount: 1,  rewardCoins: 60,  rewardXp: 30),
    Order(id: 'lvl3_plant_2',   requiredItemId: '🌿', requiredCount: 2,  rewardCoins: 45,  rewardXp: 20),
  ],
  4: [
    Order(id: 'lvl4_plant_1',   requiredItemId: '🌲', requiredCount: 1,  rewardCoins: 100, rewardXp: 50),
    Order(id: 'lvl4_pebble_1',  requiredItemId: '🐌', requiredCount: 1,  rewardCoins: 100, rewardXp: 50),
    Order(id: 'lvl4_tool_1',    requiredItemId: '⚙️', requiredCount: 1,  rewardCoins: 120, rewardXp: 60),
    Order(id: 'lvl4_gem_intro', requiredItemId: '💎', requiredCount: 2,  rewardCoins: 80,  rewardXp: 40),
    Order(id: 'lvl4_plant_2',   requiredItemId: '🌿', requiredCount: 3,  rewardCoins: 65,  rewardXp: 32),
  ],
  5: [
    Order(id: 'lvl5_gem_1',     requiredItemId: '🔮', requiredCount: 1,  rewardCoins: 220, rewardXp: 110),
    Order(id: 'lvl5_tool_1',    requiredItemId: '🔗', requiredCount: 1,  rewardCoins: 200, rewardXp: 100),
    Order(id: 'lvl5_plant_1',   requiredItemId: '🌲', requiredCount: 2,  rewardCoins: 180, rewardXp: 90),
    Order(id: 'lvl5_pebble_1',  requiredItemId: '🐌', requiredCount: 2,  rewardCoins: 180, rewardXp: 90),
    Order(id: 'lvl5_gem_2',     requiredItemId: '💎', requiredCount: 2,  rewardCoins: 150, rewardXp: 75),
  ],
  6: [
    Order(id: 'lvl6_food_intro',requiredItemId: '🌾', requiredCount: 3,  rewardCoins: 60,  rewardXp: 30),
    Order(id: 'lvl6_plant_1',   requiredItemId: '🌴', requiredCount: 1,  rewardCoins: 250, rewardXp: 125),
    Order(id: 'lvl6_pebble_1',  requiredItemId: '🦋', requiredCount: 1,  rewardCoins: 250, rewardXp: 125),
    Order(id: 'lvl6_tool_1',    requiredItemId: '🔗', requiredCount: 1,  rewardCoins: 200, rewardXp: 100),
    Order(id: 'lvl6_gem_1',     requiredItemId: '✨', requiredCount: 1,  rewardCoins: 300, rewardXp: 150),
  ],
  7: [
    Order(id: 'lvl7_food_1',    requiredItemId: '🍞', requiredCount: 2,  rewardCoins: 120, rewardXp: 60),
    Order(id: 'lvl7_food_many', requiredItemId: '🌾', requiredCount: 4,  rewardCoins: 80,  rewardXp: 40),
    Order(id: 'lvl7_gem_1',     requiredItemId: '✨', requiredCount: 1,  rewardCoins: 300, rewardXp: 150),
    Order(id: 'lvl7_pebble_1',  requiredItemId: '🌸', requiredCount: 1,  rewardCoins: 350, rewardXp: 175),
    Order(id: 'lvl7_plant_1',   requiredItemId: '🌲', requiredCount: 2,  rewardCoins: 180, rewardXp: 90),
  ],
  8: [
    Order(id: 'lvl8_magic_intro',requiredItemId: '⚗️', requiredCount: 2, rewardCoins: 80,  rewardXp: 40),
    Order(id: 'lvl8_food_1',    requiredItemId: '🥐', requiredCount: 1,  rewardCoins: 180, rewardXp: 90),
    Order(id: 'lvl8_gem_1',     requiredItemId: '🌟', requiredCount: 1,  rewardCoins: 400, rewardXp: 200),
    Order(id: 'lvl8_plant_1',   requiredItemId: '🎋', requiredCount: 1,  rewardCoins: 450, rewardXp: 225),
    Order(id: 'lvl8_pebble_1',  requiredItemId: '🌸', requiredCount: 1,  rewardCoins: 350, rewardXp: 175),
  ],
  9: [
    Order(id: 'lvl9_magic_1',   requiredItemId: '🧪', requiredCount: 2,  rewardCoins: 200, rewardXp: 100),
    Order(id: 'lvl9_magic_2',   requiredItemId: '🔯', requiredCount: 1,  rewardCoins: 300, rewardXp: 150),
    Order(id: 'lvl9_food_1',    requiredItemId: '🥐', requiredCount: 2,  rewardCoins: 350, rewardXp: 175),
    Order(id: 'lvl9_plant_1',   requiredItemId: '🌴', requiredCount: 2,  rewardCoins: 500, rewardXp: 250),
    Order(id: 'lvl9_tool_1',    requiredItemId: '⚒️', requiredCount: 1,  rewardCoins: 550, rewardXp: 275),
  ],
  10: [
    Order(id: 'lvl10_magic_1',  requiredItemId: '🌈', requiredCount: 1,  rewardCoins: 800, rewardXp: 400),
    Order(id: 'lvl10_food_1',   requiredItemId: '🎁', requiredCount: 1,  rewardCoins: 700, rewardXp: 350),
    Order(id: 'lvl10_gem_1',    requiredItemId: '👑', requiredCount: 1,  rewardCoins: 900, rewardXp: 450),
    Order(id: 'lvl10_plant_1',  requiredItemId: '🎋', requiredCount: 1,  rewardCoins: 450, rewardXp: 225),
    Order(id: 'lvl10_pebble_1', requiredItemId: '🌸', requiredCount: 1,  rewardCoins: 350, rewardXp: 175),
    Order(id: 'lvl10_tool_1',   requiredItemId: '⚒️', requiredCount: 1,  rewardCoins: 550, rewardXp: 275),
  ],
};

class OrderNotifier extends StateNotifier<List<Order>> {
  final Ref ref;
  final _random = Random();

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

  void _assertValidState() {
    assert(state.length <= 3,
        'Order slots exceeded max (3): ${state.length} active');
    assert(
      state.map((o) => o.id).toSet().length == state.length,
      'Duplicate order IDs in active state: ${state.map((o) => o.id).toList()}',
    );
    assert(
      state.every((o) => o.requiredCount > 0),
      'Order with zero or negative requiredCount found',
    );
    assert(
      state.every((o) => o.rewardCoins >= 0),
      'Order with negative rewardCoins found',
    );
  }

  // Generate initial orders based on the player's current level
  void _generateInitialOrders(int count) {
    final playerLevel = ref.read(playerStatsProvider).level;
    final availableOrders = _getAvailableOrdersForLevel(playerLevel);
    final initialOrders = <Order>[];

    for (int i = 0; i < count && availableOrders.isNotEmpty; i++) {
      final randomIndex = _random.nextInt(availableOrders.length);
      initialOrders.add(availableOrders.removeAt(randomIndex));
    }
    state = initialOrders;
    _assertValidState();
  }

  // Fix 4: Cumulative pool — level 3 includes level 1+2+3 orders.
  // Fix 1: No dedup against completed orders — same order can reappear after delivery.
  //        Only excludes orders currently active (no duplicate simultaneous slots).
  List<Order> _getAvailableOrdersForLevel(int playerLevel) {
    assert(playerLevel >= 1, 'Invalid playerLevel: $playerLevel');
    // Clamp to the highest defined level so adding player levels without
    // updating _ordersByLevel degrades gracefully instead of crashing.
    final maxDefinedLevel = _ordersByLevel.keys.reduce((a, b) => a > b ? a : b);
    final effectiveLevel = playerLevel.clamp(1, maxDefinedLevel);
    assert(
      effectiveLevel == playerLevel,
      'No orders defined for level $playerLevel — add entries to _ordersByLevel. '
      'Falling back to level $maxDefinedLevel pool.',
    );
    final pool = <Order>[];
    for (int lvl = 1; lvl <= effectiveLevel; lvl++) {
      pool.addAll(_ordersByLevel[lvl] ?? []);
    }
    assert(pool.isNotEmpty, 'Cumulative order pool is empty for level $effectiveLevel');
    return pool;
  }

  /// Attempts to deliver items for a specific order.
  /// Checks the grid for required items and consumes them if found.
  /// Grants rewards and replaces the order if successful.
  bool attemptDelivery(Order orderToDeliver) {
    final gridState = ref.read(gridProvider);
    final gridNotifier = ref.read(gridProvider.notifier);
    final playerNotifier = ref.read(playerStatsProvider.notifier);

    // ── Phase 1: VALIDATE — read-only, no mutations ───────────────────────────

    // Collect locations of required items
    final itemLocations = <Point<int>>[];
    for (int r = 0; r < gridState.length; r++) {
      for (int c = 0; c < gridState[r].length; c++) {
        if (gridState[r][c].itemImagePath == orderToDeliver.requiredItemId) {
          itemLocations.add(Point(r, c));
        }
      }
    }

    if (itemLocations.length < orderToDeliver.requiredCount) {
      print("Not enough items for order '${orderToDeliver.id}'. "
          "Found ${itemLocations.length}, need ${orderToDeliver.requiredCount}.");
      return false;
    }

    // ── Phase 2: EXECUTE — all mutations run only after validation passes ─────

    // 2a. Consume items — preserve each tile's original base colour
    final toConsume = itemLocations.take(orderToDeliver.requiredCount);
    for (final loc in toConsume) {
      final original = gridState[loc.x][loc.y];
      gridNotifier.updateTile(
        loc.x, loc.y,
        TileData(
          row: loc.x,
          col: loc.y,
          baseImagePath: original.baseImagePath, // fix: keep base, not hardcoded 🟫
        ),
      );
    }

    // 2b. Grant rewards
    playerNotifier.addCoins(orderToDeliver.rewardCoins);
    print("Order '${orderToDeliver.id}' delivered! Rewarded ${orderToDeliver.rewardCoins} coins.");

    // 2c. Remove completed order
    state = state.where((o) => o.id != orderToDeliver.id).toList();
    _assertValidState();

    // 2d. Fill slot at CURRENT level — before orderCompleted() which may level up
    _maybeAddNewOrder();
    _assertValidState();

    // 2e. Notify player last — may trigger level-up, banner shows after orders updated
    playerNotifier.orderCompleted();
    return true;
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
      // Remove orders already active to avoid duplicates
      final activeOrderIds = state.map((o) => o.id).toSet();
      availableOrders.removeWhere((o) => activeOrderIds.contains(o.id));
      print(
        "[OrderNotifier] _maybeAddNewOrder: Available for level $playerLevel (after filter): ${availableOrders.map((o) => o.id).toList()}",
      );

      if (availableOrders.isNotEmpty) {
        final randomIndex = _random.nextInt(availableOrders.length);
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

  // On level-up: keeps existing orders and fills empty slots with
  // orders from the now-expanded cumulative pool.
  void _fillOrderSlots() {
    const int maxActiveOrders = 3;
    final playerLevel = ref.read(playerStatsProvider).level;
    print("[OrderNotifier] _fillOrderSlots: Filling slots for level $playerLevel");

    while (state.length < maxActiveOrders) {
      final pool = _getAvailableOrdersForLevel(playerLevel);
      final activeIds = state.map((o) => o.id).toSet();
      pool.removeWhere((o) => activeIds.contains(o.id));
      if (pool.isEmpty) break;
      final pick = pool[_random.nextInt(pool.length)];
      state = [...state, pick];
      print("[OrderNotifier] _fillOrderSlots: Added ${pick.id}");
    }
    _assertValidState();
  }

  // ── Debug helpers (never call from prod code) ──────────────────────────────

  void refreshOrders() => _fillOrderSlots();

  void debugCompleteOrder(String orderId) {
    state = state.where((o) => o.id != orderId).toList();
    ref.read(playerStatsProvider.notifier).addCoins(100);
    _maybeAddNewOrder();
  }
}

// Update the provider definition to pass the ref
final orderProvider = StateNotifierProvider<OrderNotifier, List<Order>>((ref) {
  return OrderNotifier(ref); // Pass ref here
});
