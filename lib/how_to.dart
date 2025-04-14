import 'package:flutter/material.dart';

class HowToProgressOverlay extends StatelessWidget {
  const HowToProgressOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7), // Dimmed background
      body: GestureDetector(
        onTap: () => Navigator.pop(context), // Tap anywhere to close
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              const Text(
                "HOW TO\nPROGRESS",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Steps
              _buildStep(
                number: 1,
                iconPath: "assets/icons/create_item.png",
                label: "CREATE\nITEMS",
              ),
              _buildStep(
                number: 2,
                iconPath: "assets/icons/merge_item.png",
                label: "MERGE\nITEMS",
              ),
              _buildStep(
                number: 3,
                iconPath: "assets/icons/order_go.png",
                label: "FULFILL\nORDERS",
              ),
              _buildStep(
                number: 4,
                iconPath: "assets/icons/map_upgrade.png",
                label: "TAP THE MAP\nTO UPGRADE THE TOWN",
              ),
              const SizedBox(height: 40),

              // Tap to close
              const Text(
                "Tap to close",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required int number,
    required String iconPath,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$number",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(iconPath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
