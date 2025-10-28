import 'package:flutter/material.dart';
import 'package:veriwork_mobile/core/constants/routes.dart';
import 'package:veriwork_mobile/widgets/onboarding_items.dart';

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
          "Quickly verify your employment status with secure authentication.",
      "lottie": "assets/lottie/verify.json",
    },
    {
      "title": "Update Your Profile",
      "description":
          "Keep your profile up to date with the latest information.",
      "lottie": "assets/lottie/update_profile.json",
    },
  ];

  bool get isLastPage => currentIndex == onboardingData.length - 1;

  void _nextPage() {
    if (isLastPage) {
      _navigateToWelcome();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToWelcome() {
    print('Onboarding to Welcome');
    Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
  }

  void _skipToLogin() {
    print('Onboarding to Skip to Login');
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),

          // SKIP BUTTON – TextButton (as requested)
          if (!isLastPage)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: TextButton(
                onPressed: _skipToLogin,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                child: const Text("Skip"),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                // Page Content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => currentIndex = index);
                    },
                    itemCount: onboardingData.length,
                    itemBuilder: (context, index) {
                      final item = onboardingData[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.08,
                          vertical: size.height * 0.05,
                        ),
                        child: OnboardingItem(
                          title: item["title"]!,
                          description: item["description"]!,
                          lottieAsset: item["lottie"]!,
                        ),
                      );
                    },
                  ),
                ),

                // Dots Indicator
                Row(
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
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Back + Next Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back
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
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 48),

                      // Next / Finish
                      GestureDetector(
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
