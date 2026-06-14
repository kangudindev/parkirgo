import '../constants/constants.dart';

class LocalDatabase {
  LocalDatabase._internal();
  static final LocalDatabase _instance = LocalDatabase._internal();
  static LocalDatabase get instance => _instance;

  final Map<String, dynamic> _store = {};

  Future<void> init() async {}

  String? getString(String key) => _store[key] as String?;
  Future<void> setString(String key, String value) async => _store[key] = value;

  int? getInt(String key) => _store[key] as int?;
  Future<void> setInt(String key, int value) async => _store[key] = value;

  bool? getBool(String key) => _store[key] as bool?;
  Future<void> setBool(String key, bool value) async => _store[key] = value;

  dynamic get(String key) => _store[key];
  Future<void> put(String key, dynamic value) async => _store[key] = value;

  Future<void> remove(String key) async => _store.remove(key);

  void clearAuth() {
    _store.remove(AppConstants.tokenKey);
    _store.remove(AppConstants.userKey);
    _store.remove(AppConstants.refreshTokenKey);
  }
}
