import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../bloc/payment_bloc.dart';

class QrisPaymentPage extends StatelessWidget {
  const QrisPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final amount = ModalRoute.of(context)?.settings.arguments as int? ?? 0;
    const qrisPayload = '00020101021126680016ID.CO.PARKIRGO0112ZONA-MONAS5204599953033605802ID5911ParkirGo6007Jakarta6304DEMO';

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran QRIS')),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pembayaran QRIS tercatat: ${state.transactionNumber ?? '-'}')),
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text('Scan QRIS Berikut', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.qr_code, size: 200),
                    ),
                    const SizedBox(height: 16),
                    const Text('Zona Monas Timur', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text('Total: Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: AppColors.warning.withOpacity(0.1),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info, color: AppColors.warning),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Pengendara scan & bayar QRIS di atas. '
                          'Setelah itu jukir konfirmasi untuk mencatat pembayaran.',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PaymentBloc>().payQris(
                      zoneId: 0,
                      amount: amount,
                      qrisPayload: qrisPayload,
                    );
              },
              icon: const Icon(Icons.check),
              label: const Text('Konfirmasi Pembayaran QRIS'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: AppColors.qrisMethod,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
