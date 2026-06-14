import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioError(dynamic error) {
    return ApiException(
      message: error.message ?? 'Terjadi kesalahan jaringan',
      statusCode: error.response?.statusCode,
    );
  }

  factory ApiException.serverError(int statusCode, String message) {
    return ApiException(message: message, statusCode: statusCode);
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class LoadingOverlay extends StatelessWidget {
  final String? message;
  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
