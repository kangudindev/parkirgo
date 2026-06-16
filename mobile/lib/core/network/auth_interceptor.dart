import 'package:dio/dio.dart';

import '../constants/constants.dart';
import '../storage/local_database.dart';

/// Dio interceptor that:
/// 1. Injects `Authorization: Bearer <token>` from Hive on every request.
/// 2. Surfaces 401 responses so the auth bloc can sign the user out.
///
/// The token is read from [LocalDatabase.authToken] (Hive) and is never
/// logged — see pretty_dio_logger in [DioClient] for the rest.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.localDb});

  final LocalDatabase localDb;

  /// Routes that must NOT receive a Bearer token (the login endpoint
  /// would 401 if it sent the expired/garbage token it has).
  static const Set<String> _unauthenticatedPaths = {
    '/login/qr',
  };

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final path = options.path;
    if (_unauthenticatedPaths.contains(path)) {
      return handler.next(options);
    }

    final token = localDb.authToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Tell the backend we want JSON, not HTML.
    options.headers['Accept'] = 'application/json';

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // The bloc layer reacts to ApiException(401) and signs the user out.
    // We just propagate the error — no silent retries here.
    if (err.response?.statusCode == 401) {
      // Optionally clear the local token so the next request doesn't keep
      // retrying with a bad one.
      // localDb.clearAuth();
    }
    handler.next(err);
  }
}

/// Adds a small `X-Device-Id` + `X-Client-Version` header pair on every
/// request. Useful for the backend's audit log.
class DeviceHeaderInterceptor extends Interceptor {
  DeviceHeaderInterceptor({required this.localDb});

  final LocalDatabase localDb;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers['X-Client'] = 'parkirgo-mobile';
    options.headers['X-Client-Version'] = '1.0.0';
    final deviceId = localDb.deviceId;
    if (deviceId != null && deviceId.isNotEmpty) {
      options.headers['X-Device-Id'] = deviceId;
    }
    handler.next(options);
  }
}

/// Helper constants exposed for tests and the auth bloc.
class AuthHeader {
  AuthHeader._();
  static const String authorization = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const Duration tokenLifetime = AppConstants.tokenLifetime;
}
