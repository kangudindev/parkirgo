/// App-wide constants — storage keys, timeouts, pagination, etc.
///
/// All magic strings/numbers must live here (or in `api_url.dart`), never
/// inline in widgets or repositories.
class AppConstants {
  AppConstants._();

  // ── App meta ────────────────────────────────────────────────────────
  static const String appName = 'ParkirGo';
  static const String appTagline = 'Aplikasi Jukir Pintar';

  // ── Hive box names ──────────────────────────────────────────────────
  static const String hiveBoxAuth = 'auth';
  static const String hiveBoxCacheZones = 'cache_zones';
  static const String hiveBoxCacheVehicleTypes = 'cache_vehicle_types';
  static const String hiveBoxPendingSync = 'pending_sync';
  static const String hiveBoxSessions = 'parking_sessions';
  static const String hiveBoxTransactions = 'transactions';
  static const String hiveBoxAttendances = 'attendances';

  // ── Storage keys (SharedPreferences) ────────────────────────────────
  static const String prefAuthToken = 'auth_token';
  static const String prefAuthExpiresAt = 'auth_expires_at';
  static const String prefUserId = 'user_id';
  static const String prefUserRole = 'user_role';
  static const String prefUserName = 'user_name';
  static const String prefUserZoneId = 'user_zone_id';
  static const String prefUserZoneName = 'user_zone_name';
  static const String prefOnboarded = 'onboarded';
  static const String prefLastSyncAt = 'last_sync_at';
  static const String prefDeviceId = 'device_id';

  // ── Timeouts ────────────────────────────────────────────────────────
  static const Duration httpConnectTimeout = Duration(seconds: 30);
  static const Duration httpReceiveTimeout = Duration(seconds: 60);
  static const Duration httpSendTimeout = Duration(seconds: 30);

  // Token validity is 8h per backend (`AuthController::loginQr`).
  static const Duration tokenLifetime = Duration(hours: 8);

  // ── Pagination ──────────────────────────────────────────────────────
  static const int pageSize = 50;

  // ── Camera / Scanner defaults ───────────────────────────────────────
  static const Duration cameraCaptureTimeout = Duration(seconds: 30);
  static const int imageMaxWidth = 1920;
  static const int imageMaxHeight = 1080;
  static const int imageQuality = 85;

  // ── Parkir-specific ─────────────────────────────────────────────────
  /// Maximum plate length the form accepts.
  static const int maxPlateLength = 12;

  /// Indonesian format for rupiah formatting via `intl`.
  static const String localeId = 'id_ID';
  static const String currencyIdr = 'Rp';

  // ── Indonesia default lat/lng for the geofence fallback ────────────
  static const double defaultLatitude = -6.2088;
  static const double defaultLongitude = 106.8456;
}
