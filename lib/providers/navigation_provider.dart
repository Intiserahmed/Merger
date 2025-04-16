import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to hold the index of the currently active main screen.
/// 0 = GameGridScreen
/// 1 = MapScreen
final activeScreenIndexProvider = StateProvider<int>(
  (ref) => 0,
); // Start with Grid screen
