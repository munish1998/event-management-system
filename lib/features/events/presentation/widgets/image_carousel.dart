import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/cached_image.dart';

class ImageCarouselWidget extends StatelessWidget {
  final List<String> images;
  final double height;

  const ImageCarouselWidget({
    super.key,
    required this.images,
    this.height = 240,
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
              return CachedImage(
                url: images[index],
                width: double.infinity,
                height: height,
                fit: BoxFit.cover,
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
                              ? AppColors.primary
                              : Colors.white.withValues(alpha: 0.5),
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
