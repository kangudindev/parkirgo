import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/parking_constants.dart';
import '../auth/bloc/auth_bloc.dart';
import '../bloc/home_bloc.dart';

class HomeJukirPage extends StatefulWidget {
  const HomeJukirPage({super.key});

  @override
  State<HomeJukirPage> createState() => _HomeJukirPageState();
}

class _HomeJukirPageState extends State<HomeJukirPage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().loadDashboard();
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final homeState = context.watch<HomeBloc>().state;
    final role = authState.role ?? Role.jukir;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkirGo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<HomeBloc>().loadDashboard(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status kehadiran
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time, color: AppColors.warning),
                title: const Text('Status Kehadiran'),
                subtitle: const Text('Belum absen'),
                trailing: ElevatedButton(
                  onPressed: () => context.push('/attendance'),
                  child: const Text('Absen'),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Stats
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.local_parking, color: AppColors.primary, size: 32),
                          const SizedBox(height: 8),
                          Text('${homeState.activeSessionsCount}',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          const Text('Parkir Aktif', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.money, color: AppColors.success, size: 32),
                          const SizedBox(height: 8),
                          Text(_formatRupiah(homeState.totalRevenue),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          const Text('Estimasi', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tombol Kendaraan Masuk
            ElevatedButton.icon(
              onPressed: () => context.push('/parking-entry'),
              icon: const Icon(Icons.add_circle, size: 28),
              label: const Text('KENDARAAN MASUK', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),

            // Menu list
            _menuItem(context, Icons.list, 'Daftar Parkir Aktif', '/parking-active'),
            _menuItem(context, Icons.history, 'Riwayat Transaksi', '/history'),
            _menuItem(context, Icons.money_off, 'Setoran Akhir Shift', '/settlement'),

            // Supervisor extra menu
            if (role == Role.supervisor) ...[
              const Divider(height: 32),
              const Text('MENU SUPERVISOR',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              _menuItem(context, Icons.people, 'Monitoring Jukir', '/monitoring'),
              _menuItem(context, Icons.verified, 'Verifikasi QRIS', '/verify-qris'),
              _menuItem(context, Icons.bar_chart, 'Laporan Zona', '/report'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, String route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}
