import 'package:dio/dio.dart';
import '../services/local_database.dart';
import '../constants/constants.dart';

class AuthInterceptor extends Interceptor {
  final LocalDatabase _localDatabase;

  AuthInterceptor(this._localDatabase);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _localDatabase.getString(AppConstants.tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _localDatabase.clearAuth();
    }
    handler.next(err);
  }
}
