import 'package:flutter/material.dart';
import  'package:lottie/lottie.dart';

class OnboardingItem extends StatelessWidget {
  final String title;
  final String description;
  final String lottieAsset;

  const OnboardingItem({
    super.key,
    required this.title,
    required this.description,
    required this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            lottieAsset,
            height: 500,
            repeat: true,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Unbounded',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              // readable on background
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
