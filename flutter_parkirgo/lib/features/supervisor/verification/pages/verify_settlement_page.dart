import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/remote/supervisor_remote_ds.dart';

class VerifySettlementPage extends StatefulWidget {
  const VerifySettlementPage({super.key});

  @override
  State<VerifySettlementPage> createState() => _VerifySettlementPageState();
}

class _VerifySettlementPageState extends State<VerifySettlementPage> {
  List<Map<String, dynamic>> _settlements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final ds = context.read<SupervisorRemoteDatasource>();
      final data = await ds.getPendingSettlements();
      if (mounted) setState(() => _settlements = data);
    } catch (e) {
      // handle
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}';
  }

  Future<void> _action(int id, String action) async {
    try {
      final ds = context.read<SupervisorRemoteDatasource>();
      await ds.approveSettlement(id, action);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Setoran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _settlements.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 64, color: AppColors.success),
                          SizedBox(height: 16),
                          Text('Semua setoran sudah diverifikasi'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _settlements.length,
                      itemBuilder: (ctx, i) {
                        final s = _settlements[i];
                        final id = s['id'] as int;
                        final cash = s['cash_amount'] as int? ?? 0;
                        final qris = s['qris_amount'] as int? ?? 0;
                        final total = s['total_amount'] as int? ?? 0;
                        final jukir = s['jukir'] as Map<String, dynamic>?;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Jukir: ${jukir?['name'] ?? '-'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                _row('Tunai', _formatRupiah(cash)),
                                _row('QRIS', _formatRupiah(qris)),
                                const Divider(),
                                _row('Total', _formatRupiah(total)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _action(id, 'approve'),
                                        icon: const Icon(Icons.check, size: 16),
                                        label: const Text('Setujui'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.success,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _action(id, 'reject'),
                                        icon: const Icon(Icons.close, size: 16),
                                        label: const Text('Tolak'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
