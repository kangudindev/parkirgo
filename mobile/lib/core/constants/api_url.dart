/// API base URL + endpoint paths for ParkirGo backend.
///
/// Default points to the Android emulator host loopback (`10.0.2.2:8000`).
/// Override at build time with `--dart-define=API_BASE_URL=...` for iOS,
/// physical devices, or staging environments.
class ApiUrl {
  ApiUrl._();

  /// Base URL for the API. Android emulator → 10.0.2.2 hits the host
  /// machine. iOS simulator → 127.0.0.1 / localhost.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  // ── Auth ────────────────────────────────────────────────────────────
  static const String loginQr = '/login/qr';
  static const String logout = '/logout';
  static const String me = '/me';

  // ── Zones & vehicle types ───────────────────────────────────────────
  static const String zones = '/zones';

  // ── Attendances ─────────────────────────────────────────────────────
  static const String attendances = '/attendances';

  // ── Parking sessions ────────────────────────────────────────────────
  static const String parkingSessions = '/parking-sessions';
  static String parkingSessionByTicket(String ticket) =>
      '/parking-sessions/by-ticket/$ticket';
  static String parkingSessionClose(int id) => '/parking-sessions/$id/close';
  static String parkingSessionForceExit(int id) =>
      '/parking-sessions/$id/force-exit';
  static const String parkingSessionUnregisteredExit =
      '/parking-sessions/unregistered-exit';

  // ── Transactions ────────────────────────────────────────────────────
  static const String transactions = '/transactions';
  static const String transactionsVerify = '/transactions/verify';

  // ── Penalties ───────────────────────────────────────────────────────
  static const String penaltiesByZoneType = '/penalties/by-zone-type';

  // ── Settlements ─────────────────────────────────────────────────────
  static const String settlements = '/settlements';
  static const String settlementsApprove = '/settlements/approve';

  // ── Sync ────────────────────────────────────────────────────────────
  static const String syncBatch = '/sync/batch';

  // ── Supervisor ──────────────────────────────────────────────────────
  static const String supervisorMonitoring = '/supervisor/monitoring';
  static const String supervisorPendingQris = '/supervisor/pending-qris';

  // ── Uploads ─────────────────────────────────────────────────────────
  static const String upload = '/upload';
}
