import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'app_colors.dart';
import 'enum.dart';

class Utils {
  static void showFlushBar(
    String message,
    FlushBarType flushBarType,
    BuildContext context, {
    Widget? child,
  }) {
    showTopSnackBar(
      Overlay.of(context),
      child ??
          Flushbar(
            flushbarPosition: FlushbarPosition.TOP,
            forwardAnimationCurve: Curves.decelerate,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(15),
            message: message,
            messageColor: flushBarType == FlushBarType.warn
                ? Colors.black
                : Colors.white,
            duration: const Duration(seconds: 2),
            backgroundColor: flushBarType == FlushBarType.success
                ? Colors.green
                : flushBarType == FlushBarType.error
                ? Colors.red
                : Colors.amber.shade700,
            borderRadius: BorderRadius.circular(10),
            icon: Icon(
              flushBarType == FlushBarType.success
                  ? Icons.check_circle
                  : flushBarType == FlushBarType.error
                  ? Icons.error
                  : Icons.warning,
              color: flushBarType == FlushBarType.warn
                  ? Colors.black
                  : Colors.white,
            ),
          ),
    );
  }

  static Future<void> showLogoutDialog(
    BuildContext context, {
    required VoidCallback onConfirmLogout,
  }) async {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Confirm Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirmLogout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String formatDateShort(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  static String formatTimeOnly(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $ampm';
  }

  static Map<String, int> getRemainingTime(DateTime targetDate) {
    final difference = targetDate.difference(DateTime.now());
    if (difference.isNegative) {
      return {'days': 0, 'hours': 0, 'minutes': 0, 'seconds': 0};
    }
    return {
      'days': difference.inDays,
      'hours': difference.inHours % 24,
      'minutes': difference.inMinutes % 60,
      'seconds': difference.inSeconds % 60,
    };
  }
}
