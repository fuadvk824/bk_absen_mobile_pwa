
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';

class ToastHelper {
  static void success(
    BuildContext context, {
    String title = 'Berhasil',
    required String message,
  }) {
    CherryToast.success(
      title: Text(title),
      description: Text(message),
      animationType: AnimationType.fromTop,
      animationDuration: const Duration(milliseconds: 700),
    ).show(context);
  }

  static void error(
    BuildContext context, {
    String title = 'Gagal',
    required String message,
  }) {
    CherryToast.error(
      title: Text(title),
      description: Text(message),
      animationType: AnimationType.fromTop,
      animationDuration: const Duration(milliseconds: 700),
    ).show(context);
  }

  static void warning(
    BuildContext context, {
    String title = 'Peringatan',
    required String message,
  }) {
    CherryToast.warning(
      title: Text(title),
      description: Text(message),
      animationType: AnimationType.fromTop,
      animationDuration: const Duration(milliseconds: 700),
    ).show(context);
  }

  static void info(
    BuildContext context, {
    String title = 'Informasi',
    required String message,
  }) {
    CherryToast.info(
      title: Text(title),
      description: Text(message),
      animationType: AnimationType.fromTop,
      animationDuration: const Duration(milliseconds: 700),
    ).show(context);
  }
}

