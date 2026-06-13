import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/printer/printer_service.dart';
import '../../../core/printer/receipt_builder.dart';
import '../../../core/theme/app_colors.dart';

class PenaltyReceipt extends StatelessWidget {
  const PenaltyReceipt({
    super.key,
    required this.parkingFee,
    required this.penaltyFee,
    required this.totalFee,
    this.penaltyType,
    this.ownerName,
    this.plateNumber,
    this.ticketNumber,
    this.entryTime,
    this.jukirName,
    required this.onPayCash,
    required this.onPayQris,
  });

  final int parkingFee;
  final int penaltyFee;
  final int totalFee;
  final String? penaltyType;
  final String? ownerName;
  final String? plateNumber;
  final String? ticketNumber;
  final String? entryTime;
  final String? jukirName;
  final VoidCallback onPayCash;
  final VoidCallback onPayQris;

  String _format(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final reasonLabel = penaltyType == 'card_lost' ? 'Karcis Hilang' : 'Tidak Tercatat';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Rincian Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // Data verifikasi
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user, color: AppColors.success, size: 18),
                    const SizedBox(width: 6),
                    const Text('Verifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('👤 Pemilik: ${ownerName ?? '-'}'),
                Text('📌 Status: ⚠️ $reasonLabel'),
                Text('📸 4 foto tersimpan sebagai bukti'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tagihan
        Card(
          color: AppColors.error.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _row('Tarif Parkir', _format(parkingFee)),
                if (penaltyFee > 0) ...[
                  const SizedBox(height: 4),
                  _row('Denda $reasonLabel', _format(penaltyFee),
                      valueColor: AppColors.error),
                ],
                const Divider(height: 24),
                _row('TOTAL', _format(totalFee),
                    valueStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppColors.error,
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Cetak struk
        OutlinedButton.icon(
          onPressed: () {
            final bytes = ReceiptBuilder.strukBayar(
              zoneName: 'Zona',
              ticketNumber: ticketNumber ?? '-',
              plateNumber: plateNumber ?? '-',
              entryTime: entryTime ?? '-',
              exitTime: DateTime.now().toString().substring(11, 19),
              duration: '-',
              amount: _format(totalFee),
              paymentMethodLabel: reasonLabel,
              jukirName: jukirName ?? 'Juru Parkir',
            );
            PrinterService.instance.printBytes(bytes);
          },
          icon: const Icon(Icons.print, size: 18),
          label: const Text('Cetak Struk'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
        const SizedBox(height: 12),

        // Tombol bayar
        ElevatedButton.icon(
          onPressed: onPayCash,
          icon: const Icon(Icons.money),
          label: Text('Bayar Tunai ${_format(totalFee)}'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: AppColors.cashMethod,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onPayQris,
          icon: const Icon(Icons.qr_code),
          label: Text('Bayar QRIS ${_format(totalFee)}'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: AppColors.qrisMethod,
            foregroundColor: Colors.white,
          ),
        ),

        const SizedBox(height: 16),
        Card(
          color: AppColors.warning.withOpacity(0.1),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info, color: AppColors.warning, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Jika karcis asli ditemukan, segera laporkan ke supervisor untuk verifikasi.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {Color? valueColor, TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value,
            style: valueStyle ??
                TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }
}
