import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';

class VerificationStep extends StatefulWidget {
  const VerificationStep({
    super.key,
    required this.onVerified,
    this.plateNumber,
    this.initialPlate,
  });

  final VoidCallback onVerified;
  final String? plateNumber;
  final String? initialPlate;

  @override
  State<VerificationStep> createState() => VerificationStepState();
}

class VerificationStepState extends State<VerificationStep> {
  File? _ktpPhoto;
  File? _stnkPhoto;
  File? _vehiclePhoto;
  File? _driverPhoto;

  final _nameCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  bool get _allComplete =>
      _ktpPhoto != null &&
      _stnkPhoto != null &&
      _vehiclePhoto != null &&
      _driverPhoto != null &&
      _nameCtrl.text.trim().isNotEmpty &&
      _nikCtrl.text.trim().isNotEmpty &&
      _plateCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.initialPlate != null) {
      _plateCtrl.text = widget.initialPlate!;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nikCtrl.dispose();
    _addressCtrl.dispose();
    _plateCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera, maxWidth: 1280, maxHeight: 960);
    if (photo != null) return File(photo.path);
    return null;
  }

  Widget _photoBox(File? file, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? AppColors.success : AppColors.border,
            width: file != null ? 2 : 1,
          ),
        ),
        child: file != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(file, fit: BoxFit.cover, width: double.infinity, height: 120),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, color: AppColors.textSecondary, size: 28),
                  const SizedBox(height: 4),
                  Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, {String? hint, bool multiline = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          maxLines: multiline ? 3 : 1,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Verifikasi Kepemilikan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Lengkapi 4 foto dan data pemilik untuk kendaraan ini.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),

        // Grid 2x2 foto
        Row(
          children: [
            Expanded(child: _photoBox(_ktpPhoto, 'KTP', () async {
              final f = await _pickImage();
              if (f != null) setState(() => _ktpPhoto = f);
            })),
            const SizedBox(width: 8),
            Expanded(child: _photoBox(_stnkPhoto, 'STNK', () async {
              final f = await _pickImage();
              if (f != null) setState(() => _stnkPhoto = f);
            })),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _photoBox(_vehiclePhoto, 'Kendaraan', () async {
              final f = await _pickImage();
              if (f != null) setState(() => _vehiclePhoto = f);
            })),
            const SizedBox(width: 8),
            Expanded(child: _photoBox(_driverPhoto, 'Pengendara', () async {
              final f = await _pickImage();
              if (f != null) setState(() => _driverPhoto = f);
            })),
          ],
        ),

        const SizedBox(height: 20),
        const Text('Data Pemilik', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        _inputField('Nama Pemilik (dari KTP)', _nameCtrl, hint: 'Contoh: Bambang'),
        const SizedBox(height: 8),
        _inputField('NIK (dari KTP)', _nikCtrl, hint: '3173XXXXXXXXXXXX'),
        const SizedBox(height: 8),
        _inputField('Alamat', _addressCtrl, hint: 'Jl. Merdeka No. 1', multiline: true),
        const SizedBox(height: 8),
        _inputField('Plat STNK', _plateCtrl, hint: 'B 1234 PGO'),

        if (widget.plateNumber != null && widget.plateNumber == _plateCtrl.text)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 14),
                SizedBox(width: 4),
                Text('Plat cocok dengan data sistem',
                    style: TextStyle(color: AppColors.success, fontSize: 12)),
              ],
            ),
          ),

        const SizedBox(height: 12),
        _inputField('Catatan Jukir (opsional)', _noteCtrl, hint: 'Keterangan tambahan...', multiline: true),

        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _allComplete ? widget.onVerified : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Lanjut ke Rincian Denda'),
        ),
        if (!_allComplete)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Lengkapi semua foto & data pemilik',
                style: TextStyle(color: AppColors.textDisabled, fontSize: 12),
                textAlign: TextAlign.center),
          ),
      ],
    );
  }

  Map<String, dynamic> get payload => {
        'owner_name': _nameCtrl.text.trim(),
        'owner_nik': _nikCtrl.text.trim(),
        'owner_address': _addressCtrl.text.trim(),
        'owner_ktp_photo': _ktpPhoto?.path ?? '',
        'owner_stnk_photo': _stnkPhoto?.path ?? '',
        'exit_vehicle_photo': _vehiclePhoto?.path ?? '',
        'driver_photo': _driverPhoto?.path ?? '',
        'jukir_note': _noteCtrl.text.trim(),
      };

  String get ownerName => _nameCtrl.text.trim();
  String get ownerNik => _nikCtrl.text.trim();
  String get ownerAddress => _addressCtrl.text.trim();
  String get plateText => _plateCtrl.text.trim();
  String get note => _noteCtrl.text.trim();
}
