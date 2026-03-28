// lib/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/zone_meta.dart';
import '../providers/expansion_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/game_grid/game_grid_hud.dart';
import '../widgets/map/zone_node.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allZones = ref.watch(allUnlocksProvider);
    final unlockedIds = ref.watch(unlockedStatusProvider);
    final playerStats = ref.watch(playerStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Column(
        children: [
          // Shared top HUD (same as game grid)
          const GameGridHud(),

          // Map title bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFF162032),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🗺️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'World Map',
                  style: TextStyle(
                    color: Colors.amber.shade300,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: Text(
                    '${unlockedIds.length}/${allZones.length} zones',
                    style: const TextStyle(color: Colors.amber, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Map canvas
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(80),
                  minScale: 0.6,
                  maxScale: 2.0,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: Stack(
                      children: [
                        // Map background
                        _MapBackground(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                        ),

                        // Dotted paths between zones
                        CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _PathPainter(
                            allZones: allZones,
                            unlockedIds: unlockedIds,
                          ),
                        ),

                        // Zone nodes
                        ...allZones.map((zone) {
                          final meta = metaForZone(zone.id);
                          if (meta == null) return const SizedBox.shrink();
                          final dx = meta.mapPosition.dx * constraints.maxWidth;
                          final dy = meta.mapPosition.dy * constraints.maxHeight;
                          return Positioned(
                            left: dx - 40,
                            top: dy - 48,
                            child: ZoneNode(zone: zone, meta: meta),
                          );
                        }),

                        // Player level badge
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: _LevelBadge(level: playerStats.level),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'navFabMap',
        onPressed: () {
          ref.read(activeScreenIndexProvider.notifier).state = 0;
        },
        tooltip: 'Go to Grid',
        backgroundColor: Colors.teal,
        child: const Icon(Icons.grid_on),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Map background — layered gradient terrain
// ---------------------------------------------------------------------------
class _MapBackground extends StatelessWidget {
  final double width;
  final double height;
  const _MapBackground({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    const decorEmojis = ['🌲', '🌳', '🌿', '🪨', '🌾', '🌊'];
    const positions = [
      Offset(0.1, 0.2),  Offset(0.85, 0.15), Offset(0.3, 0.1),
      Offset(0.7, 0.35), Offset(0.15, 0.55), Offset(0.9, 0.5),
      Offset(0.45, 0.05),Offset(0.55, 0.88), Offset(0.05, 0.8),
      Offset(0.8, 0.8),  Offset(0.35, 0.65), Offset(0.65, 0.65),
      Offset(0.2, 0.35), Offset(0.78, 0.55), Offset(0.12, 0.92),
      Offset(0.9, 0.92), Offset(0.45, 0.78), Offset(0.6, 0.1),
    ];

    return Stack(
      children: [
        Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A3A2A),
                Color(0xFF2E5E3A),
                Color(0xFF4A7C50),
                Color(0xFF5A8C5A),
                Color(0xFF6B9E6B),
              ],
            ),
          ),
        ),
        for (int i = 0; i < positions.length; i++)
          Positioned(
            left: positions[i].dx * width,
            top: positions[i].dy * height,
            child: Text(
              decorEmojis[i % decorEmojis.length],
              style: TextStyle(
                fontSize: 20,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dotted paths between consecutive zone nodes
// ---------------------------------------------------------------------------
class _PathPainter extends CustomPainter {
  final List allZones;
  final Set<String> unlockedIds;

  const _PathPainter({required this.allZones, required this.unlockedIds});

  @override
  void paint(Canvas canvas, Size size) {
    final unlockedPaint = Paint()
      ..color = Colors.amber.withOpacity(0.7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final lockedPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final metas = allZones
        .map((z) => metaForZone(z.id as String))
        .whereType<ZoneMeta>()
        .toList();

    for (int i = 0; i < metas.length - 1; i++) {
      final a = metas[i];
      final b = metas[i + 1];
      final p1 = Offset(a.mapPosition.dx * size.width, a.mapPosition.dy * size.height);
      final p2 = Offset(b.mapPosition.dx * size.width, b.mapPosition.dy * size.height);
      final bothUnlocked = unlockedIds.contains(a.id) && unlockedIds.contains(b.id);
      _drawDotted(canvas, p1, p2, bothUnlocked ? unlockedPaint : lockedPaint);
    }
  }

  void _drawDotted(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashLen = 8.0;
    const gapLen = 6.0;
    final total = (p2 - p1).distance;
    final dir = (p2 - p1) / total;
    double drawn = 0;
    bool isDash = true;
    while (drawn < total) {
      final seg = isDash ? dashLen : gapLen;
      if (isDash) {
        canvas.drawLine(
          p1 + dir * drawn,
          p1 + dir * (drawn + seg).clamp(0, total),
          paint,
        );
      }
      drawn += seg;
      isDash = !isDash;
    }
  }

  @override
  bool shouldRepaint(_PathPainter old) => old.unlockedIds != unlockedIds;
}

// ---------------------------------------------------------------------------
// Player level badge
// ---------------------------------------------------------------------------
class _LevelBadge extends StatelessWidget {
  final int level;
  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            'Level $level',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
