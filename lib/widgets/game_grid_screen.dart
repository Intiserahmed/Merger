// lib/widgets/game_grid_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merger/providers/order_provider.dart'; // Keep for debug save?
import 'package:merger/models/tile_unlock.dart';
import 'package:merger/providers/expansion_provider.dart';
import 'package:merger/main.dart'; // Import main to access global isar instance
import 'package:merger/persistence/game_service.dart';
import 'package:merger/widgets/info_popup.dart'; // Keep for _buildTile
import 'package:merger/widgets/game_grid/tile_content.dart'; // Import new helper
import 'package:merger/widgets/game_grid/game_grid_hud.dart'; // Import HUD
import 'package:merger/widgets/game_grid/game_grid_orders.dart'; // Import Orders
import 'package:merger/widgets/game_grid/game_grid_bottom_bar.dart'; // Import Bottom Bar
import 'package:merger/widgets/game_grid_components.dart'
    hide buildTileContent; // Import helper

import 'dart:async';
import 'dart:math' as math;
import '../models/tile_data.dart';
import '../providers/grid_provider.dart' as grid;
import '../providers/player_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/merge_trees.dart';
import 'package:flutter/foundation.dart';
import '../debug/debug_panel.dart';
import 'game_grid/drag_layer.dart';
import 'game_grid/merge_effects.dart';
import 'game_grid/generator_tile.dart';
import '../services/merge_audio.dart';

// Define colors (keep here or move to a theme file)
final Color lightBrown = Colors.brown[300]!;
final Color darkBrown = Colors.brown[600]!;
final Color grassGreen = Colors.green[400]!;

// Convert to ConsumerStatefulWidget
class GameGridScreen extends ConsumerStatefulWidget {
  const GameGridScreen({super.key});

  @override
  ConsumerState<GameGridScreen> createState() => _GameGridScreenState();
}

