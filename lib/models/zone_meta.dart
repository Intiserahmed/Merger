// lib/models/zone_meta.dart
import 'package:flutter/material.dart';

/// Visual + gameplay metadata for a map zone.
/// Paired with TileUnlock by matching [id].
class ZoneMeta {
  final String id;
  final String name;
  final String emoji;

  /// Emoji icons per infrastructure upgrade level (index 0 = upgrade 0, index 5 = fully upgraded)
  final List<String> upgradeEmojis;

  /// Normalised position on the map canvas (0.0–1.0 for both x and y)
  final Offset mapPosition;

  const ZoneMeta({
    required this.id,
    required this.name,
    required this.emoji,
    required this.upgradeEmojis,
    required this.mapPosition,
  });

  /// Returns the emoji that represents the current upgrade level.
  String emojiForUpgrade(int upgradeLevel) {
    final clamped = upgradeLevel.clamp(0, upgradeEmojis.length - 1);
    return upgradeEmojis[clamped];
  }
}

/// Master list of zone visual metadata.
const List<ZoneMeta> allZoneMeta = [
  ZoneMeta(
    id: 'zone_starter',
    name: 'Starting Village',
    emoji: '🏕️',
    upgradeEmojis: ['🏕️', '🏠', '🏘️', '🏡', '🏙️', '🌆'],
    mapPosition: Offset(0.5, 0.75),
  ),
  ZoneMeta(
    id: 'zone_beach_1',
    name: 'Sandy Beach',
    emoji: '🏖️',
    upgradeEmojis: ['🔒', '🏖️', '⛵', '🐚', '🌊', '🏝️'],
    mapPosition: Offset(0.75, 0.6),
  ),
  ZoneMeta(
    id: 'zone_forest_1',
    name: 'Ancient Forest',
    emoji: '🌲',
    upgradeEmojis: ['🔒', '🌱', '🌿', '🌳', '🌲', '🏔️'],
    mapPosition: Offset(0.25, 0.45),
  ),
  ZoneMeta(
    id: 'zone_mine_1',
    name: 'Crystal Mine',
    emoji: '⛏️',
    upgradeEmojis: ['🔒', '⛏️', '🪨', '💎', '🔮', '✨'],
    mapPosition: Offset(0.6, 0.3),
  ),
  ZoneMeta(
    id: 'zone_castle_1',
    name: 'Ancient Castle',
    emoji: '🏰',
    upgradeEmojis: ['🔒', '🪨', '🗼', '🏯', '🏰', '👑'],
    mapPosition: Offset(0.4, 0.15),
  ),
];

ZoneMeta? metaForZone(String id) {
  try {
    return allZoneMeta.firstWhere((m) => m.id == id);
  } catch (_) {
    return null;
  }
}
