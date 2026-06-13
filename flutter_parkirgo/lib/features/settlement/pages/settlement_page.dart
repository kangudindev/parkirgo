import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/components/loading_overlay.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/settlement_bloc.dart';
import '../bloc/settlement_state.dart';

class SettlementPage extends StatefulWidget {
  const SettlementPage({super.key});

  @override
  State<SettlementPage> createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  File? _proofImage;

  @override
  void initState() {
    super.initState();
    context.read<SettlementBloc>().loadSummary();
  }

  Future<void> _takeProofPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera, maxWidth: 1280, maxHeight: 960);
    if (photo != null && mounted) {
      setState(() => _proofImage = File(photo.path));
    }
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setoran Akhir Shift'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<SettlementBloc, SettlementState>(
        listener: (context, state) {
          if (state.isSuccess) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Setoran Berhasil Dikirim!', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('No. Setoran: ${state.settlementNumber ?? '-'}'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.read<SettlementBloc>().reset();
                      context.pop();
                      context.pop();
                    },
                    child: const Text('Selesai'),
                  ),
                ],
              ),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text('Ringkasan Shift', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          _summaryRow('Total Transaksi', '${state.totalTransactions}'),
                          const Divider(),
                          _summaryRow('Tunai', _formatRupiah(state.totalCash),
                              valueColor: AppColors.cashMethod),
                          const Divider(),
                          _summaryRow('QRIS', _formatRupiah(state.totalQris),
                              valueColor: AppColors.qrisMethod),
                          const Divider(),
                          _summaryRow('Total Setoran', _formatRupiah(state.totalAmount),
                              valueStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Proof photo
                  const Text('Foto Bukti Setor', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _takeProofPhoto,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: _proofImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_proofImage!, fit: BoxFit.cover, width: double.infinity),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 40, color: AppColors.textSecondary),
                                SizedBox(height: 8),
                                Text('Foto uang yang disetor', style: TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit
                  ElevatedButton.icon(
                    onPressed: state.totalTransactions == 0 || state.isSuccess
                        ? null
                        : () {
                            context.read<SettlementBloc>().submitSettlement(
                                  shiftId: 1,
                                  proofImagePath: _proofImage?.path,
                                );
                          },
                    icon: const Icon(Icons.send),
                    label: const Text('Kirim Setoran'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: AppColors.primary,
                    ),
                  ),

                  if (state.isSuccess)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextButton(
                        onPressed: () {
                          context.read<SettlementBloc>().reset();
                          context.pop();
                        },
                        child: const Text('Kembali ke Dashboard'),
                      ),
                    ),
                ],
              ),
              if (state.isLoading) const LoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor, TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value,
              style: valueStyle ??
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }
}
