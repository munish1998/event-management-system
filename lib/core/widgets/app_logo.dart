import 'package:flutter/material.dart';

class AppLogoWidget extends StatelessWidget {
  final double size;
  final bool showGlow;

  const AppLogoWidget({
    super.key,
    this.size = 110,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(
                color: const Color(0xFFF5A623),
                width: 2.0,
              ),
              boxShadow: showGlow
                  ? [
                      BoxShadow(
                        color: const Color(0xFFF5A623).withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [

                Container(
                  width: size * 0.82,
                  height: size * 0.82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x66F5A623),
                      width: 1.0,
                    ),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: size * 0.32,
                      color: const Color(0xFFF5A623),
                    ),
                    const SizedBox(height: 2),
                    Icon(
                      Icons.pan_tool_alt_rounded,
                      size: size * 0.22,
                      color: const Color(0xFFFFC25C),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
