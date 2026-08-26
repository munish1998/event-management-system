import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';

class MediaUploadPickerWidget extends StatelessWidget {
  final ValueNotifier<List<String>> imagesNotifier;
  final ValueNotifier<String?> videoNotifier;

  const MediaUploadPickerWidget({
    super.key,
    required this.imagesNotifier,
    required this.videoNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final uploadProgressNotifier = ValueNotifier<double>(0.0);
    final isUploadingNotifier = ValueNotifier<bool>(false);

    void simulateImageUpload() async {
      isUploadingNotifier.value = true;
      uploadProgressNotifier.value = 0.1;
      await Future.delayed(const Duration(milliseconds: 300));
      uploadProgressNotifier.value = 0.4;
      await Future.delayed(const Duration(milliseconds: 300));
      uploadProgressNotifier.value = 0.8;
      await Future.delayed(const Duration(milliseconds: 300));
      uploadProgressNotifier.value = 1.0;

      final sampleImages = [
        'https://images.unsplash.com/photo-1511578314322-379afb476865?q=80&w=1000',
        'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?q=80&w=1000',
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=1000',
        'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=1000',
      ];
      final nextImg = sampleImages[imagesNotifier.value.length % sampleImages.length];
      imagesNotifier.value = [...imagesNotifier.value, nextImg];

      isUploadingNotifier.value = false;
    }

    void simulateVideoUpload() async {
      isUploadingNotifier.value = true;
      uploadProgressNotifier.value = 0.2;
      await Future.delayed(const Duration(milliseconds: 400));
      uploadProgressNotifier.value = 0.6;
      await Future.delayed(const Duration(milliseconds: 400));
      uploadProgressNotifier.value = 1.0;

      videoNotifier.value =
          'https://assets.mixkit.co/videos/preview/mixkit-stage-lights-in-a-concert-41584-large.mp4';
      isUploadingNotifier.value = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Media Upload & Optimization',
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: simulateImageUpload,
                      icon: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary),
                      label: Text(
                        'Add Image (< 300KB)',
                        style: AppTypography.caption.copyWith(color: AppColors.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: simulateVideoUpload,
                      icon: const Icon(Icons.video_call_rounded, color: AppColors.secondary),
                      label: Text(
                        'Add Video (< 5MB)',
                        style: AppTypography.caption.copyWith(color: AppColors.secondary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.secondary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),

              ValueListenableBuilder<bool>(
                valueListenable: isUploadingNotifier,
                builder: (context, isUploading, child) {
                  if (!isUploading) return const SizedBox.shrink();

                  return ValueListenableBuilder<double>(
                    valueListenable: uploadProgressNotifier,
                    builder: (context, progress, child) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Compressing & Uploading Media...',
                                  style: AppTypography.caption.copyWith(color: AppColors.primary),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.surfaceLight,
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        ValueListenableBuilder<List<String>>(
          valueListenable: imagesNotifier,
          builder: (context, images, child) {
            if (images.isEmpty) {
              return Text(
                'No images attached yet (At least 3 recommended)',
                style: AppTypography.caption.copyWith(color: AppColors.textMuted),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attached Images (${images.length})',
                      style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Compressed < 300KB each ✓',
                        style: AppTypography.caption.copyWith(color: Colors.greenAccent, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(images[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 14,
                            child: GestureDetector(
                              onTap: () {
                                final current = List<String>.from(imagesNotifier.value);
                                current.removeAt(index);
                                imagesNotifier.value = current;
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 12),

        ValueListenableBuilder<String?>(
          valueListenable: videoNotifier,
          builder: (context, videoUrl, child) {
            if (videoUrl == null) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.video_file_rounded, color: AppColors.secondary, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Short Video Attached (Max 15s)',
                          style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'Size: 3.4 MB (Compressed < 5MB ✓)',
                          style: AppTypography.caption.copyWith(color: AppColors.secondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    onPressed: () => videoNotifier.value = null,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
