import 'package:flutter/material.dart';
import '../../../../widgets/app_shimmer.dart';

class EventCardShimmer extends StatelessWidget {
  const EventCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x33F2AF34), width: 1),
        ),
        child: Column(
          children: [
            // Top Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xff222222),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Shimmer Box
                  const ShimmerBox(
                    width: 90,
                    height: 100,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 12),
                  // Content Details Shimmer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: ShimmerBox(height: 16, borderRadius: 4),
                            ),
                            const SizedBox(width: 12),
                            ShimmerBox(
                              width: 65,
                              height: 18,
                              borderRadius: 10,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const ShimmerBox(
                              width: 14,
                              height: 14,
                              borderRadius: 7,
                            ),
                            const SizedBox(width: 6),
                            const Expanded(
                              child: ShimmerBox(height: 12, borderRadius: 4),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const ShimmerBox(
                              width: 14,
                              height: 14,
                              borderRadius: 7,
                            ),
                            const SizedBox(width: 6),
                            ShimmerBox(
                              width: 110,
                              height: 11,
                              borderRadius: 4,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const ShimmerBox(
                              width: 14,
                              height: 14,
                              borderRadius: 7,
                            ),
                            const SizedBox(width: 6),
                            ShimmerBox(
                              width: 130,
                              height: 11,
                              borderRadius: 4,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Action Bar Shimmer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xff161616),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const ShimmerBox(
                        width: 14,
                        height: 14,
                        borderRadius: 7,
                      ),
                      const SizedBox(width: 6),
                      ShimmerBox(
                        width: 100,
                        height: 11,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const ShimmerBox(
                        width: 24,
                        height: 24,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 10),
                      ShimmerBox(
                        width: 95,
                        height: 28,
                        borderRadius: 16,
                      ),
                    ],
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

/// A helper widget to render multiple shimmer skeleton cards
class EventCardShimmerList extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const EventCardShimmerList({
    super.key,
    this.itemCount = 4,
    this.padding = const EdgeInsets.only(top: 8, bottom: 20),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) => const EventCardShimmer(),
    );
  }
}
