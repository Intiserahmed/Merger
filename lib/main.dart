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

  // Load game data after Isar is initialized
  // We need the container to read/write providers
  await GameService(isar, container).loadGame();

  runApp(
    UncontrolledProviderScope(
      container: container, // Use the same container
      child: const MyApp(),
    ),
  );
}

// Make MyApp a ConsumerWidget to access providers
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // Define the list of screens corresponding to the provider index
  final List<Widget> _screens = const [
    GameGridScreen(), // Index 0
    MapScreen(), // Index 1
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    );
  }
}
