import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/remote/supervisor_remote_ds.dart';

class VerifyQrisPage extends StatefulWidget {
  const VerifyQrisPage({super.key});

  @override
  State<VerifyQrisPage> createState() => _VerifyQrisPageState();
}

class _VerifyQrisPageState extends State<VerifyQrisPage> {
  List<Map<String, dynamic>> _transactions = [];
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
      final data = await ds.getPendingQris();
      if (mounted) setState(() => _transactions = data);
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
      await ds.verifyQris(id, action);
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
        title: const Text('Verifikasi QRIS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _transactions.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 64, color: AppColors.success),
                          SizedBox(height: 16),
                          Text('Semua QRIS sudah diverifikasi'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _transactions.length,
                      itemBuilder: (ctx, i) {
                        final t = _transactions[i];
                        final id = t['id'] as int;
                        final amount = t['amount'] as int? ?? 0;
                        final jukir = t['jukir'] as Map<String, dynamic>?;
                        final plat = t['parking_session']?['plate_number'] as String? ?? '-';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Plat: $plat'),
                                    Text(_formatRupiah(amount),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Jukir: ${jukir?['name'] ?? '-'}',
                                    style: const TextStyle(color: AppColors.textSecondary)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _action(id, 'verify'),
                                        icon: const Icon(Icons.check, size: 16),
                                        label: const Text('Verifikasi'),
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
}
