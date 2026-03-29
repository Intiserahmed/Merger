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

  // --- Load validation ---
  // Returns null when the saved stats look sane; a reason string when corrupt.
  String? _validateStats(PlayerStats s) {
    if (s.level < 1 || s.level > maxPlayerLevel) return 'level out of range: ${s.level}';
    if (s.coins < 0) return 'negative coins: ${s.coins}';
    if (s.gems < 0) return 'negative gems: ${s.gems}';
    if (s.energy < 0 || s.energy > s.maxEnergy) return 'energy out of range: ${s.energy}/${s.maxEnergy}';
    if (s.maxEnergy < 20) return 'maxEnergy too low: ${s.maxEnergy}';
    if (s.completedOrders < 0) return 'negative completedOrders: ${s.completedOrders}';
    return null;
  }

  // --- Load Game State ---
  Future<void> loadGame() async {
    print("Attempting to load game state...");

    // Load Player Stats — always saved with id=1 (see saveGame)
    final savedStats = await isar.playerStats.get(1);
    if (savedStats != null) {
      final problem = _validateStats(savedStats);
      if (problem != null) {
        print("Saved PlayerStats corrupt ($problem). Discarding and using defaults.");
        // Leave the provider at its default state; corrupt save will be
        // overwritten on the next saveGame() call.
      } else {
        print(
          "Loaded PlayerStats: Level ${savedStats.level}, Coins ${savedStats.coins}",
        );
        container.read(playerStatsProvider.notifier).loadStats(savedStats);
      }
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
      // Each unfilled cell gets the correct row/col so _assertValidGrid passes
      // even on partial saves (fewer tiles than rowCount*colCount).
      final loadedGrid = List.generate(
        rowCount,
        (r) => List.generate(
          colCount,
          (c) => TileData(row: r, col: c, baseImagePath: defaultEmptyBase),
        ),
      );
      bool gridValid = true;
      for (final tile in savedTiles) {
        if (tile.row < rowCount && tile.col < colCount) {
          // Drop corrupt generator tiles that have no item to produce — they
          // would crash at activateGenerator() with a null dereference.
          if (tile.isGenerator && tile.generatesItemPath == null) {
            print(
              "Warning: Generator at (${tile.row}, ${tile.col}) has no generatesItemPath. Resetting to empty.",
            );
            gridValid = false;
            continue;
          }
          loadedGrid[tile.row][tile.col] = tile;
        } else {
          print(
            "Warning: Loaded tile out of bounds (${tile.row}, ${tile.col}). Skipping.",
          );
          gridValid = false;
        }
      }

      if (gridValid) {
        // Route through loadGrid() so _assertValidGrid() runs in debug builds.
        container.read(gridProvider.notifier).loadGrid(loadedGrid);
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
      // Cap at 3 to guard against corrupted saves with extra orders.
      final capped = savedOrders.take(3).toList();
      print("Loaded ${capped.length} orders (${savedOrders.length} in DB).");
      container.read(orderProvider.notifier).state = capped;
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
        // Clear each collection individually so unrelated collections are not
        // wiped if new collections are added in future.  This is safe because
        // the entire block is one atomic Isar transaction — if it fails, Isar
        // rolls back the whole thing, so we never end up with an empty DB.
        await isar.playerStats.clear();
        await isar.tileDatas.clear();
        await isar.orders.clear();

        // Save Player Stats — copy the state object so we never mutate the
        // live provider state (which is an Isar model with an `id` field).
        final statsToSave = playerStats.copyWith()..id = 1;
        await isar.playerStats.put(statsToSave);
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
