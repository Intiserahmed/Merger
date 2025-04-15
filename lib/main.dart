import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
// Import your main screen widget if it's in a separate file
import 'widgets/game_grid_screen.dart';

// Wrap your MyApp widget with ProviderScope
void main() {
  runApp(
    const ProviderScope(
      // Add ProviderScope here
      child: MyApp(),
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
