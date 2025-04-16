import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/player_stats.dart'; // Import schemas
import 'models/tile_data.dart';
import 'models/order.dart';
import 'widgets/game_grid_screen.dart';
import 'persistence/game_service.dart'; // Import the service

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Merger Game', // Updated title
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ), // Example theme
        useMaterial3: true,
      ),
      home: const GameGridScreen(), // Your main screen widget
      debugShowCheckedModeBanner: false,
    );
  }
}
