import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class OnboardingItem {
  final String category;
  final String title;
  final String description;
  final String imageUrl;
  final IconData icon;

  const OnboardingItem({
    required this.category,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.icon,
  });
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const List<OnboardingItem> pages = [
    OnboardingItem(
      category: 'MY EVENTS',
      title: 'The all-in-one tool for event organisers',
      description: 'Every event, one tap away. Manage ticket sales, checked-in counts, and registrations in real-time.',
      imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=1000',
      icon: Icons.event_available_rounded,
    ),
    OnboardingItem(
      category: 'REGISTRATIONS',
      title: 'Know who\'s coming before they arrive',
      description: 'Search attendee passes, track Explorer & VIP tickets, and perform instant check-ins.',
      imageUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?q=80&w=1000',
      icon: Icons.people_alt_rounded,
    ),
    OnboardingItem(
      category: 'ANALYTICS',
      title: 'Live analytics. Zero guesswork.',
      description: 'Track Revenue Trends, Ticket Trends, Page Visits, and Ticket Source breakdowns live.',
      imageUrl: 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?q=80&w=1000',
      icon: Icons.bar_chart_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    final currentPageNotifier = ValueNotifier<int>(0);

    void navigateToLogin() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: Branding + Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.event_seat_rounded, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'allevents',
                        style: AppTypography.headingSmall.copyWith(
                          fontSize: 18,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: navigateToLogin,
                    child: Text(
                      'Skip',
                      style: AppTypography.button.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Onboarding PageView
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: pages.length,
                onPageChanged: (index) => currentPageNotifier.value = index,
                itemBuilder: (context, index) {
                  final item = pages[index];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        // Image Card with Overlay Icon
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.network(
                                item.imageUrl,
                                height: 260,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 260,
                                  color: AppColors.surfaceSecondary,
                                  child: const Icon(Icons.image, size: 60, color: AppColors.textMuted),
                                ),
                              ),
                            ),
                            Container(
                              height: 260,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.background.withValues(alpha: 0.85),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.4),
                                      blurRadius: 18,
                                    ),
                                  ],
                                ),
                                child: Icon(item.icon, color: Colors.white, size: 32),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Category Pill & Title Card
                        GlassContainer(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                item.category,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.title,
                                style: AppTypography.headingMedium.copyWith(color: AppColors.primaryDark),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.description,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area: Page Indicators & Action Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Dot Indicators
                  ValueListenableBuilder<int>(
                    valueListenable: currentPageNotifier,
                    builder: (context, currentPage, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: currentPage == i ? 32 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: currentPage == i
                                  ? AppColors.primary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Next / Get Started Button
                  ValueListenableBuilder<int>(
                    valueListenable: currentPageNotifier,
                    builder: (context, currentPage, child) {
                      final isLastPage = currentPage == pages.length - 1;

                      return CustomButton(
                        label: isLastPage ? 'Get Started 🎉' : 'Continue',
                        icon: isLastPage ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                        gradient: AppColors.primaryGradient,
                        onPressed: () {
                          if (isLastPage) {
                            navigateToLogin();
                          } else {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
