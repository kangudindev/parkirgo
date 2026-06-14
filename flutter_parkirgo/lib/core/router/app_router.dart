import 'package:go_router/go_router.dart';

import '../../features/auth/pages/scan_qr_page.dart';
import '../../features/auth/pages/splash_page.dart';
import '../../features/attendance/pages/attendance_page.dart';
import '../../features/history/pages/history_page.dart';
import '../../features/home/pages/home_jukir_page.dart';
import '../../features/parking_active/pages/active_sessions_page.dart';
import '../../features/parking_entry/pages/parking_entry_page.dart';
import '../../features/parking_exit/pages/parking_exit_page.dart';
import '../../features/payment/pages/cash_payment_page.dart';
import '../../features/payment/pages/qris_payment_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/settlement/pages/settlement_page.dart';
import '../../features/supervisor/monitoring/pages/monitoring_page.dart';
import '../../features/supervisor/reports/pages/zone_report_page.dart';
import '../../features/supervisor/verification/pages/verify_qris_page.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/scan-qr', builder: (_, __) => const ScanQrPage()),
        GoRoute(path: '/attendance', builder: (_, __) => const AttendancePage()),
        GoRoute(path: '/home-jukir', builder: (_, __) => const HomeJukirPage()),
        GoRoute(path: '/parking-entry', builder: (_, __) => const ParkingEntryPage()),
        GoRoute(path: '/parking-active', builder: (_, __) => const ActiveSessionsPage()),
        GoRoute(path: '/parking-exit', builder: (_, __) => const ParkingExitPage()),
        GoRoute(path: '/parking-exit/cash', builder: (_, __) => const CashPaymentPage()),
        GoRoute(path: '/parking-exit/qris', builder: (_, __) => const QrisPaymentPage()),
        GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
        GoRoute(path: '/settlement', builder: (_, __) => const SettlementPage()),
        GoRoute(path: '/monitoring', builder: (_, __) => const MonitoringPage()),
        GoRoute(path: '/verify-qris', builder: (_, __) => const VerifyQrisPage()),
        GoRoute(path: '/report', builder: (_, __) => const ZoneReportPage()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      ],
    );
  }
}
