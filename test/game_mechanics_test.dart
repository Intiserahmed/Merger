// test/game_mechanics_test.dart
//
// Fast unit tests for core game mechanics — no device/emulator needed.
// Run with: flutter test test/game_mechanics_test.dart
//
// Coverage:
//  1. Merge Tree Logic  — pure function, no Riverpod
//  2. Player Stats      — energy, coins, XP, order progression, level-up
//  3. Grid Mechanics    — updateTile, mergeTiles (sequence + special), activateGenerator
//  4. Order System      — attemptDelivery success/failure, rewards, slot refill
//  5. Full Game Loop    — generate → merge → deliver → level-up

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:merger/models/merge_trees.dart';
import 'package:merger/models/tile_data.dart';
import 'package:merger/providers/grid_provider.dart';
import 'package:merger/providers/player_provider.dart';
import 'package:merger/providers/order_provider.dart';

// Helper — place an item tile at (row, col) without caring about base appearance
TileData item(int row, int col, String emoji) => TileData(
      row: row,
      col: col,
      type: TileType.item,
      baseImagePath: '🟫',
      itemImagePath: emoji,
    );

TileData empty(int row, int col) => TileData(
      row: row,
      col: col,
      type: TileType.empty,
      baseImagePath: '🟫',
    );

void main() {
  // AppLifecycleListener (used by PlayerStatsNotifier) requires WidgetsBinding.
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  // ─────────────────────────────────────────────────
  // 1. MERGE TREE LOGIC  (pure, no providers)
  // ─────────────────────────────────────────────────
  group('Merge Tree Logic', () {
    test('plant sequence: each level returns the next', () {
      expect(getNextItemInSequence('🌱'), '🌿');
      expect(getNextItemInSequence('🌿'), '🌳');
      expect(getNextItemInSequence('🌳'), '🌲');
    });

    test('plant sequence: max level returns null', () {
      expect(getNextItemInSequence('🌲'), isNull);
    });

    test('pebble sequence: each level returns the next', () {
      expect(getNextItemInSequence('🪨'), '🪵');
      expect(getNextItemInSequence('🪵'), '🐚');
      expect(getNextItemInSequence('🐚'), '🐌');
    });

    test('pebble sequence: max level returns null', () {
      expect(getNextItemInSequence('🐌'), isNull);
    });

    test('tool sequence: each level returns the next', () {
      expect(getNextItemInSequence('🔧'), '🔨');
      expect(getNextItemInSequence('🔨'), '🔩');
      expect(getNextItemInSequence('🔩'), '⚙️');
      expect(getNextItemInSequence('⚙️'), '🔗');
    });

    test('tool sequence: max level returns null', () {
      expect(getNextItemInSequence('🔗'), isNull);
    });

    test('unknown item returns null', () {
      expect(getNextItemInSequence('🏰'), isNull);
      expect(getNextItemInSequence('⭐'), isNull);
    });
  });

  // ─────────────────────────────────────────────────
  // 2. PLAYER STATS
  // ─────────────────────────────────────────────────
  group('Player Stats', () {
    late ProviderContainer c;
    setUp(() => c = ProviderContainer());
    tearDown(() => c.dispose());

    test('starts with correct defaults', () {
      final s = c.read(playerStatsProvider);
      expect(s.level, 1);
      expect(s.energy, 100);
      expect(s.maxEnergy, 100);
      expect(s.coins, 50);
      expect(s.gems, 20);
      expect(s.xp, 0);
      expect(s.completedOrders, 0);
      expect(s.ordersForNextLevel, 3);
    });

    test('spendEnergy: deducts correctly and returns true', () {
      final notifier = c.read(playerStatsProvider.notifier);
      expect(notifier.spendEnergy(5), isTrue);
      expect(c.read(playerStatsProvider).energy, 95);
    });

    test('spendEnergy: returns false when insufficient, energy unchanged', () {
      final notifier = c.read(playerStatsProvider.notifier);
      notifier.spendEnergy(100); // drain all
      expect(notifier.spendEnergy(1), isFalse);
      expect(c.read(playerStatsProvider).energy, 0);
    });

    test('addEnergy: caps at maxEnergy', () {
      c.read(playerStatsProvider.notifier).addEnergy(9999);
      expect(c.read(playerStatsProvider).energy, 100);
    });

    test('addCoins: increases balance', () {
      c.read(playerStatsProvider.notifier).addCoins(25);
      expect(c.read(playerStatsProvider).coins, 75);
    });

    test('spendCoins: deducts when sufficient', () {
      c.read(playerStatsProvider.notifier).spendCoins(20);
      expect(c.read(playerStatsProvider).coins, 30);
    });

    test('spendCoins: does nothing when insufficient', () {
      c.read(playerStatsProvider.notifier).spendCoins(9999);
      expect(c.read(playerStatsProvider).coins, 50); // unchanged
    });

    test('addXp: accumulates', () {
      final n = c.read(playerStatsProvider.notifier);
      n.addXp(10);
      n.addXp(5);
      expect(c.read(playerStatsProvider).xp, 15);
    });

    test('orderCompleted: increments counter', () {
      c.read(playerStatsProvider.notifier).orderCompleted();
      expect(c.read(playerStatsProvider).completedOrders, 1);
    });

    test('levelUp: bumps level and maxEnergy, refills energy', () {
      c.read(playerStatsProvider.notifier).levelUp();
      final s = c.read(playerStatsProvider);
      expect(s.level, 2);
      expect(s.maxEnergy, 110);
      expect(s.energy, 110);
    });

    test('orderCompleted: triggers level-up at the 3-order threshold', () {
      final n = c.read(playerStatsProvider.notifier);
      n.orderCompleted();
      n.orderCompleted();
      expect(c.read(playerStatsProvider).level, 1); // not yet
      n.orderCompleted(); // 3rd order hits the threshold
      expect(c.read(playerStatsProvider).level, 2);
    });

    test('spendEnergy: does NOT reset completedOrders (regression)', () {
      final n = c.read(playerStatsProvider.notifier);
      n.orderCompleted();
      n.orderCompleted();
      expect(c.read(playerStatsProvider).completedOrders, 2);
      // Spending energy must not wipe the order progress
      n.spendEnergy(2);
      expect(c.read(playerStatsProvider).completedOrders, 2);
      // Level-up should still fire on the 3rd order
      n.orderCompleted();
      expect(c.read(playerStatsProvider).level, 2);
    });
  });

  // ─────────────────────────────────────────────────
  // 3. GRID MECHANICS
  // ─────────────────────────────────────────────────
  group('Grid Mechanics', () {
    late ProviderContainer c;
    setUp(() {
      c = ProviderContainer();
      c.read(gridProvider); // initialise
    });
    tearDown(() => c.dispose());

    test('grid is 9 rows × 7 cols on startup', () {
      final g = c.read(gridProvider);
      expect(g.length, 9);
      expect(g[0].length, 7);
    });

    test('generators are at (4,1) Camp, (4,3) Mine, (4,5) Workshop', () {
      final g = c.read(gridProvider);
      expect(g[4][1].type, TileType.generator);
      expect(g[4][3].type, TileType.generator);
      expect(g[4][5].type, TileType.generator);
    });

    test('updateTile: places item on an unlocked tile', () {
      c.read(gridProvider.notifier).updateTile(0, 0, item(0, 0, '🌱'));
      expect(c.read(gridProvider)[0][0].itemImagePath, '🌱');
    });

    // ── Sequence merges ──────────────────────────────────────

    test('mergeTiles: 🌱 + 🌱 → 🌿, source becomes empty', () {
      final n = c.read(gridProvider.notifier);
      n.updateTile(0, 0, item(0, 0, '🌱'));
      n.updateTile(0, 1, item(0, 1, '🌱'));
      n.mergeTiles(0, 0, 0, 1); // target=(0,0), source=(0,1)
      final g = c.read(gridProvider);
      expect(g[0][0].itemImagePath, '🌿');
      expect(g[0][1].type, TileType.empty);
    });

    test('mergeTiles: 🪨 + 🪨 → 🪵 (pebble sequence)', () {
      final n = c.read(gridProvider.notifier);
      n.updateTile(0, 0, item(0, 0, '🪨'));
      n.updateTile(0, 1, item(0, 1, '🪨'));
      n.mergeTiles(0, 0, 0, 1);
      expect(c.read(gridProvider)[0][0].itemImagePath, '🪵');
    });

    test('mergeTiles: 🐚 + 🐚 → 🐌 (shell is in pebble sequence, not special)', () {
      final n = c.read(gridProvider.notifier);
      n.updateTile(0, 0, item(0, 0, '🐚'));
      n.updateTile(0, 1, item(0, 1, '🐚'));
      n.mergeTiles(0, 0, 0, 1);
      expect(c.read(gridProvider)[0][0].itemImagePath, '🐌');
    });

    test('mergeTiles: grants XP on successful merge', () {
      final n = c.read(gridProvider.notifier);
      final xpBefore = c.read(playerStatsProvider).xp;
      n.updateTile(0, 0, item(0, 0, '🌱'));
      n.updateTile(0, 1, item(0, 1, '🌱'));
      n.mergeTiles(0, 0, 0, 1);
      expect(c.read(playerStatsProvider).xp, greaterThan(xpBefore));
    });

    test('mergeTiles: different items — no merge, tiles unchanged', () {
      final n = c.read(gridProvider.notifier);
      n.updateTile(0, 0, item(0, 0, '🌱'));
      n.updateTile(0, 1, item(0, 1, '🪨'));
      n.mergeTiles(0, 0, 0, 1);
      final g = c.read(gridProvider);
      expect(g[0][0].itemImagePath, '🌱');
      expect(g[0][1].itemImagePath, '🪨');
    });

    test('mergeTiles: max-level items (🌲) — no merge', () {
      final n = c.read(gridProvider.notifier);
      n.updateTile(0, 0, item(0, 0, '🌲'));
      n.updateTile(0, 1, item(0, 1, '🌲'));
      n.mergeTiles(0, 0, 0, 1);
      final g = c.read(gridProvider);
      expect(g[0][0].itemImagePath, '🌲');
      expect(g[0][1].itemImagePath, '🌲');
    });

    // ── Special merges ───────────────────────────────────────

    test('mergeTiles: ⚔️ + ⚔️ → 🛡️ (special merge)', () {
      final n = c.read(gridProvider.notifier);
      n.updateTile(0, 0, item(0, 0, '⚔️'));
      n.updateTile(0, 1, item(0, 1, '⚔️'));
      n.mergeTiles(0, 0, 0, 1);
      final g = c.read(gridProvider);
      expect(g[0][0].itemImagePath, '🛡️');
      expect(g[0][1].type, TileType.empty);
    });

    // ── Generator activation ─────────────────────────────────

    test('activateGenerator: spawns item adjacent to Camp (4,1)', () {
      final n = c.read(gridProvider.notifier);
      // Ensure (3,1) is empty so Camp can spawn there
      n.updateTile(3, 1, empty(3, 1));
      n.activateGenerator(4, 1);

      final g = c.read(gridProvider);
      // Check the four neighbours; at least one should hold '🌱'
      final spawned = [
        g[3][1],
        g[5][1],
        g[4][0],
        g[4][2],
      ].any((t) => t.itemImagePath == '🌱');
      expect(spawned, isTrue);
    });

    test('activateGenerator: deducts energy (Camp costs 2)', () {
      final n = c.read(gridProvider.notifier);
      n.updateTile(3, 1, empty(3, 1));
      final energyBefore = c.read(playerStatsProvider).energy;
      n.activateGenerator(4, 1);
      expect(c.read(playerStatsProvider).energy, energyBefore - 2); // Camp energyCost = 2
    });

    test('activateGenerator: refunds energy when no adjacent empty tile', () {
      final n = c.read(gridProvider.notifier);
      // Block all four neighbours of Camp (4,1)
      n.updateTile(3, 1, item(3, 1, '🌱'));
      n.updateTile(5, 1, item(5, 1, '🌱'));
      n.updateTile(4, 0, item(4, 0, '🌱'));
      n.updateTile(4, 2, item(4, 2, '🌱'));

      final energyBefore = c.read(playerStatsProvider).energy;
      n.activateGenerator(4, 1);
      expect(c.read(playerStatsProvider).energy, energyBefore); // unchanged
    });
  });

  // ─────────────────────────────────────────────────
  // 4. ORDER SYSTEM
  // ─────────────────────────────────────────────────
  group('Order System', () {
    late ProviderContainer c;
    setUp(() {
      c = ProviderContainer();
      c.read(gridProvider);
      c.read(orderProvider);
    });
    tearDown(() => c.dispose());

    test('starts with 3 active orders at level 1', () {
      expect(c.read(orderProvider).length, 3);
    });

    test('attemptDelivery: grants coins when items present', () {
      final order = c.read(orderProvider).first;
      final gn = c.read(gridProvider.notifier);
      for (var i = 0; i < order.requiredCount; i++) {
        gn.updateTile(0, i, item(0, i, order.requiredItemId));
      }
      final coinsBefore = c.read(playerStatsProvider).coins;
      c.read(orderProvider.notifier).attemptDelivery(order);
      expect(
        c.read(playerStatsProvider).coins,
        coinsBefore + order.rewardCoins,
      );
    });

    test('attemptDelivery: increments completedOrders', () {
      final order = c.read(orderProvider).first;
      final gn = c.read(gridProvider.notifier);
      for (var i = 0; i < order.requiredCount; i++) {
        gn.updateTile(0, i, item(0, i, order.requiredItemId));
      }
      c.read(orderProvider.notifier).attemptDelivery(order);
      expect(c.read(playerStatsProvider).completedOrders, 1);
    });

    test('attemptDelivery: removes consumed items from the grid', () {
      final order = c.read(orderProvider).first;
      final gn = c.read(gridProvider.notifier);
      for (var i = 0; i < order.requiredCount; i++) {
        gn.updateTile(0, i, item(0, i, order.requiredItemId));
      }
      c.read(orderProvider.notifier).attemptDelivery(order);
      final g = c.read(gridProvider);
      int remaining = 0;
      for (var i = 0; i < order.requiredCount; i++) {
        if (g[0][i].itemImagePath == order.requiredItemId) remaining++;
      }
      expect(remaining, 0);
    });

    test('attemptDelivery: delivery confirmed + order slot refilled (≤3 orders)', () {
      final order = c.read(orderProvider).first;
      final gn = c.read(gridProvider.notifier);
      for (var i = 0; i < order.requiredCount; i++) {
        gn.updateTile(0, i, item(0, i, order.requiredItemId));
      }
      c.read(orderProvider.notifier).attemptDelivery(order);
      // Delivery confirmed by completedOrders increment
      expect(c.read(playerStatsProvider).completedOrders, 1);
      // Slot was either refilled or pool was empty — never exceeds max
      expect(c.read(orderProvider).length, lessThanOrEqualTo(3));
    });

    test('attemptDelivery: fails silently when items missing — no reward', () {
      final order = c.read(orderProvider).first;
      final coinsBefore = c.read(playerStatsProvider).coins;
      // Do NOT place items — attempt should fail
      c.read(orderProvider.notifier).attemptDelivery(order);
      expect(c.read(playerStatsProvider).coins, coinsBefore);
      expect(
        c.read(orderProvider).any((o) => o.id == order.id),
        isTrue, // order still active
      );
    });
  });

  // ─────────────────────────────────────────────────
  // 5. FULL GAME LOOP
  // ─────────────────────────────────────────────────
  group('Full Game Loop', () {
    late ProviderContainer c;
    setUp(() {
      c = ProviderContainer();
      c.read(gridProvider);
      c.read(orderProvider);
    });
    tearDown(() => c.dispose());

    test('complete plant sequence: 🌱 → 🌿 → 🌳 → 🌲 (max), then no merge', () {
      final n = c.read(gridProvider.notifier);

      n.updateTile(0, 0, item(0, 0, '🌱'));
      n.updateTile(0, 1, item(0, 1, '🌱'));
      n.mergeTiles(0, 0, 0, 1);
      expect(c.read(gridProvider)[0][0].itemImagePath, '🌿');

      n.updateTile(0, 1, item(0, 1, '🌿'));
      n.mergeTiles(0, 0, 0, 1);
      expect(c.read(gridProvider)[0][0].itemImagePath, '🌳');

      n.updateTile(0, 1, item(0, 1, '🌳'));
      n.mergeTiles(0, 0, 0, 1);
      expect(c.read(gridProvider)[0][0].itemImagePath, '🌲');

      // Max level — merge has no effect
      n.updateTile(0, 1, item(0, 1, '🌲'));
      n.mergeTiles(0, 0, 0, 1);
      expect(c.read(gridProvider)[0][0].itemImagePath, '🌲');
      expect(c.read(gridProvider)[0][1].itemImagePath, '🌲');
    });

    test('complete pebble sequence: 🪨 → 🪵 → 🐚 → 🐌 (max)', () {
      final n = c.read(gridProvider.notifier);

      n.updateTile(0, 0, item(0, 0, '🪨'));
      n.updateTile(0, 1, item(0, 1, '🪨'));
      n.mergeTiles(0, 0, 0, 1);
      expect(c.read(gridProvider)[0][0].itemImagePath, '🪵');

      n.updateTile(0, 1, item(0, 1, '🪵'));
      n.mergeTiles(0, 0, 0, 1);
      expect(c.read(gridProvider)[0][0].itemImagePath, '🐚');

      n.updateTile(0, 1, item(0, 1, '🐚'));
      n.mergeTiles(0, 0, 0, 1);
      expect(c.read(gridProvider)[0][0].itemImagePath, '🐌');
    });

    test('completing 3 orders in a row triggers level-up to 2', () {
      final gn = c.read(gridProvider.notifier);
      final on = c.read(orderProvider.notifier);

      for (int round = 0; round < 3; round++) {
        final order = c.read(orderProvider).first;
        for (var i = 0; i < order.requiredCount; i++) {
          gn.updateTile(0, i, item(0, i, order.requiredItemId));
        }
        on.attemptDelivery(order);
      }

      expect(c.read(playerStatsProvider).level, 2);
      expect(c.read(playerStatsProvider).maxEnergy, 110);
    });

    test('generator → merge → deliver: full single-cycle test', () {
      final gn = c.read(gridProvider.notifier);
      final on = c.read(orderProvider.notifier);

      // Step 1: activate Camp to spawn first 🌱
      gn.updateTile(3, 1, empty(3, 1));
      gn.activateGenerator(4, 1);

      // Step 2: manually place a second 🌱 and merge
      gn.updateTile(0, 0, item(0, 0, '🌱'));
      gn.updateTile(0, 1, item(0, 1, '🌱'));
      gn.mergeTiles(0, 0, 0, 1);
      expect(c.read(gridProvider)[0][0].itemImagePath, '🌿');

      // Step 3: deliver whatever order we have (using manual item placement)
      final order = c.read(orderProvider).first;
      for (var i = 0; i < order.requiredCount; i++) {
        gn.updateTile(1, i, item(1, i, order.requiredItemId));
      }
      final coinsBefore = c.read(playerStatsProvider).coins;
      on.attemptDelivery(order);

      expect(c.read(playerStatsProvider).coins, greaterThan(coinsBefore));
      expect(c.read(playerStatsProvider).completedOrders, 1);
    });
  });
}
