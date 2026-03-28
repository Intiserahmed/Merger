import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fireworks/flutter_fireworks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merger/how_to.dart';
import 'package:merger/main.dart';
import 'package:merger/models/order.dart';
import 'package:merger/providers/order_provider.dart';
import 'package:merger/models/tile_unlock.dart';
import 'package:merger/providers/expansion_provider.dart';
import 'package:merger/persistence/game_service.dart';
import 'package:merger/widgets/info_popup.dart';

import '../models/tile_data.dart';
import '../providers/grid_provider.dart' as grid;
import '../providers/player_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/merge_trees.dart';
import '../models/generator_config.dart';

// ── Tile colours ────────────────────────────────────────────────────────────
final Color _lightBrown = Colors.brown[300]!;
final Color _darkBrown = Colors.brown[600]!;
final Color _grassGreen = Colors.green[400]!;

// Show tutorial once per session
final _tutorialShownProvider = StateProvider<bool>((ref) => false);

// ── Screen widget ────────────────────────────────────────────────────────────
class GameGridScreen extends ConsumerStatefulWidget {
  const GameGridScreen({super.key});

  @override
  ConsumerState<GameGridScreen> createState() => _GameGridScreenState();
}

class _GameGridScreenState extends ConsumerState<GameGridScreen> {
  TileData? _selectedTile;
  Timer? _tutorialTimer;

