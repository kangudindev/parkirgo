class ApiUrl {
  ApiUrl._();

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://parkirgo.localhost/api',
  );

  static const String v1 = '$baseUrl/v1';

  // Auth
  static const String loginQr = '$v1/login/qr';
  static const String me = '$v1/me';

  // Zones
  static const String zones = '$v1/zones';

  // Attendance
  static const String attendances = '$v1/attendances';

  // Parking Sessions
  static const String parkingSessions = '$v1/parking-sessions';
  static String closeParkingSession(String id) => '$parkingSessions/$id/close';
  static String byTicketParkingSession(String ticket) => '$parkingSessions/by-ticket/$ticket';
  static String forceExit(String id) => '$parkingSessions/$id/force-exit';
  static const String unregisteredExit = '$v1/parking-sessions/unregistered-exit';

  // Transactions
  static const String transactions = '$v1/transactions';

  // Settlements
  static const String settlements = '$v1/settlements';

  // Sync
  static const String syncBatch = '$v1/sync/batch';

  // Upload
  static const String upload = '$v1/upload';

  // Penalties
  static const String penalties = '$v1/penalties';
  static const String penaltyByZoneType = '$v1/penalties/by-zone-type';

  // Supervisor
  static const String supervisorMonitoring = '$v1/supervisor/monitoring';
  static const String supervisorQrisPending = '$v1/supervisor/qris-pending';
  static const String supervisorVerifyQris = '$v1/supervisor/verify-qris';
  static const String supervisorSettlementsPending = '$v1/supervisor/settlements-pending';
  static const String supervisorApproveSettlement = '$v1/supervisor/approve-settlement';
}
