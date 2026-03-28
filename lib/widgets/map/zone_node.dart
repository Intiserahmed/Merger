// lib/widgets/map/zone_node.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/tile_unlock.dart';
import '../../models/zone_meta.dart';
import '../../providers/expansion_provider.dart';
import '../../providers/player_provider.dart';

class ZoneNode extends ConsumerStatefulWidget {
  final TileUnlock zone;
  final ZoneMeta meta;

  const ZoneNode({super.key, required this.zone, required this.meta});

  @override
  ConsumerState<ZoneNode> createState() => _ZoneNodeState();
}

class _ZoneNodeState extends ConsumerState<ZoneNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showZoneSheet(BuildContext context, bool isUnlocked, bool canUnlock) {
    final playerStats = ref.read(playerStatsProvider);
    final upgradeLevel =
        playerStats.infrastructureLevels[widget.zone.requiredLevel] ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _ZoneBottomSheet(
            zone: widget.zone,
            meta: widget.meta,
            isUnlocked: isUnlocked,
            canUnlock: canUnlock,
            upgradeLevel: upgradeLevel,
            onUnlock: () {
              final success = ref
                  .read(playerStatsProvider.notifier)
                  .unlockZone(widget.zone);
              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.meta.name} unlocked!'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unlockedIds = ref.watch(unlockedStatusProvider);
    final playerStats = ref.watch(playerStatsProvider);

    final isUnlocked = unlockedIds.contains(widget.zone.id);
    final canUnlock =
        !isUnlocked &&
        playerStats.level >= widget.zone.requiredLevel &&
        playerStats.coins >= widget.zone.unlockCostCoins;

    final upgradeLevel =
        playerStats.infrastructureLevels[widget.zone.requiredLevel] ?? 0;
    final displayEmoji = widget.meta.emojiForUpgrade(
      isUnlocked ? upgradeLevel : 0,
    );

    return GestureDetector(
      onTap: () => _showZoneSheet(context, isUnlocked, canUnlock),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulse animation for available-to-unlock zones
          if (canUnlock)
            ScaleTransition(
              scale: _pulseAnim,
              child: _NodeCircle(
                emoji: displayEmoji,
                isUnlocked: isUnlocked,
                canUnlock: canUnlock,
              ),
            )
          else
            _NodeCircle(
              emoji: displayEmoji,
              isUnlocked: isUnlocked,
              canUnlock: canUnlock,
            ),
          const SizedBox(height: 4),
          // Zone name label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.meta.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Lock requirements badge
          if (!isUnlocked)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color:
                    canUnlock
                        ? Colors.green.withOpacity(0.8)
                        : Colors.red.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Lv${widget.zone.requiredLevel} · ${widget.zone.unlockCostCoins}🪙',
                style: const TextStyle(color: Colors.white, fontSize: 9),
              ),
            ),
        ],
      ),
    );
  }
}

class _NodeCircle extends StatelessWidget {
  final String emoji;
  final bool isUnlocked;
  final bool canUnlock;

  const _NodeCircle({
    required this.emoji,
    required this.isUnlocked,
    required this.canUnlock,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    if (isUnlocked) {
      borderColor = Colors.amber;
      bgColor = Colors.green.shade700;
    } else if (canUnlock) {
      borderColor = Colors.greenAccent;
      bgColor = Colors.teal.shade700;
    } else {
      borderColor = Colors.grey.shade600;
      bgColor = Colors.grey.shade800;
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child:
            isUnlocked
                ? Text(emoji, style: const TextStyle(fontSize: 28))
                : Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      emoji,
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                    const Text('🔒', style: TextStyle(fontSize: 22)),
                  ],
                ),
      ),
    );
  }
}

class _ZoneBottomSheet extends StatelessWidget {
  final TileUnlock zone;
  final ZoneMeta meta;
  final bool isUnlocked;
  final bool canUnlock;
  final int upgradeLevel;
  final VoidCallback onUnlock;

  const _ZoneBottomSheet({
    required this.zone,
    required this.meta,
    required this.isUnlocked,
    required this.canUnlock,
    required this.upgradeLevel,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A3B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUnlocked ? Colors.amber : Colors.grey.shade600,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zone icon + name
          Row(
            children: [
              Text(
                meta.emojiForUpgrade(isUnlocked ? upgradeLevel : 0),
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isUnlocked)
                      Text(
                        'Infrastructure: $upgradeLevel / 5',
                        style: TextStyle(
                          color: Colors.amber.shade300,
                          fontSize: 13,
                        ),
                      )
                    else
                      Text(
                        'Requires Level ${zone.requiredLevel} · ${zone.unlockCostCoins} 🪙',
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Infrastructure upgrade preview (unlocked zones)
          if (isUnlocked) ...[
            _buildUpgradeBar(upgradeLevel),
            const SizedBox(height: 16),
          ],

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canUnlock && !isUnlocked ? onUnlock : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isUnlocked
                        ? Colors.grey.shade700
                        : (canUnlock ? Colors.green : Colors.grey.shade800),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isUnlocked
                    ? 'Zone Active ✓'
                    : (canUnlock ? 'Unlock Zone' : 'Requirements Not Met'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeBar(int level) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < level;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                filled ? Colors.amber.shade600 : Colors.grey.shade800,
            border: Border.all(
              color: filled ? Colors.amber : Colors.grey.shade600,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              meta.upgradeEmojis[(i + 1).clamp(0, meta.upgradeEmojis.length - 1)],
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      }),
    );
  }
}