// Create the State class
class _GameGridScreenState extends ConsumerState<GameGridScreen>
    with SingleTickerProviderStateMixin {
  TileData? _selectedTile;

  // ── Custom drag system ─────────────────────────────────────────────────
  final GlobalKey _gridKey = GlobalKey();
  final DragOverlayController _dragCtrl = DragOverlayController();

  // ── Merge effects ──────────────────────────────────────────────────────
  final MergeEffectsController _mergeCtrl = MergeEffectsController();
  final Set<(int, int)> _implosionTiles = {};
  (int, int)? _popCell;

  // ── Screen shake ───────────────────────────────────────────────────────
  late final AnimationController _shakeCtrl;
  Offset _shakeOffset = Offset.zero;

  int? _dragRow, _dragCol;
  (int, int)? _hoverCell;
  bool _isDragging = false;

  // ── Drag helpers ───────────────────────────────────────────────────────

  void _startItemDrag(int row, int col, Offset globalPos) {
    if (_isDragging) return; // multi-touch guard: ignore second finger
    final gridData = ref.read(grid.gridProvider);
    if (row >= gridData.length || col >= gridData[0].length) return;
    final tile = gridData[row][col];
    if (!tile.isItem || tile.itemImagePath == null) return;

    setState(() {
      _dragRow = row;
      _dragCol = col;
      _hoverCell = null;
      _isDragging = true;
    });

    _dragCtrl.startDrag(
      emoji: tile.itemImagePath!,
      globalPos: globalPos,
      tileSize: 54.0,
    );
  }

  void _updateItemDrag(Offset globalPos) {
    if (!_isDragging) return;
    _dragCtrl.updateDrag(globalPos);

    final cell = _cellFromGlobal(globalPos);
    final wasValid = _hoverCell != null && _isValidDrop(_hoverCell!.$1, _hoverCell!.$2);
    final nowValid = cell != null && _isValidDrop(cell.$1, cell.$2);

    if (cell != _hoverCell) {
      setState(() => _hoverCell = cell);
    }
    if (nowValid != wasValid) {
      _dragCtrl.setOverValid(nowValid);
    }
  }

  void _endItemDrag(Offset globalPos) {
    if (!_isDragging) return;

    final srcRow = _dragRow!;
    final srcCol = _dragCol!;
    final cell = _cellFromGlobal(globalPos);

    // Validate BEFORE clearing drag state (_isValidDrop reads _dragRow/_dragCol)
    final isValid = cell != null &&
        !(cell.$1 == srcRow && cell.$2 == srcCol) &&
        _isValidDrop(cell.$1, cell.$2);

    setState(() {
      _isDragging = false;
      _hoverCell = null;
      _dragRow = null;
      _dragCol = null;
    });

    if (isValid) {
      final tgtRow = cell!.$1, tgtCol = cell.$2;
      final isMerge = _willMerge(srcRow, srcCol, tgtRow, tgtCol);
      final target = _cellCenterGlobal(tgtRow, tgtCol);

      _dragCtrl.snapTo(target, () {
        if (isMerge) {
          // Hide source + target tiles during implosion
          final gridData = ref.read(grid.gridProvider);
          final srcEmoji = gridData[srcRow][srcCol].itemImagePath ?? '';
          final isRare   = (gridData[srcRow][srcCol].overlayNumber) >= 3;

          setState(() {
            _implosionTiles.add((srcRow, srcCol));
            _implosionTiles.add((tgtRow, tgtCol));
          });

          MergeAudio.instance.playMerge();

          _mergeCtrl.onPop = () {
            setState(() => _popCell = (tgtRow, tgtCol));
            Future.delayed(const Duration(milliseconds: 400), () {
              if (mounted) setState(() => _popCell = null);
            });
          };
          _mergeCtrl.trigger(
            mergeGlobal:  _cellCenterGlobal(tgtRow, tgtCol),
            src1Global:   _cellCenterGlobal(srcRow, srcCol),
            src2Global:   _cellCenterGlobal(tgtRow, tgtCol),
            sourceEmoji:  srcEmoji,
            xpGain:       5 + (gridData[srcRow][srcCol].overlayNumber) * 3,
            isRare:       isRare,
            onImplosionDone: () {
              _executeDrop(srcRow, srcCol, tgtRow, tgtCol);
              setState(() {
                _implosionTiles.remove((srcRow, srcCol));
                _implosionTiles.remove((tgtRow, tgtCol));
              });
            },
          );
        } else {
          _executeDrop(srcRow, srcCol, tgtRow, tgtCol);
        }
      });
    } else {
      // Invalid → wobble and return arc
      final src = _cellCenterGlobal(srcRow, srcCol);
      _dragCtrl.wobbleAndReturn(src, () {});
    }
  }

  (int, int)? _cellFromGlobal(Offset globalPos) {
    final box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final local = box.globalToLocal(globalPos);
    final cw = box.size.width / grid.colCount;
    final ch = box.size.height / grid.rowCount;
    final col = (local.dx / cw).floor();
    final row = (local.dy / ch).floor();
    if (row < 0 || row >= grid.rowCount || col < 0 || col >= grid.colCount) {
      return null;
    }
    return (row, col);
  }

  Offset _cellCenterGlobal(int row, int col) {
    final box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    final cw = box.size.width / grid.colCount;
    final ch = box.size.height / grid.rowCount;
    return box.localToGlobal(Offset((col + 0.5) * cw, (row + 0.5) * ch));
  }

  bool _willMerge(int srcRow, int srcCol, int tgtRow, int tgtCol) {
    final gridData = ref.read(grid.gridProvider);
    if (tgtRow >= gridData.length || tgtCol >= gridData[0].length) return false;
    final target = gridData[tgtRow][tgtCol];
    final source = gridData[srcRow][srcCol];
    return target.itemImagePath != null &&
        source.itemImagePath != null &&
        target.itemImagePath == source.itemImagePath;
  }

  bool _isValidDrop(int row, int col) {
    final gridData = ref.read(grid.gridProvider);
    final srcRow = _dragRow;
    final srcCol = _dragCol;
    if (srcRow == null || srcCol == null) return false;
    if (row == srcRow && col == srcCol) return false;
    if (row >= gridData.length || col >= gridData[0].length) return false;

    final target = gridData[row][col];
    final source = gridData[srcRow][srcCol];

    if (target.isLocked) return false;
    if (target.isGenerator) return false;
    if (target.itemImagePath == null && source.isItem) return true;
    if (target.itemImagePath != null &&
        source.itemImagePath != null &&
        target.itemImagePath == source.itemImagePath) {
      final next = getNextItemInSequence(target.itemImagePath!);
      if (next != null) return true;
    }
    return false;
  }

  void _executeDrop(int srcRow, int srcCol, int tgtRow, int tgtCol) {
    final gridData = ref.read(grid.gridProvider);
    if (tgtRow >= gridData.length || tgtCol >= gridData[0].length) return;
    final target = gridData[tgtRow][tgtCol];
    final source = gridData[srcRow][srcCol];

    if (target.itemImagePath == null && source.isItem) {
      ref.read(grid.gridProvider.notifier).moveItem(srcRow, srcCol, tgtRow, tgtCol);
    } else if (target.itemImagePath != null &&
        target.itemImagePath == source.itemImagePath) {
      ref.read(grid.gridProvider.notifier).mergeTiles(tgtRow, tgtCol, srcRow, srcCol);
    }
  }

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )
      ..addListener(() {
        final t = _shakeCtrl.value;
        setState(() => _shakeOffset = Offset(math.sin(t * math.pi * 8) * 2.0, 0));
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) setState(() => _shakeOffset = Offset.zero);
      });

    _mergeCtrl.onShake = () => _shakeCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _isDragging = false;
    _dragRow = null;
    _dragCol = null;
    _hoverCell = null;
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _showLevelUpBanner(BuildContext context, int newLevel) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B2A3B), Color(0xFF2E5E3A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.amber, width: 2.5),
            boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 20, spreadRadius: 4)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 8),
              const Text('LEVEL UP!', style: TextStyle(color: Colors.amber, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 6),
              Text('You reached Level $newLevel', style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('+10 Max Energy', style: TextStyle(color: Colors.greenAccent, fontSize: 14)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue', style: TextStyle(color: Colors.amber, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Build Tile Method ---
  Widget _buildTile(int index) {
    final int row = index ~/ grid.colCount;
    final int col = index % grid.colCount;
    final gridData = ref.watch(grid.gridProvider);

    if (row >= gridData.length || col >= gridData[0].length) {
      return Container(color: Colors.red.withOpacity(0.2), margin: const EdgeInsets.all(1.0));
    }

    final TileData tileData = gridData[row][col];
    final bool isDragSource    = _isDragging && _dragRow == row && _dragCol == col;
    final bool isImploding     = _implosionTiles.contains((row, col));
    final bool isPopTarget     = _popCell == (row, col);
    final bool isHoverTarget = _hoverCell == (row, col);
    final bool hoverValid = isHoverTarget && _isValidDrop(row, col);
    final bool hoverInvalid = isHoverTarget && !hoverValid && _isDragging;

    Color backgroundColor;
    if (tileData.baseImagePath == '🟩') {
      backgroundColor = grassGreen;
    } else if (tileData.isLocked) {
      backgroundColor = Colors.grey.shade500;
    } else {
      backgroundColor = (row + col) % 2 == 0 ? lightBrown : darkBrown;
    }

    // Hover highlight colours
    Color borderColor = Colors.black.withOpacity(0.2);
    double borderWidth = 0.5;
    if (hoverValid) {
      borderColor = Colors.greenAccent.shade400;
      borderWidth = 2.5;
    } else if (hoverInvalid) {
      borderColor = Colors.redAccent.shade200;
      borderWidth = 2.0;
    }

    // ── Generator tiles get their own rich widget ───────────────────────────
    if (tileData.isGenerator) {
      return GeneratorTile(
        key: ValueKey('gen_${row}_$col'),
        tile: tileData,
        bgColor: backgroundColor,
        onTap: () => ref.read(grid.gridProvider.notifier).activateGenerator(row, col),
      );
    }

    Widget content = Container(
      key: ValueKey('tile_${row}_${col}_${tileData.type}_${tileData.itemImagePath ?? 'base'}_${tileData.isReady}'),
      margin: const EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: tileData.isItem
            ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3.0, offset: const Offset(1, 1))]
            : null,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          if (tileData.isLocked)
            buildTileContent(tileData.baseImagePath, fit: BoxFit.contain, size: 30),
          // Hide item while dragging or during implosion overlay
          if (tileData.itemImagePath != null && !isDragSource && !isImploding)
            buildTileContent(tileData.itemImagePath!, fit: BoxFit.contain, size: 28),
          // Proximity pulse ring on valid hover target
          if (hoverValid)
            Positioned.fill(child: _PulseRing()),
        ],
      ),
    );

    content = SizedBox(width: 50, height: 50, child: content);

    // 7 ── New item pop: bounce-in at 120% → 100% ──────────────────────────
    if (isPopTarget) {
      content = TweenAnimationBuilder<double>(
        key: ValueKey('pop_${row}_$col'),
        tween: Tween(begin: 1.2, end: 1.0),
        duration: const Duration(milliseconds: 380),
        curve: Curves.elasticOut,
        builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
        child: content,
      );
    }

    if (tileData.isItem) {
      return GestureDetector(
        onPanStart: (d) => _startItemDrag(row, col, d.globalPosition),
        onPanUpdate: (d) => _updateItemDrag(d.globalPosition),
        onPanEnd: (d) => _endItemDrag(d.globalPosition),
        onPanCancel: () {
          if (_isDragging) {
            final src = _cellCenterGlobal(_dragRow!, _dragCol!);
            setState(() { _isDragging = false; _hoverCell = null; _dragRow = null; _dragCol = null; });
            _dragCtrl.wobbleAndReturn(src, () {});
          }
        },
        child: content,
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() => _selectedTile = (_selectedTile == tileData) ? null : tileData);
          if (tileData.isLocked) {
            _handleLockedTileTap(row, col);
          } else if (tileData.itemImagePath == null) {
            setState(() => _selectedTile = null);
          }
        },
        child: content,
      );
    }
  }

  // --- Helper for Locked Tile Tap Logic ---
  void _handleLockedTileTap(int row, int col) {
    final availableUnlocks = ref.read(availableUnlocksProvider);
    final mathPoint = math.Point<int>(
      col,
      row,
    ); // Using math.Point (x, y) -> (col, row)
    TileUnlock? targetUnlock;

    // Find the unlock zone covering this tile
    for (final unlock in availableUnlocks) {
      // Assuming coveredTiles in TileUnlock uses a custom Point or similar structure {row, col}
      if (unlock.coveredTiles.any((p) => p.row == row && p.col == col)) {
        targetUnlock = unlock;
        break;
      }
      // If TileUnlock uses math.Point:
      // if (unlock.coveredTiles.any((p) => p.x == col && p.y == row)) {
      //      targetUnlock = unlock;
      //      break;
      // }
    }

    if (targetUnlock != null) {
      final success = ref
          .read(playerStatsProvider.notifier)
          .unlockZone(targetUnlock);
      if (mounted) {
        // Check if the widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? "Zone '${targetUnlock.id}' unlocked!"
                  : "Failed to unlock zone. Check level (${targetUnlock.requiredLevel}) and coins (${targetUnlock.unlockCostCoins}).",
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Tile is locked, but not part of an *available* unlock
      final allUnlocks = ref.read(allUnlocksProvider);
      final actualZone = allUnlocks.firstWhere(
        (u) => u.coveredTiles.any((p) => p.row == row && p.col == col),
        // Provide a default/fallback TileUnlock if not found (adjust defaults)
        orElse:
            () => TileUnlock(
              id: 'unknown',
              requiredLevel: 999,
              unlockCostCoins: 0,
              coveredTiles: [],
            ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              actualZone.id != 'unknown'
                  ? "Zone locked. Requires Level ${actualZone.requiredLevel}."
                  : "Locked tile (Unknown zone).",
            ), // Handle case where zone isn't found
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  // --- Build Method (Simplified) ---
  @override
  Widget build(BuildContext context) {
    // Level-up announcement listener
    ref.listen<int>(
      playerStatsProvider.select((s) => s.level),
      (previous, next) {
        if (previous != null && next > previous) {
          _showLevelUpBanner(context, next);
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Column(
        children: [
          // --- Top HUD ---
          const GameGridHud(), // Use the new widget
          // --- Debug Buttons Row Removed ---

          // --- Order Display ---
          const GameGridOrders(), // Use the new widget
          // --- Game Grid ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Transform.translate(
                  offset: _shakeOffset,
                  child: Stack(
                    children: [
                      GridView.builder(
                        key: _gridKey,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: grid.rowCount * grid.colCount,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: grid.colCount,
                          childAspectRatio: 1.0,
                          mainAxisSpacing: 1.0,
                          crossAxisSpacing: 1.0,
                        ),
                        itemBuilder: (context, index) => _buildTile(index),
                      ),
                      // Merge effects overlay
                      Positioned.fill(
                        child: IgnorePointer(
                          child: MergeEffectsOverlay(controller: _mergeCtrl),
                        ),
                      ),
                      // Drag overlay
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DragOverlay(controller: _dragCtrl),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Bottom Info Bar ---
          // Pass the selected tile state to the bottom bar widget
          GameGridBottomBar(selectedTile: _selectedTile),
        ],
      ),

      // --- Floating Action Buttons ---
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (kDebugMode) debugFab(context, ref),
          if (kDebugMode) const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: 'navFabGrid',
            onPressed: () {
              ref.read(activeScreenIndexProvider.notifier).state = 1;
            },
            tooltip: 'Go to Map',
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.map),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pulse ring shown on valid drop target during proximity hover
// ---------------------------------------------------------------------------
class _PulseRing extends StatefulWidget {
  const _PulseRing();

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: 1.0 + _ctrl.value * 0.10,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.greenAccent.withOpacity(0.6 + _ctrl.value * 0.3),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Live-ticking cooldown overlay for generator tiles
// ---------------------------------------------------------------------------
class _CooldownOverlay extends StatefulWidget {
  final TileData tile;
  const _CooldownOverlay({required this.tile});

  @override
  State<_CooldownOverlay> createState() => _CooldownOverlayState();
}

class _CooldownOverlayState extends State<_CooldownOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.tile.remainingCooldown;
    if (remaining == Duration.zero) return const SizedBox.shrink();
    final secs = remaining.inSeconds + 1;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          '${secs}s',
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
