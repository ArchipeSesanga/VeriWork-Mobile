import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
    final size = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallHeight = constraints.maxHeight < 500;
        final imageHeight = isSmallHeight ? size.height * 0.35 : 500.0;
        final titleFontSize = isSmallHeight ? 22.0 : 28.0;
        final descFontSize = isSmallHeight ? 16.0 : 20.0;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    lottieAsset,
                    height: imageHeight,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Unbounded',
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: descFontSize,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