  // Stores the reward of the order that is currently being delivered,
  // so the order-complete popup can display the right amount.
  int _pendingOrderReward = 0;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // Show tutorial on first visit this session (delayed so grid is visible first)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(_tutorialShownProvider)) {
        ref.read(_tutorialShownProvider.notifier).state = true;
        _tutorialTimer =
            Timer(const Duration(milliseconds: 600), _showTutorial);
      }
    });
  }

  @override
  void dispose() {
    _tutorialTimer?.cancel();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _showTutorial() {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const HowToProgressOverlay(),
      ),
    );
  }

  void _autoSave() {
    try {
      GameService(isar, ProviderScope.containerOf(context)).saveGame();
    } catch (_) {
      // isar may not be initialised in widget-test environments
    }
  }

  // Renders a string as an emoji Text or an asset Image.
  Widget _tileContent(String pathOrEmoji, {double size = 28}) {
    if (pathOrEmoji.contains('/')) {
      return Image.asset(
        pathOrEmoji,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.error_outline, color: Colors.red.shade300, size: size),
      );
    }
    return Text(pathOrEmoji, style: TextStyle(fontSize: size));
  }

  // ── Order-complete popup ───────────────────────────────────────────────────
  void _showOrderCompletePopup(int coins) {
    if (!mounted) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, _, __) => _OrderCompleteDialog(coins: coins),
    );
  }

  // ── Level-up dialog ────────────────────────────────────────────────────────
  void _showLevelUpDialog(int newLevel) {
    if (!mounted) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, _, __) => _LevelUpDialog(newLevel: newLevel),
    );
  }

  // ── HUD ────────────────────────────────────────────────────────────────────
  Widget _buildTopArea() {
    final s = ref.watch(playerStatsProvider);
    final progress = s.ordersForNextLevel > 0
        ? (s.completedOrders / s.ordersForNextLevel).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 10,
        top: MediaQuery.of(context).padding.top + 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade700],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar + level
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white24,
                    radius: 18,
                    child: Text('👤', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level ${s.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${s.completedOrders}/${s.ordersForNextLevel} orders',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      _resourceChip('⚡', '${s.energy}/${s.maxEnergy}',
                          Colors.blue.shade300),
                      const SizedBox(width: 4),
                      _resourceChip('🪙', '${s.coins}', Colors.amber),
                      const SizedBox(width: 4),
                      _resourceChip('💎', '${s.gems}', Colors.cyanAccent),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          // Progress bar toward next level
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.amber.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resourceChip(String icon, String value, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha:0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Orders panel ───────────────────────────────────────────────────────────
  Widget _buildOrderDisplay() {
    final orders = ref.watch(orderProvider);

    return Container(
      height: 106,
      color: Colors.black.withValues(alpha:0.35),
      child: orders.isEmpty
          ? const Center(
              child: Text(
                'All orders fulfilled! New ones coming soon…',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              itemCount: orders.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildOrderCard(orders[i]),
              ),
            ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      width: 118,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade800, Colors.brown.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Colors.amber.shade600, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black38,
              blurRadius: 4,
              offset: const Offset(1, 2))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Item + count badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(order.requiredItemId,
                  style: const TextStyle(fontSize: 26)),
              if (order.requiredCount > 1) ...[
                const SizedBox(width: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'x${order.requiredCount}',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          // Reward
          Text(
            '+${order.rewardCoins} 🪙',
            style: TextStyle(
                color: Colors.amber.shade300,
                fontSize: 11,
                fontWeight: FontWeight.bold),
          ),
          // GO button
          SizedBox(
            width: double.infinity,
            height: 24,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)),
                elevation: 2,
              ),
              onPressed: () {
                _pendingOrderReward = order.rewardCoins;
                ref
                    .read(orderProvider.notifier)
                    .attemptDelivery(order);
              },
              child: const Text('GO',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid tile ──────────────────────────────────────────────────────────────
  Widget _buildTile(int index) {
    final row = index ~/ grid.colCount;
    final col = index % grid.colCount;
    final gridData = ref.watch(grid.gridProvider);

    if (row >= gridData.length || col >= gridData[0].length) {
      return Container(color: Colors.red.withValues(alpha:0.2));
    }
    final tileData = gridData[row][col];

    Color bg;
    if (tileData.baseImagePath == '🟩') {
      bg = _grassGreen;
    } else if (tileData.isLocked) {
      bg = Colors.grey.shade600;
    } else {
      bg = (row + col) % 2 == 0 ? _lightBrown : _darkBrown;
    }

    Widget tileWidget = Container(
      key: ValueKey(
          'tile_${row}_${col}_${tileData.type}_${tileData.itemImagePath}'),
      margin: const EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: Colors.black.withValues(alpha:0.2), width: 0.5),
        boxShadow: tileData.isItem
            ? [
                BoxShadow(
                    color: Colors.black.withValues(alpha:0.3),
                    blurRadius: 3,
                    offset: const Offset(1, 1))
              ]
            : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          // Base (generator / locked icon)
          if (tileData.isGenerator || tileData.isLocked)
            Center(
              child: _tileContent(tileData.baseImagePath, size: 30),
            ),

          // Item layer — AnimatedSwitcher gives a pop-in whenever the emoji changes
          if (tileData.itemImagePath != null)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, animation) {
                final scale = Tween(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                      parent: animation, curve: Curves.elasticOut),
                );
                return ScaleTransition(
                  scale: scale,
                  child:
                      FadeTransition(opacity: animation, child: child),
                );
              },
              // Key change (emoji change) triggers the animation
              child: Center(
                key: ValueKey(
                    'item_${row}_${col}_${tileData.itemImagePath}'),
                child:
                    _tileContent(tileData.itemImagePath!, size: 28),
              ),
            ),

          // Cooldown overlay on generator
          if (tileData.isGenerator && !tileData.isReady)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha:0.62),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '${tileData.remainingCooldown.inSeconds}s',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          // DragTarget highlight when a compatible item hovers over
        ],
      ),
    );

    tileWidget = SizedBox(width: 50, height: 50, child: tileWidget);

    // ── Draggable items ──────────────────────────────────────────────────
    if (tileData.isItem) {
      return DragTarget<TileDropData>(
        onWillAcceptWithDetails: (details) {
          final dragData = details.data;
          if (dragData.row == row && dragData.col == col) return false;
          if (tileData.isLocked) return false;
          if (tileData.itemImagePath != null &&
              tileData.itemImagePath == dragData.tileData.itemImagePath) {
            final next = getNextItemInSequence(tileData.itemImagePath!);
            if (next != null) return true;
            if (tileData.itemImagePath == '🐚' ||
                tileData.itemImagePath == '⚔️') {
              return true;
            }
          }
          return false;
        },
        onAcceptWithDetails: (details) {
          final dragData = details.data;
          ref
              .read(grid.gridProvider.notifier)
              .mergeTiles(row, col, dragData.row, dragData.col);
        },
        builder: (_, candidates, __) {
          // Glow when a valid item is hovering
          final hovering = candidates.isNotEmpty;
          return Draggable<TileDropData>(
            data: TileDropData(row: row, col: col, tileData: tileData),
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 48,
                height: 48,
                child: _tileContent(tileData.itemImagePath!, size: 38),
              ),
            ),
            childWhenDragging: SizedBox(
              width: 50,
              height: 50,
              child: Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: Colors.black.withValues(alpha:0.2), width: 0.5),
                ),
                child: tileData.isGenerator
                    ? Center(
                        child:
                            _tileContent(tileData.baseImagePath, size: 30))
                    : null,
              ),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: hovering
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                            color:
                                Colors.greenAccent.withValues(alpha:0.7),
                            blurRadius: 12,
                            spreadRadius: 2),
                      ],
                    )
                  : null,
              child: tileWidget,
            ),
          );
        },
      );
    }

    // ── Tappable tiles (generators, locked, empty) ───────────────────────
    return DragTarget<TileDropData>(
      onWillAcceptWithDetails: (_) => false,
      builder: (_, __, ___) => GestureDetector(
        onTap: () {
          setState(() {
            _selectedTile =
                (_selectedTile == tileData) ? null : tileData;
          });

          if (tileData.isLocked) {
            _handleLockedTileTap(row, col);
          } else if (tileData.isGenerator) {
            ref
                .read(grid.gridProvider.notifier)
                .activateGenerator(row, col);
          }
        },
        child: tileWidget,
      ),
    );
  }

  void _handleLockedTileTap(int row, int col) {
    final available = ref.read(availableUnlocksProvider);
    TileUnlock? target;
    for (final u in available) {
      if (u.coveredTiles.any((p) => p.row == row && p.col == col)) {
        target = u;
        break;
      }
    }

    if (target != null) {
      final ok = ref.read(playerStatsProvider.notifier).unlockZone(target);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? "Zone '${target.id}' unlocked! 🎉"
            : "Requires level ${target.requiredLevel} & ${target.unlockCostCoins} 🪙"),
        duration: const Duration(seconds: 2),
      ));
    } else {
      final all = ref.read(allUnlocksProvider);
      final zone = all.firstWhere(
        (u) => u.coveredTiles.any((p) => p.row == row && p.col == col),
        orElse: () => TileUnlock(id: 'unknown', requiredLevel: 99),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('🔒 Requires Level ${zone.requiredLevel}'),
        duration: const Duration(seconds: 1),
      ));
    }
  }

  // ── Bottom info bar ────────────────────────────────────────────────────────
  Widget _buildBottomInfoBar() {
    Widget helpButton = IconButton(
      icon: const Icon(Icons.help_outline, size: 20),
      color: Colors.white54,
      onPressed: _showTutorial,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      tooltip: 'How to play',
    );

    if (_selectedTile == null || _selectedTile!.isLocked) {
      return Container(
        height: 46,
        color: Colors.grey.shade900,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.touch_app, color: Colors.white38, size: 16),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Tap a generator to spawn items. Drag to merge.',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
            helpButton,
          ],
        ),
      );
    }

    final t = _selectedTile!;
    final emoji = t.itemImagePath;
    final mergeItem = emoji != null ? mergeItemsByEmoji[emoji] : null;
    final genCfg = generatorConfigs[t.baseImagePath];

    String infoText;
    Widget? popup;

    if (t.isGenerator && genCfg != null) {
      infoText =
          'Generator · produces ${t.generatesItemPath ?? '??'} · '
          'costs ${t.energyCost}⚡';
      popup = InfoPopup(
          generatorEmoji: t.baseImagePath, generatorConfig: genCfg);
    } else if (mergeItem != null) {
      infoText =
          '${mergeItem.id.replaceAll('_', ' ')} (Lv ${mergeItem.level}) · '
          'merge to level up';
      popup = InfoPopup(item: mergeItem);
    } else if (emoji != null) {
      infoText = 'Item: $emoji';
    } else {
      infoText = 'Empty tile';
    }

    return Container(
      height: 46,
      color: Colors.grey.shade900,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: popup != null
                ? () => showDialog(
                    context: context, builder: (_) => popup!)
                : null,
            child: Icon(
              Icons.info_outline,
              color:
                  popup != null ? Colors.white70 : Colors.grey.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              infoText,
              style:
                  const TextStyle(fontSize: 12, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          helpButton,
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Listen for order completions → popup + auto-save
    ref.listen<int>(
      playerStatsProvider.select((s) => s.completedOrders),
      (prev, next) {
        if (prev != null && next > prev) {
          final reward = _pendingOrderReward;
          _pendingOrderReward = 0;
          _showOrderCompletePopup(reward);
          _autoSave();
        }
      },
    );

    // Listen for level-ups → dialog + auto-save
    ref.listen<int>(
      playerStatsProvider.select((s) => s.level),
      (prev, next) {
        if (prev != null && next > prev) {
          _showLevelUpDialog(next);
          _autoSave();
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Column(
        children: [
          _buildTopArea(),
          _buildOrderDisplay(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: grid.rowCount * grid.colCount,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: grid.colCount,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                  ),
                  itemBuilder: (_, index) => _buildTile(index),
                ),
              ),
            ),
          ),
          _buildBottomInfoBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'navFabGrid',
        backgroundColor: Colors.blueAccent,
        tooltip: 'Open Map',
        onPressed: () =>
            ref.read(activeScreenIndexProvider.notifier).state = 1,
        child: const Icon(Icons.map),
      ),
    );
  }
}

