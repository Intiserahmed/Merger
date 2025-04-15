// lib/models/order.dart
import 'package:isar/isar.dart';

part 'order.g.dart'; // Isar generated code

@collection
class Order {
  Id isarId = Isar.autoIncrement; // Isar requires an Id field

  late String
  id; // Keep your original ID if needed, or remove if isarId is sufficient
  late String requiredItemId; // e.g., 'item_shell_level_3'
  late int requiredCount;
  int currentCount;
  late int rewardCoins;
  late int rewardXp;

  // Constructor for Isar
  Order({
    required this.id,
    required this.requiredItemId,
    required this.requiredCount,
    this.currentCount = 0,
    required this.rewardCoins,
    required this.rewardXp,
  });

  // Note: Removed copyWith, ==, and hashCode
}
