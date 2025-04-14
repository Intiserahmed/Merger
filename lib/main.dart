import 'package:flutter/material.dart';
import 'package:merger/tileData.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const GameGridScreen(),
    );
  }
}

class PurchasePopup extends StatelessWidget {
  const PurchasePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main card container
            Container(
              width: 320,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.brown.shade100, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 30), // Reserved for banner overlap
                  Image.asset(
                    'assets/coin.png',
                    height: 40,
                  ), // Add your coin asset
                  const SizedBox(height: 8),
                  const Text(
                    "Purchase the building",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    height: 40,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Purple Banner
            Positioned(
              top: -35,
              left: 30,
              right: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    "BEACH",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),

            // Red Close Button
            Positioned(
              top: -15,
              right: -15,
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 20,
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A simple class to hold tile merge data from a drag source.
class TileDropData {
  final int row;
  final int col;
  final TileData tileData;

  TileDropData({required this.row, required this.col, required this.tileData});
}

/// Data class for the grid tile.
class TileData {
  final String baseImagePath;
  final String? itemImagePath;
  final int overlayNumber; // 0 means no number

  TileData({
    required this.baseImagePath,
    this.itemImagePath,
    this.overlayNumber = 0,
  });
}

// --- Main Widget ---
class GameGridScreen extends StatefulWidget {
  const GameGridScreen({Key? key}) : super(key: key);

  @override
  State<GameGridScreen> createState() => _GameGridScreenState();
}

class _GameGridScreenState extends State<GameGridScreen> {
  final int rowCount = 11;
  final int colCount = 6;
  late List<List<TileData>> gridData;

  @override
  void initState() {
    super.initState();
    _initializeGridData(); // Initialize the grid state
  }

  // --- Initialize Grid Data ---
  // Adjust these asset paths as needed for your project
  void _initializeGridData() {
    const String sand = 'assets/images/sand.png';
    const String sandGrass = 'assets/images/sand_grass.png';
    const String shell = 'assets/images/shell.png';
    const String castle = 'assets/images/sandcastle.png';
    const String coins = 'assets/images/coins.png';
    const String photo = 'assets/images/photo_frame.png';
    const String star = 'assets/images/starfish.png';

    gridData = List.generate(rowCount, (row) {
      return List.generate(colCount, (col) {
        // --- !!! THIS IS WHERE YOU MAP YOUR IMAGE TO DATA !!! ---
        if (row == 0 && col == 4)
          return TileData(baseImagePath: sand, overlayNumber: 11);
        if (row == 0 && col == 5)
          return TileData(baseImagePath: sand, overlayNumber: 11);
        if (row == 1 && col == 3) return TileData(baseImagePath: sandGrass);
        if (row == 1 && col == 4)
          return TileData(baseImagePath: sand, overlayNumber: 10);
        if (row == 1 && col == 5)
          return TileData(baseImagePath: sand, overlayNumber: 10);
        if (row == 1 && col == 2)
          return TileData(baseImagePath: sand, overlayNumber: 9);

        if (row == 2 && col == 0)
          return TileData(baseImagePath: sand, overlayNumber: 8);
        if (row == 2 && col == 1)
          return TileData(baseImagePath: sand, overlayNumber: 8);
        if (row == 2 && col == 3) return TileData(baseImagePath: sandGrass);

        if (row == 3 && col == 0)
          return TileData(baseImagePath: sand, overlayNumber: 8);
        if (row == 3 && col == 1)
          return TileData(baseImagePath: sand, overlayNumber: 7);
        if (row == 3 && col == 2)
          return TileData(baseImagePath: sand, itemImagePath: photo);
        if (row == 3 && col == 5)
          return TileData(baseImagePath: sand, overlayNumber: 6);
        if (row == 3 && col == 4)
          return TileData(baseImagePath: sand, overlayNumber: 6);

        if (row == 4 && col == 0)
          return TileData(baseImagePath: sand, overlayNumber: 8);
        if (row == 4 && col == 1)
          return TileData(baseImagePath: sand, itemImagePath: castle);
        if (row == 4 && col == 2)
          return TileData(baseImagePath: sand, itemImagePath: coins);
        if (row == 4 && col == 3)
          return TileData(baseImagePath: sand, itemImagePath: star);
        if (row == 4 && col == 4)
          return TileData(baseImagePath: sand, itemImagePath: castle);
        if (row == 4 && col == 5)
          return TileData(baseImagePath: sand, overlayNumber: 6);

        if (row == 5 && col == 0)
          return TileData(baseImagePath: sand, overlayNumber: 8);
        if (row == 5 && col == 1)
          return TileData(baseImagePath: sand, itemImagePath: shell);
        if (row == 5 && col == 2)
          return TileData(baseImagePath: sand, itemImagePath: shell);
        if (row == 6 && col == 0)
          return TileData(baseImagePath: sand, overlayNumber: 8);
        if (row == 6 && col == 1)
          return TileData(baseImagePath: sand, itemImagePath: castle);
        if (row == 6 && col == 2)
          return TileData(baseImagePath: sand, itemImagePath: castle);
        if (row == 7 && col == 0)
          return TileData(baseImagePath: sand, itemImagePath: photo);
        if (row < 2 && col < 4) return TileData(baseImagePath: sandGrass);

        // Default: Plain sand tile.
        return TileData(baseImagePath: sand);
      });
    });
  }

  // --- Build Tile Widget with Drag & Drop ---
  Widget _buildTile(BuildContext context, int index) {
    final int row = index ~/ colCount;
    final int col = index % colCount;
    final TileData tileData = gridData[row][col];

    return DragTarget<TileDropData>(
      onWillAccept: (dragData) {
        // Reject if no data, or if it's the same tile
        if (dragData == null || (dragData.row == row && dragData.col == col))
          return false;

        // Allow merge if both tiles have the same overlay number (> 0).
        if (tileData.overlayNumber > 0 &&
            tileData.overlayNumber == dragData.tileData.overlayNumber) {
          return true;
        }
        return false;
      },
      onAccept: (dragData) {
        setState(() {
          int mergedValue = tileData.overlayNumber + 1;
          gridData[row][col] = TileData(
            baseImagePath: tileData.baseImagePath,
            overlayNumber: mergedValue,
          );
          gridData[dragData.row][dragData.col] = TileData(
            baseImagePath: dragData.tileData.baseImagePath,
          );
        });
      },
      builder: (context, candidateData, rejectedData) {
        // Wrap each tile in a Draggable if it has merge data (here, overlayNumber > 0 or an item).
        Widget content;
        if (tileData.overlayNumber > 0) {
          // Tile displays a number overlay.
          content = Container(
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              color: Colors.orange.shade100.withOpacity(0.85),
              image: const DecorationImage(
                image: AssetImage('assets/images/overlay_texture.png'),
                fit: BoxFit.cover,
                opacity: 0.5,
              ),
              border: Border.all(color: Colors.brown, width: 0.5),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder:
                    (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                child: Text(
                  '${tileData.overlayNumber}',
                  key: ValueKey<int>(
                    tileData.overlayNumber,
                  ), // Key to trigger the change
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black54,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          // Tile displays the base image and an item (if any).
          content = Container(
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.brown, width: 0.5),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(tileData.baseImagePath, fit: BoxFit.cover),
                if (tileData.itemImagePath != null)
                  Image.asset(tileData.itemImagePath!, fit: BoxFit.contain),
              ],
            ),
          );
        }

        // Return the tile wrapped as a draggable.
        return Draggable<TileDropData>(
          data: TileDropData(row: row, col: col, tileData: tileData),
          feedback: Material(
            // Use Material to show the widget properly during dragging.
            color: Colors.transparent,
            child: SizedBox(width: 50, height: 50, child: content),
          ),
          childWhenDragging: Container(
            margin: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              border: Border.all(color: Colors.brown, width: 0.5),
            ),
          ),
          child: content,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Grid Example')),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rowCount * colCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: colCount,
            childAspectRatio: 1.0,
          ),
          itemBuilder: _buildTile,
        ),
      ),
    );
  }
}
