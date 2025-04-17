import 'package:flutter/material.dart';

// Hiding buildTileContent to avoid conflicts
// ignore: non_constant_identifier_names
export 'package:flutter/material.dart' hide buildTileContent;

// --- Helper Methods ---
Widget buildTileContent(
  String pathOrEmoji, {
  BoxFit fit = BoxFit.contain,
  double size = 28,
}) {
  if (pathOrEmoji.contains('/')) {
    return Image.asset(
      pathOrEmoji,
      fit: fit,
      errorBuilder:
          (context, error, stackTrace) => Center(
            child: Icon(
              Icons.error_outline,
              color: Colors.red.shade300,
              size: size * 0.8,
            ),
          ),
    );
  } else {
    return Center(child: Text(pathOrEmoji, style: TextStyle(fontSize: size)));
  }
}

// --- Helper for Top HUD Resources ---
Widget buildTopResource({
  required String icon,
  required String value,
  String? cooldown,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min, // Prevent column taking too much space
    children: [
      Text(icon, style: const TextStyle(fontSize: 18)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      if (cooldown != null)
        Text(
          cooldown,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ), // Adjusted color
        ),
    ],
  );
}
