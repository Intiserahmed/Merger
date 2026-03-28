// test/widget_test.dart
//
// Widget tests for GameGridScreen.
// Uses ProviderScope so the container is auto-disposed with the widget tree,
// which cancels the energy-regen Timer before the framework checks for leaks.
//
// Run with:  flutter test test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merger/providers/player_provider.dart';
import 'package:merger/providers/grid_provider.dart' as grid;
import 'package:merger/widgets/game_grid_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _app = ProviderScope(child: MaterialApp(home: GameGridScreen()));

/// Container from the live widget tree (auto-disposed when widget is torn down).
ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(GameGridScreen)));

/// Sets test viewport to a typical portrait phone (390×844 logical px).
void usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  // ─────────────────────────────────────────────────
  // 1. HUD RENDERING
  // ─────────────────────────────────────────────────
  group('HUD rendering', () {
    testWidgets('shows Level 1 label on first launch', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_app);
      await tester.pump();

      expect(find.textContaining('Level 1'), findsOneWidget);
    });

    testWidgets('shows starting energy 100/100', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_app);
      await tester.pump();

      expect(find.textContaining('100'), findsWidgets);
    });

    testWidgets('shows starting coins 50', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_app);
      await tester.pump();

      expect(find.textContaining('50'), findsWidgets);
    });

    testWidgets('order progress shows 0/3', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_app);
      await tester.pump();

      expect(find.textContaining('0/3'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────
  // 2. ORDER CARDS
  // ─────────────────────────────────────────────────
  group('Order cards', () {
    testWidgets('three GO buttons are visible', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_app);
      await tester.pump();

      expect(find.text('GO'), findsNWidgets(3));
    });

    testWidgets('GO button does nothing when grid has no items', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_app);
      await tester.pump();

      await tester.tap(find.text('GO').first);
      await tester.pump();

      expect(_container(tester).read(playerStatsProvider).completedOrders, 0);
    });
  });

  // ─────────────────────────────────────────────────
  // 3. GENERATOR INTERACTION
  // ─────────────────────────────────────────────────
  group('Generator taps', () {
    testWidgets('tapping Camp generator spends energy', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_app);
      await tester.pump();

      final energyBefore =
          _container(tester).read(playerStatsProvider).energy;

      await tester.tap(find.text('🏕️'));
      await tester.pump();

      expect(_container(tester).read(playerStatsProvider).energy,
          lessThan(energyBefore));
    });

    testWidgets('tapping Camp spawns an item on the grid', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_app);
      await tester.pump();

      await tester.tap(find.text('🏕️'));
      await tester.pump();

      final hasItem = _container(tester)
          .read(grid.gridProvider)
          .expand((row) => row)
          .any((tile) => tile.isItem);
      expect(hasItem, isTrue);
    });

    testWidgets('generator is on cooldown after tap', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_app);
      await tester.pump();

      await tester.tap(find.text('🏕️'));
      await tester.pump();

      expect(_container(tester).read(grid.gridProvider)[4][1].isReady, isFalse);
    });
  });

  // ─────────────────────────────────────────────────
  // 4. LEVEL-UP FLOW
  // Widget tests avoid pumping after the 3rd order because that opens the
  // fireworks dialog (flutter_fireworks uses non-cancellable internal timers).
  // The level-up logic itself is fully covered in game_mechanics_test.dart.
  // ─────────────────────────────────────────────────
  group('Level-up flow', () {
    testWidgets('HUD shows progress 1/3 after first order', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_app);
      await tester.pump();

      _container(tester).read(playerStatsProvider.notifier).orderCompleted();
      await tester.pump(); // 1 order — no level-up, no fireworks dialog

      expect(find.textContaining('1/3'), findsOneWidget);
    });

    testWidgets('HUD shows progress 2/3 after two orders', (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_app);
      await tester.pump();

      final n = _container(tester).read(playerStatsProvider.notifier);
      n.orderCompleted();
      n.orderCompleted();
      await tester.pump(); // 2 orders — still level 1, no dialog

      expect(find.textContaining('2/3'), findsOneWidget);
      expect(find.textContaining('Level 1'), findsOneWidget);
    });

    testWidgets('level reaches 2 after 3 orders (provider state, no pump)',
        (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_app);
      await tester.pump();

      final n = _container(tester).read(playerStatsProvider.notifier);
      n.orderCompleted();
      n.orderCompleted();
      n.orderCompleted(); // triggers level-up in provider synchronously

      // Verify via provider — no pump so the fireworks dialog never opens.
      expect(_container(tester).read(playerStatsProvider).level, 2);
    });

    testWidgets('spendEnergy between orders does NOT reset progress',
        (tester) async {
      usePhoneViewport(tester);
      await tester.pumpWidget(_app);
      await tester.pump();

      final n = _container(tester).read(playerStatsProvider.notifier);
      n.orderCompleted();
      n.spendEnergy(2); // regression: used to silently reset completedOrders
      n.orderCompleted();
      n.spendEnergy(2);
      await tester.pump(); // 2 orders — still level 1, no dialog

      expect(find.textContaining('2/3'), findsOneWidget);
    });
  });
}
