import 'package:flutter/material.dart';
import 'package:project/pages/login.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class  OnboardingScreen extends StatefulWidget {
  const  OnboardingScreen({super.key});

  @override
  State< OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => isLastPage = index == 2);
                },
                children: [
                  buildPage(
                    image: 'assets/images/onboarding1.jpg',
                    title: 'Order from Top Restaurants',
                    subtitle:
                    'Choose your favorite meals from famous of top-rated restaurants.',
                  ),
                  buildPage(
                    image: 'assets/images/onboarding2.jpg',
                    title: 'Fast & Fresh Delivery',
                    subtitle:
                    'Your food reaches you hot and fresh in just a few minutes.',
                  ),
                  buildPage(
                    image: 'assets/images/onboarding3.jpg',
                    title: 'Enjoy Every Bite!',
                    subtitle:
                    'Track your order and enjoy your meal right at your doorstep.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: const ExpandingDotsEffect(
                activeDotColor: Colors.red,
                dotColor: Colors.black26,
                dotHeight: 10,
                dotWidth: 10,
                expansionFactor: 3,
                spacing: 5,
              ),
            ),
            const SizedBox(height: 40),

            // Bottom Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip Button
                TextButton(
                  onPressed: () {
                    _controller.jumpToPage(2);
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Next or Get Started
                ElevatedButton(
                  onPressed: () {
                    if (isLastPage) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    isLastPage ? "Get Started" : "Next",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: 300),
        const SizedBox(height: 40),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}