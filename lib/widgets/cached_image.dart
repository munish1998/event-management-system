import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

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

  static const String defaultFallbackImage =
      'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800';

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    final trimmed = url.trim();
    if (trimmed.startsWith('data:image')) {
      try {
        final commaIndex = trimmed.indexOf(',');
        final rawBase64 = commaIndex != -1 ? trimmed.substring(commaIndex + 1) : trimmed;
        final bytes = base64Decode(rawBase64);
        imageWidget = Image.memory(
          bytes,
          height: height,
          width: width ?? double.infinity,
          fit: fit,
          errorBuilder: (ctx, err, stack) => _buildFallbackWidget(),
        );
      } catch (e) {
        debugPrint("Base64 image decode error: $e");
        imageWidget = _buildFallbackWidget();
      }
    } else if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      imageWidget = Image.network(
        trimmed,
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          if (trimmed != defaultFallbackImage) {
            return Image.network(
              defaultFallbackImage,
              height: height,
              width: width ?? double.infinity,
              fit: fit,
              errorBuilder: (ctx, err, stack) => _buildFallbackWidget(),
            );
          }
          return _buildFallbackWidget();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget();
        },
      );
    } else if (trimmed.startsWith('assets/')) {
      imageWidget = Image.asset(
        trimmed,
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallbackWidget(),
      );
    } else if (trimmed.isNotEmpty) {
      final file = File(trimmed);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          height: height,
          width: width ?? double.infinity,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallbackWidget(),
        );
      } else {
        imageWidget = Image.network(
          defaultFallbackImage,
          height: height,
          width: width ?? double.infinity,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallbackWidget(),
        );
      }
    } else {
      imageWidget = Image.network(
        defaultFallbackImage,
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallbackWidget(),
      );
    }

    return Stack(
      children: [
        imageWidget,
        ?child,
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: height ?? 180,
      width: width ?? double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff2A2A2A), Color(0xff1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xffF2AF34)),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackWidget() {
    return Container(
      height: height ?? 180,
      width: width ?? double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff2A241A), Color(0xff1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_seat_rounded,
              color: Color(0xffF2AF34),
              size: 36,
            ),
            SizedBox(height: 6),
            Text(
              "EVENT PASS",
              style: TextStyle(
                color: Color(0xffF2AF34),
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
