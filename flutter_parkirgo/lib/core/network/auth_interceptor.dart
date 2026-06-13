import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/constants.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._box);

  final Box _box;

  String? get token => _box.get(AppConstants.tokenKey) as String?;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final currentToken = token;
    if (currentToken != null && currentToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $currentToken';
    }
    super.onRequest(options, handler);
  }

  bool get isTokenExpired {
    final expiry = _box.get(AppConstants.tokenExpiryKey) as String?;
    if (expiry == null) return true;
    return DateTime.now().isAfter(DateTime.tryParse(expiry) ?? DateTime.now());
  }

  Future<void> saveAuth({
    required String token,
    required String expiresAt,
    required Map<String, dynamic> user,
  }) async {
    await _box.put(AppConstants.tokenKey, token);
    await _box.put(AppConstants.tokenExpiryKey, expiresAt);
    await _box.put(AppConstants.userDataKey, jsonEncode(user));
  }

  Future<void> clearAuth() async {
    await _box.delete(AppConstants.tokenKey);
    await _box.delete(AppConstants.tokenExpiryKey);
    await _box.delete(AppConstants.userDataKey);
  }
}
