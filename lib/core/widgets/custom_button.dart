import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../widgets/loading_widget.dart';
import '../constants/app_typography.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final bool isLoading;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.gradient,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPressedNotifier = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isPressedNotifier,
      builder: (context, isPressed, child) {
        return GestureDetector(
          onTapDown: (_) => isPressedNotifier.value = true,
          onTapUp: (_) => isPressedNotifier.value = false,
          onTapCancel: () => isPressedNotifier.value = false,
          onTap: isLoading ? null : onPressed,
          child: AnimatedScale(
            scale: isPressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: isOutlined
                    ? null
                    : (gradient ?? AppColors.primaryGradient),
                color: isOutlined ? Colors.transparent : null,
                borderRadius: BorderRadius.circular(14),
                border: isOutlined
                    ? Border.all(color: AppColors.primary, width: 1.5)
                    : null,
                boxShadow: isOutlined
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: isLoading
                    ? const LoadingWidget(color: Colors.white, size: 24)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              color: isOutlined ? AppColors.primary : Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            label,
                            style: AppTypography.button.copyWith(
                              color: isOutlined ? AppColors.primary : Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
