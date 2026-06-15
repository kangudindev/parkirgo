import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/components/loading_overlay.dart';
import '../../../core/printer/printer_service.dart';
import '../../../core/printer/receipt_builder.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/parking_constants.dart';
import '../bloc/entry_bloc.dart';
import '../bloc/entry_state.dart';
import '../widgets/plate_scanner.dart';

class ParkingEntryPage extends StatefulWidget {
  const ParkingEntryPage({super.key});

  @override
  State<ParkingEntryPage> createState() => _ParkingEntryPageState();
}

class _ParkingEntryPageState extends State<ParkingEntryPage> {
  final _plateController = TextEditingController();
  String _selectedVehicleType = 'motor';
  File? _entryPhoto;
  bool _showPrintPreview = false;

  final _vehicleTypes = [
    {'code': 'motor', 'label': 'Motor', 'icon': Icons.motorcycle},
    {'code': 'mobil', 'label': 'Mobil', 'icon': Icons.directions_car},
    {'code': 'bus', 'label': 'Bus', 'icon': Icons.directions_bus},
    {'code': 'truk', 'label': 'Truk', 'icon': Icons.local_shipping},
  ];

  @override
  void initState() {
    super.initState();
    context.read<EntryBloc>().loadZones();
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      maxHeight: 960,
    );
    if (photo != null && mounted) {
      setState(() => _entryPhoto = File(photo.path));
    }
  }

  Future<void> _openScanner() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => PlateScanner(
          onPlateDetected: (plate) {
            Navigator.of(context).pop(plate);
          },
          // The scanner will call onPlateDetected and then we pop with result
        ),
        fullscreenDialog: true,
      ),
    );

    if (result != null && mounted) {
      _plateController.text = result;
    }
  }

  void _submit() {
    final state = context.read<EntryBloc>().state;
    final plate = _plateController.text.trim();
    if (plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan plat nomor kendaraan')),
      );
      return;
    }
    if (_entryPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ambil foto kendaraan')),
      );
      return;
    }
    if (state.selectedZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zona tidak ditemukan')),
      );
      return;
    }
    context.read<EntryBloc>().submitEntry(
          zoneId: state.selectedZone!.id,
          plateNumber: plate,
          vehicleType: _selectedVehicleType,
          entryPhotoPath: _entryPhoto!.path,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kendaraan Masuk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<EntryBloc, EntryState>(
        listener: (context, state) {
          if (state.isSuccess && state.ticketNumber != null) {
            setState(() => _showPrintPreview = true);
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (_showPrintPreview && state.ticketNumber != null) {
            return _buildPrintPreview(state, context);
          }
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Zone selection
                  if (state.zones.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.selectedZone?.name ?? state.zones.first.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Plate input + Scan button
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Plat Nomor', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _plateController,
                              decoration: const InputDecoration(
                                hintText: 'Contoh: B 1234 PGO',
                                prefixIcon: Icon(Icons.directions_car),
                              ),
                              textCapitalization: TextCapitalization.characters,
                              style: const TextStyle(fontSize: 20, letterSpacing: 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _openScanner,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 20),
                              Text('Scan', style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Vehicle type
                  const Text('Jenis Kendaraan', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _vehicleTypes.map((vt) {
                      final selected = _selectedVehicleType == vt['code'];
                      return ChoiceChip(
                        label: Text(vt['label'] as String),
                        selected: selected,
                        avatar: Icon(vt['icon'] as IconData, size: 18),
                        onSelected: (_) => setState(() => _selectedVehicleType = vt['code'] as String),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Photo
                  const Text('Foto Kendaraan', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _takePhoto,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: _entryPhoto != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_entryPhoto!, fit: BoxFit.cover, width: double.infinity),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 48, color: AppColors.textSecondary),
                                SizedBox(height: 8),
                                Text('Tap untuk ambil foto', style: TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tariff info
                  if (state.tariffInfo != null)
                    Card(
                      color: AppColors.warning.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.info, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Expanded(child: Text(state.tariffInfo!)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Submit
                  ElevatedButton(
                    onPressed: state.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Catat Kendaraan Masuk', style: TextStyle(fontSize: 16)),
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

  Widget _buildPrintPreview(EntryState state, BuildContext context) {
    const zoneName = 'Zona Monas Timur';
    final statusLabel = state.tariffInfo?.contains('Bayar') == true ? 'LUNAS' : 'BELUM';
    final statusColor = statusLabel == 'LUNAS' ? AppColors.success : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.check_circle, color: AppColors.success, size: 64),
          const SizedBox(height: 16),
          const Text('Kendaraan Berhasil Dicatat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  const Text('PARKIRGO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  Text(zoneName, style: const TextStyle(color: AppColors.textSecondary)),
                  const Divider(),
                  // Info tanpa plat
                  _infoRow('No Tiket', state.ticketNumber ?? '-'),
                  _infoRow('Masuk', DateTime.now().toString().substring(11, 19)),
                  _infoRow('Jenis', _selectedVehicleType.toUpperCase()),
                  _infoRow('Status', statusLabel),
                  const SizedBox(height: 16),
                  // QR Code
                  if (state.ticketNumber != null)
                    QrImageView(
                      data: state.ticketNumber!,
                      version: QrVersions.auto,
                      size: 180,
                      backgroundColor: Colors.white,
                    ),
                  // Plat nomor — bawah QR, font besar, tanpa label
                  const SizedBox(height: 8),
                  Text(
                    _plateController.text,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Scan QR saat keluar', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Print button
          ElevatedButton.icon(
            onPressed: () {
              final bytes = ReceiptBuilder.karcisMasuk(
                zoneName: state.selectedZone?.name ?? 'Zona',
                ticketNumber: state.ticketNumber!,
                plateNumber: _plateController.text,
                entryTime: DateTime.now().toString().substring(11, 19),
                vehicleType: _selectedVehicleType.toUpperCase(),
                tariffInfo: state.tariffInfo ?? '-',
                paymentStatus: statusLabel,
                jukirName: 'Juru Parkir',
              );
              PrinterService.instance.printBytes(bytes);
            },
            icon: const Icon(Icons.print),
            label: const Text('Cetak Karcis'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              backgroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              context.read<EntryBloc>().reset();
              setState(() {
                _showPrintPreview = false;
                _entryPhoto = null;
                _plateController.clear();
              });
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            child: const Text('Selesai'),
          ),
          TextButton(
            onPressed: () {
              context.read<EntryBloc>().reset();
              setState(() {
                _showPrintPreview = false;
                _entryPhoto = null;
                _plateController.clear();
              });
              context.pop();
            },
            child: const Text('Kembali ke Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
