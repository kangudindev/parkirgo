import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/components/loading_overlay.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/parking_constants.dart';
import '../bloc/history_bloc.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().loadHistory();
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state.isLoading) return const LoadingOverlay();
          if (state.errorMessage != null) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          if (state.transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: AppColors.textDisabled),
                  SizedBox(height: 16),
                  Text('Belum ada transaksi'),
                ],
              ),
            );
          }

          int total = state.transactions.fold<int>(0, (sum, t) => sum + (t.amount ?? 0));

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Hari Ini', style: TextStyle(fontSize: 16)),
                      Text(_formatRupiah(total),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<HistoryBloc>().loadHistory(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.transactions.length,
                    itemBuilder: (context, index) {
                      final trx = state.transactions[index];
                      final methodColor = trx.paymentMethod == PaymentMethod.cash
                          ? AppColors.cashMethod
                          : AppColors.qrisMethod;
                      final methodLabel = trx.paymentMethod == PaymentMethod.cash ? 'Tunai' : 'QRIS';
                      final statusColor = trx.status == PaymentRecordStatus.verified
                          ? AppColors.success
                          : AppColors.warning;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: methodColor.withOpacity(0.1),
                            child: Icon(
                              trx.paymentMethod == PaymentMethod.cash
                                  ? Icons.money
                                  : Icons.qr_code,
                              color: methodColor,
                            ),
                          ),
                          title: Text(trx.transactionNumber ?? '-',
                              style: const TextStyle(fontSize: 13)),
                          subtitle: Text('$methodLabel · ${trx.transactionTime ?? '-'}',
                              style: const TextStyle(fontSize: 12)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(_formatRupiah(trx.amount ?? 0),
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(trx.status ?? '-',
                                  style: TextStyle(color: statusColor, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
