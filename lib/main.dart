import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:merger/screens/map_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'models/player_stats.dart'; // Import schemas
import 'models/tile_data.dart';
import 'models/order.dart';
import 'widgets/game_grid_screen.dart';
import 'persistence/game_service.dart'; // Import the service
import 'providers/navigation_provider.dart'; // Import the navigation provider

// Global Isar instance (consider a more robust DI approach for larger apps)
late Isar isar;

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Isar
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [PlayerStatsSchema, TileDataSchema, OrderSchema], // Add all schemas
    directory: dir.path,
    name: 'mergerGameDB', // Optional custom name
  );

  // Create ProviderContainer to access providers before runApp
  final container = ProviderContainer();

  // Create GameService instance
  final gameService = GameService(isar, container);

  // Load game data after Isar is initialized
  await gameService.loadGame();

  runApp(
    UncontrolledProviderScope(
      container: container, // Use the same container
      child: MyApp(gameService: gameService), // Pass GameService
    ),
  );
}

// Convert MyApp to StatefulWidget to handle lifecycle events
class MyApp extends StatefulWidget {
  final GameService gameService; // Add GameService instance

  const MyApp({required this.gameService, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Define the list of screens corresponding to the provider index
  final List<Widget> _screens = const [
    GameGridScreen(), // Index 0
    MapScreen(), // Index 1
  ];

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
      print("App paused - triggering auto-save...");
      // Use the passed GameService instance to save
      widget.gameService.saveGame();
    }
    // You could potentially save on other states too, like detached
    // if (state == AppLifecycleState.detached) { ... }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to watch providers within the build method
    return Consumer(
      builder: (context, ref, child) {
        // Watch the active screen index provider
        final activeIndex = ref.watch(activeScreenIndexProvider);

        return MaterialApp(
          title: 'Merger Game', // Updated title
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
            ), // Example theme
            useMaterial3: true,
          ),
          // Display the screen based on the active index
          home: _screens[activeIndex],
          debugShowCheckedModeBanner: false,
        ); // Add missing );
      }, // Add missing comma for builder
    ); // Add missing ); for Consumer
  }
}
