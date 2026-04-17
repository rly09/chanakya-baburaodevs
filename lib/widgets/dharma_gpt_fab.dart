import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/app_colors.dart';
import '../main.dart';

class DharmaGptFab extends StatelessWidget {
  const DharmaGptFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.cyanTrend.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag:
            'dharma_gpt_fab_${DateTime.now().microsecondsSinceEpoch}', // Unique tag to prevent hero animation errors when multiple screens have it
        backgroundColor: AppColors.obsidianBackground,
        onPressed: () {
          globalNavigatorKey.currentState?.pushNamed('/dharma-gpt');
        },
        child: Container(
          padding: const EdgeInsets.all(4), // tighter padding for minimal look
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.obsidianBackground, // ensure perfect blending
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/dharma_gpt_minimal.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
