import 'package:flutter/material.dart';

/// A styled bottom info bar, reminiscent of the 'Seashell' hint card.
class BottomInfoBar extends StatelessWidget {
  final String text;
  final VoidCallback? onInfoPressed;

  const BottomInfoBar({super.key, required this.text, this.onInfoPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E4D3), // light tan background
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 8.0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(0, -2),
            blurRadius: 4.0,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onInfoPressed,
            child: const Icon(
              Icons.info_outline,
              size: 24,
              color: Colors.brown,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.brown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
