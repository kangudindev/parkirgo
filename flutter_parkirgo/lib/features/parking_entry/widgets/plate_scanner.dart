import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';

class PlateScanner extends StatefulWidget {
  const PlateScanner({
    super.key,
    required this.onPlateDetected,
  });

  final ValueChanged<String> onPlateDetected;

  @override
  State<PlateScanner> createState() => _PlateScannerState();
}

class _PlateScannerState extends State<PlateScanner> {
  bool _isProcessing = false;

  Future<void> _pickAndProcess() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 720,
      );

      if (photo != null && mounted) {
        setState(() => _isProcessing = true);
        widget.onPlateDetected('');
      }
    } catch (e) {
      // handle error
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Plat Nomor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Input Manual', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 80, color: Colors.white54),
            const SizedBox(height: 24),
            const Text(
              'Ambil Foto Plat Nomor',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Foto plat nomor kendaraan untuk deteksi otomatis',
              style: TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _pickAndProcess,
              icon: const Icon(Icons.camera_alt),
              label: Text(_isProcessing ? 'Memproses...' : 'Ambil Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Input Plat Manual', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}