// ── Shared base for fireworks dialogs ────────────────────────────────────────
// Both popup dialogs follow the same pattern:
//   • Own their FireworksController (created + disposed inside the widget)
//   • Use AnimationController for any timed auto-dismiss (Ticker-based, not Timer)
//   • Fire fireworks via addPostFrameCallback so the display is ready first

// ── Order-complete popup ──────────────────────────────────────────────────────
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
                      horizontal: 36, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade900,
                    borderRadius: BorderRadius.circular(22),
                    border:
                        Border.all(color: Colors.amber.shade400, width: 2.5),
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

// ── Level-up dialog ───────────────────────────────────────────────────────────
class _LevelUpDialog extends StatefulWidget {
  final int newLevel;
  const _LevelUpDialog({required this.newLevel});

  @override
  State<_LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<_LevelUpDialog>
    with SingleTickerProviderStateMixin {
  late final FireworksController _fireworks;

  @override
  void initState() {
    super.initState();
    _fireworks = FireworksController(
      colors: const [
        Color(0xFF40C4FF),
        Color(0xFF00E5FF),
        Color(0xFFFFFFFF),
        Color(0xFF69F0AE),
        Color(0xFFB388FF),
      ],
      minExplosionDuration: 0.8,
      maxExplosionDuration: 3.0,
      minParticleCount: 130,
      maxParticleCount: 260,
      fadeOutDuration: 0.6,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fireworks.fireMultipleRockets(
          minRockets: 10,
          maxRockets: 22,
          launchWindow: const Duration(milliseconds: 1000),
        );
      }
    });
  }

  @override
  void dispose() {
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
                      horizontal: 40, vertical: 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade900, Colors.blue.shade700],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border:
                        Border.all(color: Colors.lightBlueAccent, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.5),
                        blurRadius: 36,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 4),
                      const Text(
                        'LEVEL  UP!',
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(color: Colors.black, blurRadius: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You reached Level ${widget.newLevel}!',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          '⚡  Max energy +10',
                          style: TextStyle(
                              color: Colors.lightBlueAccent, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Tap to continue',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 13),
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
