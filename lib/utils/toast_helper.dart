import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:dio/dio.dart';
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

  static String getBackendErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      final errors = data['errors'];

      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            final firstError = value.first;

            if (firstError is String &&
                firstError.trim().isNotEmpty) {
              return firstError;
            }
          }

          if (value is String && value.trim().isNotEmpty) {
            return value;
          }
        }
      }
    }

    return _fallbackMessage(e);
  }

  static String _fallbackMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Koneksi ke server timeout.';

      case DioExceptionType.sendTimeout:
        return 'Pengiriman data ke server timeout.';

      case DioExceptionType.receiveTimeout:
        return 'Server terlalu lama memberikan response.';

      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server.';

      case DioExceptionType.badCertificate:
        return 'Sertifikat server tidak valid.';

      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';

      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  static void errorFromDio(
    BuildContext context,
    DioException e, {
    String title = 'Gagal',
  }) {
    error(
      context,
      title: title,
      message: getBackendErrorMessage(e),
    );
  }
}