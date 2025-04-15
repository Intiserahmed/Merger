// lib/models/order.dart
import 'package:flutter/foundation.dart';

@immutable
class Order {
  final String id;
  final String requiredItemId; // e.g., 'item_shell_level_3'
  final int requiredCount;
  final int currentCount;
  final int rewardCoins;
  final int rewardXp;

  const Order({
    required this.id,
    required this.requiredItemId,
    required this.requiredCount,
    this.currentCount = 0,
    required this.rewardCoins,
    required this.rewardXp,
  });

  // copyWith, ==, hashCode...
  Order copyWith({
    String? id,
    String? requiredItemId,
    int? requiredCount,
    int? currentCount,
    int? rewardCoins,
    int? rewardXp,
  }) {
    return Order(
      id: id ?? this.id,
      requiredItemId: requiredItemId ?? this.requiredItemId,
      requiredCount: requiredCount ?? this.requiredCount,
      currentCount: currentCount ?? this.currentCount,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      rewardXp: rewardXp ?? this.rewardXp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          requiredItemId == other.requiredItemId &&
          requiredCount == other.requiredCount &&
          currentCount == other.currentCount &&
          rewardCoins == other.rewardCoins &&
          rewardXp == other.rewardXp;

  @override
  int get hashCode =>
      id.hashCode ^
      requiredItemId.hashCode ^
      requiredCount.hashCode ^
      currentCount.hashCode ^
      rewardCoins.hashCode ^
      rewardXp.hashCode;
}
