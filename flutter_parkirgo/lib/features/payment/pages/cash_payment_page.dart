import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/components/loading_overlay.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_state.dart';

class CashPaymentPage extends StatefulWidget {
  const CashPaymentPage({super.key});

  @override
  State<CashPaymentPage> createState() => _CashPaymentPageState();
}

class _CashPaymentPageState extends State<CashPaymentPage> {
  final _amountController = TextEditingController();
  final _paidController = TextEditingController();
  int _change = 0;

  @override
  void dispose() {
    _amountController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  void _calculateChange() {
    final amount = int.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    final paid = int.tryParse(_paidController.text.replaceAll('.', '')) ?? 0;
    setState(() => _change = paid - amount);
  }

  @override
  Widget build(BuildContext context) {
    final amount = ModalRoute.of(context)?.settings.arguments as int? ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran Tunai')),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pembayaran berhasil: ${state.transactionNumber ?? '-'}')),
            );
            context.pop();
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Total Pembayaran', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text('Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _paidController,
              decoration: const InputDecoration(
                labelText: 'Nominal Dibayar',
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateChange(),
            ),
            const SizedBox(height: 12),
            Card(
              color: _change >= 0 ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kembalian'),
                    Text('Rp ${_change >= 0 ? _change.toString() : '0'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _change >= 0 ? AppColors.success : AppColors.error,
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _change < 0 || _change == 0 && _paidController.text.isEmpty
                  ? null
                  : () {
                      context.read<PaymentBloc>().payCash(
                            zoneId: 0,
                            amount: amount,
                          );
                    },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: const Text('Konfirmasi Pembayaran Tunai'),
            ),
          ],
        ),
      ),
    );
  }
}
