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
  final gameService = GameService(isar, container);
  await gameService.loadGame();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(gameService: gameService),
    ),
  );
}

class MyApp extends StatefulWidget {
  final GameService gameService;
  const MyApp({required this.gameService, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      widget.gameService.saveGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final splashDone = ref.watch(splashDoneProvider);
        final activeIndex = ref.watch(activeScreenIndexProvider);
        const screens = [GameGridScreen(), MapScreen()];
        final safeIndex = activeIndex.clamp(0, screens.length - 1);

        return MaterialApp(
          title: 'Merger',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
            useMaterial3: true,
          ),
          home: splashDone ? screens[safeIndex] : const SplashScreen(),
        );
      },
    );
  }
}
