// lib/debug/debug_panel.dart
//
// ⚠️  DEBUG ONLY — never ships to prod.
//
// To ship: delete the entire lib/debug/ folder.
// To verify it's gone: `grep -r "debug_panel" lib/` should return nothing.
//
// Usage in game_grid_screen.dart:
//   import 'package:merger/debug/debug_panel.dart';
//   if (kDebugMode) DebugFab(context)   ← inside floatingActionButton Row

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../providers/grid_provider.dart' as grid;
import '../providers/order_provider.dart';
import '../models/tile_data.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

/// Drop this inside your floatingActionButton wrapped in `if (kDebugMode)`.
Widget debugFab(BuildContext context, WidgetRef ref) {
  assert(() {
    // Will crash in release mode if somehow called — belt-and-suspenders.
    return true;
  }());
  return FloatingActionButton(
    heroTag: 'debugFab',
    backgroundColor: Colors.red.shade700,
    mini: true,
    tooltip: 'Debug Panel',
    onPressed: () => _showDebugPanel(context, ref),
    child: const Icon(Icons.bug_report, size: 18),
  );
}

// ── Panel ─────────────────────────────────────────────────────────────────────

void _showDebugPanel(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1A1A2E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _DebugSheet(ref: ref),
  );
}

class _DebugSheet extends StatelessWidget {
  final WidgetRef ref;
  const _DebugSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🐛 Debug Panel',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'kDebugMode only — delete lib/debug/ before shipping',
            style: TextStyle(color: Colors.red.shade300, fontSize: 11),
          ),
          const SizedBox(height: 16),
          _section('Player', [
            _btn('+1000 coins',  Icons.monetization_on, () => ref.read(playerStatsProvider.notifier).addCoins(1000)),
            _btn('+50 energy',   Icons.bolt,            () => ref.read(playerStatsProvider.notifier).addEnergy(50)),
            _btn('Level up',     Icons.arrow_upward,    () => ref.read(playerStatsProvider.notifier).debugLevelUp()),
            _btn('+20 gems',     Icons.diamond,         () => ref.read(playerStatsProvider.notifier).addGems(20)),
          ]),
          const SizedBox(height: 12),
          _section('Grid', [
            _btn('Fill grid',    Icons.grid_on,         () => _fillGrid(ref)),
            _btn('Clear items',  Icons.clear_all,       () => _clearGrid(ref)),
            _btn('0s cooldowns', Icons.timer_off,       () => _zeroCooldowns(ref)),
          ]),
          const SizedBox(height: 12),
          _section('Orders', [
            _btn('Complete first order', Icons.check_circle, () => _completeFirstOrder(ref)),
            _btn('Refresh orders',       Icons.refresh,      () => ref.read(orderProvider.notifier).refreshOrders()),
          ]),
          const SizedBox(height: 12),
          _btn('🔴 Reset game', Icons.delete_forever, () {
            ref.read(playerStatsProvider.notifier).debugReset();
            ref.read(grid.gridProvider.notifier).debugReset();
            Navigator.pop(context);
          }, color: Colors.red.shade800, fullWidth: true),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _section(String label, List<Widget> buttons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: buttons),
      ],
    );
  }

  Widget _btn(String label, IconData icon, VoidCallback onTap,
      {Color? color, bool fullWidth = false}) {
    final btn = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? const Color(0xFF2E2E4E),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
      onPressed: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      icon: Icon(icon, size: 14),
      label: Text(label),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }

  // ── Grid helpers ────────────────────────────────────────────────────────────

  void _fillGrid(WidgetRef ref) {
    const items = ['🌱', '🌿', '🌳', '🔧', '🔨', '🪨', '🪵'];
    ref.read(grid.gridProvider.notifier).debugFillGrid(items);
  }

  void _clearGrid(WidgetRef ref) {
    ref.read(grid.gridProvider.notifier).debugClearItems();
  }

  void _zeroCooldowns(WidgetRef ref) {
    ref.read(grid.gridProvider.notifier).debugZeroCooldowns();
  }

  void _completeFirstOrder(WidgetRef ref) {
    final orders = ref.read(orderProvider);
    if (orders.isNotEmpty) {
      ref.read(orderProvider.notifier).debugCompleteOrder(orders.first.id);
    }
  }
}
