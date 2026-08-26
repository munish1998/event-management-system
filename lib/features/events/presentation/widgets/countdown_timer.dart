import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime targetDate;

  const CountdownTimerWidget({super.key, required this.targetDate});

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  late final ValueNotifier<Map<String, int>> remainingNotifier;

  @override
  void initState() {
    super.initState();
    remainingNotifier = ValueNotifier<Map<String, int>>(DateFormatter.getRemainingTime(widget.targetDate));
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final updated = DateFormatter.getRemainingTime(widget.targetDate);
      remainingNotifier.value = updated;

      if (updated['days'] == 0 &&
          updated['hours'] == 0 &&
          updated['minutes'] == 0 &&
          updated['seconds'] == 0) {
        _timer?.cancel();
      }
    });
  }

  @override
  void didUpdateWidget(covariant CountdownTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetDate != widget.targetDate) {
      remainingNotifier.value = DateFormatter.getRemainingTime(widget.targetDate);
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    remainingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: ValueListenableBuilder<Map<String, int>>(
        valueListenable: remainingNotifier,
        builder: (context, remaining, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeUnit(remaining['days'] ?? 0, 'DAYS'),
              _buildDivider(),
              _buildTimeUnit(remaining['hours'] ?? 0, 'HOURS'),
              _buildDivider(),
              _buildTimeUnit(remaining['minutes'] ?? 0, 'MINS'),
              _buildDivider(),
              _buildTimeUnit(remaining['seconds'] ?? 0, 'SECS'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeUnit(int value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: AppTypography.headingMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Text(
      ':',
      style: AppTypography.headingMedium.copyWith(color: AppColors.textMuted),
    );
  }
}
