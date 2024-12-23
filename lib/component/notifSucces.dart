import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class Notifsucces {
  static void showNotif({
    required BuildContext context,
    String? description,
    String title = 'Berhasil',
    ToastificationType type = ToastificationType.success,
    ToastificationStyle style = ToastificationStyle.fillColored,
    Color primaryColor = const Color(0xFF28A745),
    Color backgroundColor = Colors.black,
    Color progressBarColor = const Color(0xFFFFFFFF),
    Color progressBarTrackColor = const Color(0xFFCDCDCD),
    Icon icon = const Icon(
      Icons.check_circle_rounded,
      color: Color(0xFFFFFFFF),
    ),
    TextStyle titleStyle = const TextStyle(
      color: Color(0xFFFFFFFF),
      fontWeight: FontWeight.w700,
      fontSize: 12,
    ),
    TextStyle descriptionStyle = const TextStyle(
      color: Color(0xFFFFFFFF),
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
  }) {
    toastification.show(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(right: 16, left: 16),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        autoCloseDuration: const Duration(seconds: 8),
        progressBarTheme: ProgressIndicatorThemeData(
            color: progressBarColor, linearTrackColor: progressBarTrackColor),
        type: type,
        style: style,
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
        context: context,
        showProgressBar: false,
        closeOnClick: true,
        closeButtonShowType: CloseButtonShowType.always,
        icon: icon,
        title: Text(title, style: titleStyle),
        description: Text(
          description!,
          style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.w500,
              fontSize: 12),
        ));
  }
}
