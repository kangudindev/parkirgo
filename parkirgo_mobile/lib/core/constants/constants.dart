class AppConstants {
  AppConstants._();

  static const String appName = 'ParkirGo';
  static const String appVersion = '1.0.0';

  // Hive box names
  static const String authBoxName = 'auth';
  static const String settingsBoxName = 'settings';
  static const String syncBoxName = 'sync';

  // Keys
  static const String tokenKey = 'token';
  static const String userKey = 'user';
  static const String refreshTokenKey = 'refresh_token';
  static const String roleKey = 'role';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration syncInterval = Duration(minutes: 5);

  // Sync
  static const int maxSyncRetries = 3;
  static const int syncBatchSize = 50;
}
