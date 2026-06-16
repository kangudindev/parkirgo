import 'package:dio/dio.dart';

/// Typed exception for all API failures. Wraps [DioException] so the
/// upper layers don't need to know about Dio.
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.originalError,
  });

  /// Human-readable Indonesian message safe to show to end users.
  final String message;

  /// HTTP status code (e.g. 400, 401, 500). Null for transport errors.
  final int? statusCode;

  /// Backend error code string (e.g. "INVALID_QR", "TOKEN_EXPIRED").
  final String? errorCode;

  /// The original error/exception for logging/debugging.
  final Object? originalError;

  /// True when the failure is connectivity-related (no internet, DNS, etc).
  bool get isNetworkError => statusCode == null;

  /// True when the backend returned 401 — caller should kick the user
  /// back to the login screen.
  bool get isUnauthorized => statusCode == 401;

  /// True when the backend returned 403 — role-based access denied.
  bool get isForbidden => statusCode == 403;

  /// True when the backend returned 404.
  bool get isNotFound => statusCode == 404;

  /// True when the backend returned 5xx — server-side problem.
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() => 'ApiException($statusCode, $errorCode): $message';

  /// Map a [DioException] to an [ApiException]. The mapping follows the
  /// conventions used by Laravel (the backend) — most errors come back
  /// as `{ "message": "...", "errors": {...} }`.
  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final data = response?.data;

    // ── Network / transport ────────────────────────────────────────
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: 'Koneksi timeout. Periksa jaringan Anda.',
        errorCode: 'TIMEOUT',
        originalError: error,
      );
    }
    if (error.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Tidak ada koneksi internet.',
        errorCode: 'NO_CONNECTION',
        originalError: error,
      );
    }
    if (error.type == DioExceptionType.cancel) {
      return ApiException(
        message: 'Permintaan dibatalkan.',
        errorCode: 'CANCELLED',
        originalError: error,
      );
    }

    // ── HTTP error with body ────────────────────────────────────────
    if (response != null) {
      final status = response.statusCode ?? 0;
      final Map<String, dynamic> body = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};

      final code = body['code']?.toString();
      final rawMessage = body['message']?.toString();

      final String userMessage = switch (status) {
        400 => rawMessage ?? 'Permintaan tidak valid.',
        401 => rawMessage ?? 'Sesi Anda telah berakhir. Silakan login ulang.',
        403 => rawMessage ?? 'Anda tidak memiliki akses.',
        404 => rawMessage ?? 'Data tidak ditemukan.',
        422 => _formatValidationError(body) ?? rawMessage ?? 'Data tidak valid.',
        >= 500 && < 600 => 'Terjadi kesalahan pada server. Coba lagi nanti.',
        _ => rawMessage ?? 'Terjadi kesalahan (HTTP $status).',
      };

      return ApiException(
        message: userMessage,
        statusCode: status,
        errorCode: code,
        originalError: error,
      );
    }

    return ApiException(
      message: 'Terjadi kesalahan tidak dikenal.',
      originalError: error,
    );
  }

  static String? _formatValidationError(Map<String, dynamic> body) {
    final errors = body['errors'];
    if (errors is Map) {
      final firstField = errors.values.firstOrNull;
      if (firstField is List && firstField.isNotEmpty) {
        return firstField.first.toString();
      }
    }
    return null;
  }
}
