import 'dart:io';
import 'package:flutter/material.dart';
import '../services/app_colors.dart';
import 'loading_widget.dart';

class CachedImage extends StatelessWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget? child;

  const CachedImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      imageWidget = Image.network(
        trimmed,
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height ?? 180,
            width: width ?? double.infinity,
            color: AppColors.surfaceLight,
            child: const LoadingWidget(size: 28),
          );
        },
      );
    } else if (trimmed.startsWith('assets/')) {
      imageWidget = Image.asset(
        trimmed,
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else if (trimmed.isNotEmpty) {
      final file = File(trimmed);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          height: height,
          width: width ?? double.infinity,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      } else {
        imageWidget = Image.network(
          trimmed,
          height: height,
          width: width ?? double.infinity,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      }
    } else {
      imageWidget = _buildErrorWidget();
    }

    return Stack(
      children: [
        imageWidget,
        if (child != null) child!,
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: height ?? 180,
      width: width ?? double.infinity,
      color: AppColors.surfaceLight,
      child: const Center(
        child: Icon(Icons.broken_image_rounded, color: AppColors.textMuted, size: 36),
      ),
    );
  }
}
