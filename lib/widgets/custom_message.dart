import 'package:flutter/material.dart';
import 'app_button.dart';

class CustomMessage extends StatelessWidget {
  final String message;
  final bool showButton;
  final VoidCallback? onTap;
  final Color color;
  final double? fontSize;

  const CustomMessage({
    super.key,
    required this.message,
    this.showButton = false,
    this.onTap,
    this.color = Colors.black87,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: TextStyle(color: color, fontSize: fontSize ?? 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (showButton)
            AppButton(title: "Reload", onTap: onTap ?? () {}),
        ],
      ),
    );
  }
}
