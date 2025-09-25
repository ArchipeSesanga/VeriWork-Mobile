import 'package:flutter/material.dart';
import 'package:veriwork_app/views/pages/welcome_page.dart';
import 'package:veriwork_app/widgets/onboarding_items.dart';
import 'package:veriwork_app/widgets/my_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Verify Your Status",
      "description":
          "Quickly verify your employment status with secure authentication",
      "lottie": "assets/lottie/verify.json",
    },
    {
      "title": "Update Your Profile",
      "description": "Keep your profile up to date with the latest information",
      "lottie": "assets/lottie/update_profile.json",
    },
  ];

  bool get isLastPage => currentIndex == onboardingData.length - 1;

  void _nextPage() {
    if (isLastPage) {
      _navigateToMainPage();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      onboardingData.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToMainPage() {
    // TODO: Replace with actual navigation
    print('Navigate to main page');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PNG Background
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png", // <-- use your PNG
              fit: BoxFit.cover,
            ),
          ),

          // Skip button (top-right)
          if (!isLastPage)
            Positioned(
              top: 40, // adjust for status bar
              right: 16,
              child: TextButton(
                onPressed: _skipToEnd,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white, // White so it's visible on bg
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemCount: onboardingData.length,
                    itemBuilder: (context, index) {
                      final item = onboardingData[index];
                      return OnboardingItem(
                        title: item["title"]!,
                        description: item["description"]!,
                        lottieAsset: item["lottie"]!,
                      );
                    },
                  ),
                ),

                // Page indicators
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? Colors.blue
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom navigation
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button (visible after first page)
                      if (currentIndex > 0)
                        GestureDetector(
                          onTap: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.black87,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 48), // Spacer

                      // Next/Get Started button
                      isLastPage
                          ? MyButton(
                              title: 'Get Started',
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const WelcomeScreen(),
                                  ),
                                );
                              },
                              color: Colors.blue,
                            )
                          : GestureDetector(
                              onTap: _nextPage,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
