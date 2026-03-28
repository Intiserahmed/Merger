import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:merger/screens/map_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'models/player_stats.dart';
import 'models/tile_data.dart';
import 'models/order.dart';
import 'widgets/game_grid_screen.dart';
import 'widgets/splash_screen.dart';
import 'persistence/game_service.dart';
import 'providers/navigation_provider.dart';

// Global Isar instance
late Isar isar;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [PlayerStatsSchema, TileDataSchema, OrderSchema],
    directory: dir.path,
    name: 'mergerGameDB',
  );

  final container = ProviderContainer();
  await GameService(isar, container).loadGame();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashDone = ref.watch(splashDoneProvider);
    final activeIndex = ref.watch(activeScreenIndexProvider);

    const screens = [GameGridScreen(), MapScreen()];

    return MaterialApp(
      title: 'Merger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: splashDone ? screens[activeIndex] : const SplashScreen(),
    );
  }
}
