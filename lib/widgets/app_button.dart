import 'package:flutter/material.dart';
import '../services/app_colors.dart';
import 'loading_widget.dart';

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? color;
  final Gradient? gradient;

  const AppButton({
    super.key,
    required this.title,
    this.onTap,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
    this.gradient,
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
          onTap: isLoading ? null : onTap,
          child: AnimatedScale(
            scale: isPressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: isOutlined ? null : (gradient ?? AppColors.primaryGradient),
                color: isOutlined ? Colors.transparent : color,
                borderRadius: BorderRadius.circular(24),
                border: isOutlined
                    ? Border.all(color: AppColors.primaryColor, width: 1.5)
                    : null,
                boxShadow: isOutlined
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: isLoading
                    ? LoadingWidget(
                        color: isOutlined ? AppColors.primaryColor : Colors.white,
                        size: 24,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              color: isOutlined ? AppColors.primaryColor : Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            title,
                            style: TextStyle(
                              color: isOutlined ? AppColors.primaryColor : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
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
