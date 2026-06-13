import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  bool _isProcessing = false;

  Future<void> _handleBarcode(String qrToken) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    await context.read<AuthBloc>().loginWithQr(qrToken);
    if (!mounted) return;
    final state = context.read<AuthBloc>().state;
    if (state.isAuthenticated) {
      context.go('/home-jukir');
      return;
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: Stack(
          children: [
            MobileScanner(
              onDetect: (capture) {
                final barcode = capture.barcodes.firstOrNull;
                final rawValue = barcode?.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  _handleBarcode(rawValue);
                }
              },
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    const Icon(Icons.qr_code_scanner, color: Colors.white, size: 72),
                    const SizedBox(height: 24),
                    const Text(
                      'Scan QR ID Card Juru Parkir',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Arahkan kamera ke QR Code pada kartu identitas jukir untuk login.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.secondary, width: 3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    const Spacer(),
                    if (_isProcessing)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      const Text(
                        'Menunggu scan QR...',
                        style: TextStyle(color: Colors.white),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
