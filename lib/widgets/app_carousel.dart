import 'package:flutter/material.dart';
import '../services/app_colors.dart';
import 'cached_image.dart';

class AppCarousel extends StatelessWidget {
  final List<String> images;
  final double height;
  final BoxFit fit;

  const AppCarousel({
    super.key,
    required this.images,
    this.height = 220,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        height: height,
        color: AppColors.surfaceLight,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted, size: 40),
        ),
      );
    }

    final currentPageNotifier = ValueNotifier<int>(0);

    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) => currentPageNotifier.value = index,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedImage(
                  url: images[index],
                  height: height,
                  width: double.infinity,
                  fit: fit,
                ),
              );
            },
          ),
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ValueListenableBuilder<int>(
                valueListenable: currentPageNotifier,
                builder: (context, currentPage, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentPage == i
                              ? AppColors.primaryColor
                              : Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
