import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/remote/supervisor_remote_ds.dart';

class ZoneReportPage extends StatefulWidget {
  const ZoneReportPage({super.key});

  @override
  State<ZoneReportPage> createState() => _ZoneReportPageState();
}

class _ZoneReportPageState extends State<ZoneReportPage> {
  List<Map<String, dynamic>> _monitoring = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final sup = context.read<SupervisorRemoteDatasource>();
      final mon = await sup.getMonitoring();
      if (mounted) {
        setState(() {
          _monitoring = mon;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hadirCount = _monitoring.where((j) => j['has_attendance'] == true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Zona'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(child: _statCard('Jukir', '${_monitoring.length}', Icons.people, AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _statCard('Hadir', '$hadirCount', Icons.check_circle, AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _statCard('Tidak Hadir', '${_monitoring.length - hadirCount}', Icons.cancel, AppColors.error)),
                      const SizedBox(width: 12),
                      Expanded(child: _statCard('Kehadiran', hadirCount > 0 ? '${(hadirCount / _monitoring.length * 100).toStringAsFixed(0)}%' : '0%', Icons.trending_up, AppColors.info)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Detail laporan lengkap tersedia di Web Dashboard Admin.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
