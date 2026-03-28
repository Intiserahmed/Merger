// lib/widgets/game_grid/game_grid_orders.dart
import 'package:flutter/material.dart';
import 'package:flutter_fireworks/flutter_fireworks.dart';
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
        color: Colors.black.withValues(alpha: 0.2),
        child: const Center(
          child: Text(
            'No active orders.',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return Container(
      height: 88,
      color: Colors.black.withValues(alpha: 0.2),
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
      onTap: () {
        final success =
            ref.read(orderProvider.notifier).attemptDelivery(order);
        if (success) {
          showGeneralDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.transparent,
            pageBuilder: (ctx, _, __) =>
                _OrderCompleteDialog(coins: order.rewardCoins),
          );
        }
      },
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
            SizedBox(
              width: 32,
              height: 32,
              child: buildTileContent(order.requiredItemId, size: 26),
            ),
            Text(
              'x${order.requiredCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
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

// ── Order-complete popup ──────────────────────────────────────────────────────
// Owns its FireworksController and uses AnimationController (Ticker-based)
// for auto-dismiss — no raw Timer, safe when app is backgrounded.
class _OrderCompleteDialog extends StatefulWidget {
  final int coins;
  const _OrderCompleteDialog({required this.coins});

  @override
  State<_OrderCompleteDialog> createState() => _OrderCompleteDialogState();
}

class _OrderCompleteDialogState extends State<_OrderCompleteDialog>
    with SingleTickerProviderStateMixin {
  late final FireworksController _fireworks;
  late final AnimationController _countdown;

  @override
  void initState() {
    super.initState();
    _fireworks = FireworksController(
      colors: const [
        Color(0xFFFFD700),
        Color(0xFFFF8C00),
        Color(0xFF00C853),
        Color(0xFFFFFF00),
        Color(0xFFFF6F00),
      ],
      minExplosionDuration: 0.6,
      maxExplosionDuration: 2.2,
      minParticleCount: 90,
      maxParticleCount: 180,
      fadeOutDuration: 0.5,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fireworks.fireMultipleRockets(
          minRockets: 6,
          maxRockets: 14,
          launchWindow: const Duration(milliseconds: 700),
        );
      }
    });

    _countdown = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          Navigator.pop(context);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _countdown.dispose();
    _fireworks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.transparent,
        child: SizedBox.expand(
          child: Stack(
            children: [
              FireworksDisplay(controller: _fireworks),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade900,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.amber.shade400,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.45),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '✅  ORDER COMPLETE!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '+${widget.coins} 🪙',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Tap to continue',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
