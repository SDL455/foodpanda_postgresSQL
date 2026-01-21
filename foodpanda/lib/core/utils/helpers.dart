import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class Helpers {
  Helpers._();

  // Format Currency
  static String formatCurrency(num amount) {
    final formatter = NumberFormat('#,###', 'lo');
    return '${formatter.format(amount)} ກີບ';
  }

  // Format Date
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format DateTime
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Format Time
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // Format Distance
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} ມ';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} ກມ';
    }
  }

  // Format Duration
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes ນາທີ';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '$hours ຊົ່ວໂມງ ${mins > 0 ? '$mins ນາທີ' : ''}';
    }
  }

  // Show Snackbar
  static void showSnackbar({
    required String title,
    required String message,
    bool isError = false,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? AppColors.error : AppColors.success,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  // Show Loading Dialog
  static void showLoading({String? message}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Hide Loading
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  // Show Confirmation Dialog
  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'ຢືນຢັນ',
    String cancelText = 'ຍົກເລີກ',
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Validate Email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate Phone
  static bool isValidPhone(String phone) {
    return RegExp(r'^(20|30)\d{8}$').hasMatch(phone);
  }
}
