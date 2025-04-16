// lib/models/order.dart
import 'package:isar/isar.dart';

part 'order.g.dart'; // Isar generated code

@collection
class Order {
  Id isarId = Isar.autoIncrement; // Isar requires an Id field

  late String
  id; // Keep your original ID if needed, or remove if isarId is sufficient
  late String requiredItemId; // e.g., '⭐' or '🛡️'
  late int requiredCount;
  // Removed currentCount - we will check the grid directly
  late int rewardCoins;
  late int rewardXp;

  // Constructor for Isar
  Order({
    required this.id,
    required this.requiredItemId,
    required this.requiredCount,
    // Removed currentCount from constructor
    required this.rewardCoins,
    required this.rewardXp,
  });

  // Note: Removed copyWith, ==, and hashCode
}
