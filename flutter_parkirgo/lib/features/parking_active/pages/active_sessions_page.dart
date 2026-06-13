import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/components/loading_overlay.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/parking_constants.dart';
import '../../data/models/parking_session_model.dart';
import '../bloc/active_sessions_bloc.dart';

class ActiveSessionsPage extends StatefulWidget {
  const ActiveSessionsPage({super.key});

  @override
  State<ActiveSessionsPage> createState() => _ActiveSessionsPageState();
}

class _ActiveSessionsPageState extends State<ActiveSessionsPage> {
  Timer? _timer;
  final DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<ActiveSessionsBloc>().loadSessions();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(DateTime entry) {
    final diff = DateTime.now().difference(entry);
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    final seconds = diff.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}j ${minutes}m ${seconds}d';
    }
    return '${minutes}m ${seconds}d';
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parkir Aktif'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<ActiveSessionsBloc, ActiveSessionsState>(
        builder: (context, state) {
          if (state.isLoading) return const LoadingOverlay();
          if (state.errorMessage != null) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          if (state.sessions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_parking, size: 64, color: AppColors.textDisabled),
                  SizedBox(height: 16),
                  Text('Tidak ada kendaraan parkir aktif'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ActiveSessionsBloc>().loadSessions(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.sessions.length,
              itemBuilder: (context, index) {
                final session = state.sessions[index];
                final entryTime = DateTime.tryParse(session.entryAt ?? '');
                final duration = entryTime != null ? _formatDuration(entryTime) : '-';
                final statusColor = session.paymentStatus == PaymentStatus.paid
                    ? AppColors.paidStatus
                    : AppColors.unpaidStatus;
                final statusLabel = session.paymentStatus == PaymentStatus.paid ? 'LUNAS' : 'BELUM';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.directions_car, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                session.plateNumber ?? '-',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(statusLabel,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('${session.vehicleType ?? '-'} · ${session.ticketNumber ?? '-'}',
                                style: const TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.timer, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(duration,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              ],
                            ),
                            Text(
                              _formatRupiah(session.estimatedAmount ?? 0),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push('/parking-exit', extra: session);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Keluarkan Kendaraan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
