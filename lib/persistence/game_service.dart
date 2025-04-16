import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/player_stats.dart';
import '../models/tile_data.dart';
import '../models/order.dart';
import '../providers/player_provider.dart';
import '../providers/grid_provider.dart';
import '../providers/order_provider.dart';
import '../providers/expansion_provider.dart'; // Needed for unlockedStatusProvider access during load

class GameService {
  final Isar isar;
  // Use ProviderContainer to access providers outside of widgets/providers
  final ProviderContainer container;

  GameService(this.isar, this.container);

  // --- Load Game State ---
  Future<void> loadGame() async {
    print("Attempting to load game state...");

    // Load Player Stats
    final savedStats = await isar.playerStats.get(
      Isar.autoIncrement,
    ); // Assuming only one entry
    if (savedStats != null) {
      print(
        "Loaded PlayerStats: Level ${savedStats.level}, Coins ${savedStats.coins}",
      );
      // Update the provider state
      container.read(playerStatsProvider.notifier).loadStats(savedStats);
      // Also update the derived unlockedStatusProvider implicitly via playerStatsProvider
    } else {
      print("No saved PlayerStats found, using defaults.");
      // Initialize with default if no save exists (already handled by provider default)
      // Optionally save the default state here?
      // await saveGame(); // Save initial state if desired
    }

    // Load Grid State
    final savedTiles = await isar.tileDatas.where().findAll();
    if (savedTiles.isNotEmpty) {
      print("Loaded ${savedTiles.length} tiles.");
      // Reconstruct the grid (assuming rowCount/colCount are fixed)
      final loadedGrid = List.generate(
        rowCount,
        (_) => List<TileData>.filled(
          colCount,
          // Create a default empty tile temporarily
          TileData(row: 0, col: 0, baseImagePath: defaultEmptyBase),
        ),
      );
      bool gridValid = true;
      for (final tile in savedTiles) {
        if (tile.row < rowCount && tile.col < colCount) {
          loadedGrid[tile.row][tile.col] = tile;
        } else {
          print(
            "Warning: Loaded tile out of bounds (${tile.row}, ${tile.col}). Skipping.",
          );
          gridValid = false;
        }
      }

      if (gridValid) {
        // Directly set the state of the GridNotifier
        // Note: This bypasses the GridNotifier's initialization logic,
        // ensure loaded state is consistent or re-run init logic if needed.
        container.read(gridProvider.notifier).state = loadedGrid;
        print("Grid state loaded successfully.");
      } else {
        print("Grid state potentially corrupted, using default grid.");
        // GridProvider will keep its default initialized state if we don't update it.
        // No need to call _initializeGridData here.
      }
    } else {
      print("No saved Grid state found, using default grid.");
      // GridProvider initializes itself with defaults, so nothing needed here
    }

    // Load Orders (Optional - might regenerate on load instead)
    final savedOrders = await isar.orders.where().findAll();
    if (savedOrders.isNotEmpty) {
      print("Loaded ${savedOrders.length} orders.");
      // Update the OrderProvider state
      container.read(orderProvider.notifier).state = savedOrders;
    } else {
      print("No saved Orders found, generating initial orders.");
      // OrderProvider initializes itself, so nothing needed here
    }

    print("Game load complete.");
  }

  // --- Save Game State ---
  Future<void> saveGame() async {
    print("Attempting to save game state...");
    try {
      // Get current states from providers
      final playerStats = container.read(playerStatsProvider);
      final gridState = container.read(gridProvider);
      final orders = container.read(orderProvider);

      await isar.writeTxn(() async {
        // Clear existing data first
        await isar.clear(); // Clears the entire database - simple approach
        // Or clear collections individually:
        // await isar.playerStats.clear();
        // await isar.tileDatas.clear();
        // await isar.orders.clear();

        // Save Player Stats (ensure only one entry if using autoIncrement id)
        // We need to fetch the existing ID or handle the single entry case.
        // For simplicity, let's assume we always overwrite the entry with id = Isar.autoIncrement (which is 1 for the first object)
        playerStats.id =
            1; // Assign a fixed ID for the single player stats object
        await isar.playerStats.put(playerStats);
        print(
          "Saved PlayerStats: Level ${playerStats.level}, Coins ${playerStats.coins}",
        );

        // Save Grid State (flatten the grid and save each tile)
        final List<TileData> tilesToSave = [];
        for (final row in gridState) {
          tilesToSave.addAll(row);
        }
        await isar.tileDatas.putAll(tilesToSave);
        print("Saved ${tilesToSave.length} tiles.");

        // Save Orders
        await isar.orders.putAll(orders);
        print("Saved ${orders.length} orders.");
      });
      print("Game state saved successfully!");
    } catch (e) {
      print("Error saving game state: $e");
    }
  }
}

// Optional: Provider for the service itself if needed elsewhere
// final gameServiceProvider = Provider<GameService>((ref) {
//   // This won't work well because Isar and ProviderContainer aren't easily available here.
//   // Accessing via global `isar` and passing container from main is simpler for now.
//   throw UnimplementedError("Provider needs Isar instance and ProviderContainer");
// });
