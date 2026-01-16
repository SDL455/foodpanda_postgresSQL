import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'ຫາກໍ່ນີ້';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ນາທີກ່ອນ';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ຊົ່ວໂມງກ່ອນ';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ມື້ກ່ອນ';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ອາທິດກ່ອນ';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ເດືອນກ່ອນ';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ປີກ່ອນ';
    }
  }

  static String formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == today) {
      // Today - show time only
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'ມື້ວານ ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      // This week - show day name
      return '${_getLaoDayName(dateTime.weekday)} ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      // Older - show full date
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  static String _getLaoDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'ຈັນ';
      case 2:
        return 'ອັງຄານ';
      case 3:
        return 'ພຸດ';
      case 4:
        return 'ພະຫັດ';
      case 5:
        return 'ສຸກ';
      case 6:
        return 'ເສົາ';
      case 7:
        return 'ອາທິດ';
      default:
        return '';
    }
  }
}

