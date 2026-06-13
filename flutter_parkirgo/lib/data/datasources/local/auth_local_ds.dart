import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/constants.dart';

class AuthLocalDatasource {
  AuthLocalDatasource(this._box);

  final Box _box;

  String? get token => _box.get(AppConstants.tokenKey) as String?;
  String? get tokenExpiry => _box.get(AppConstants.tokenExpiryKey) as String?;

  Map<String, dynamic>? get user {
    final raw = _box.get(AppConstants.userDataKey) as String?;
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
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
