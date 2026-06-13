class AppConstants {
  AppConstants._();

  static const String appName = 'ParkirGo';
  static const String tokenKey = 'auth_token';
  static const String tokenExpiryKey = 'token_expires_at';
  static const String userDataKey = 'user_data';
  static const String zoneDataKey = 'zones_cache';
  static const String lastSyncKey = 'last_sync_at';
  static const String printerKey = 'printer_address';
  static const String paperSizeKey = 'paper_size'; // '58' or '80'

  static const int tokenExpiryHours = 8;
  static const int syncIntervalMinutes = 5;
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration scanTimeout = Duration(seconds: 60);
}
