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
  late Map<String, int> _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _startTimer();
  }

  void _updateRemaining() {
    _remaining = DateFormatter.getRemainingTime(widget.targetDate);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _updateRemaining();
      });
      // Stop timer if event has already started
      if (_remaining['days'] == 0 &&
          _remaining['hours'] == 0 &&
          _remaining['minutes'] == 0 &&
          _remaining['seconds'] == 0) {
        _timer?.cancel();
      }
    });
  }

  @override
  void didUpdateWidget(covariant CountdownTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetDate != widget.targetDate) {
      _updateRemaining();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const isLiveOrPast = false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimeUnit(_remaining['days'] ?? 0, 'DAYS'),
          _buildDivider(),
          _buildTimeUnit(_remaining['hours'] ?? 0, 'HOURS'),
          _buildDivider(),
          _buildTimeUnit(_remaining['minutes'] ?? 0, 'MINS'),
          _buildDivider(),
          _buildTimeUnit(_remaining['seconds'] ?? 0, 'SECS'),
        ],
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
