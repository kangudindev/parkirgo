import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/components/loading_overlay.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/parking_constants.dart';
import '../../../data/models/parking_session_model.dart';
import '../bloc/exit_bloc.dart';
import '../bloc/exit_state.dart';
import '../widgets/penalty_receipt.dart';
import '../widgets/verification_step.dart';

class ParkingExitPage extends StatefulWidget {
  const ParkingExitPage({super.key});

  @override
  State<ParkingExitPage> createState() => _ParkingExitPageState();
}

class _ParkingExitPageState extends State<ParkingExitPage> {
  int _step = 0; // 0: scan/pilih, 1: verifikasi, 2: denda+byr
  ParkingSessionModel? _session;
  String? _penaltyType;

  // untuk unregistered
  String _plateNumber = '';
  String _vehicleType = 'motor';
  File? _unregPhoto;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is ParkingSessionModel && _session == null) {
      setState(() {
        _session = extra;
        _step = 1;
      });
    }
  }

  String _format(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)}.')}';
  }

  void _onVerificationComplete(GlobalKey<VerificationStepState> verifKey) {
    final verif = verifKey.currentState;
    if (verif == null) return;
    setState(() => _step = 2);
  }

  Future<void> _payCash(ParkingSessionModel session, int total) async {
    // Proceed with payment
    context.pop();
  }

  Future<void> _payQris(ParkingSessionModel session, int total) async {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(['Kendaraan Keluar', 'Verifikasi', 'Pembayaran'][_step]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _step > 0 ? () => setState(() => _step--) : () => context.pop(),
        ),
      ),
      body: BlocConsumer<ExitBloc, ExitState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) return const LoadingOverlay();

          return IndexedStack(
            index: _step,
            children: [
              _buildStep0(context, state),
              _buildStep1(context, state),
              _buildStep2(context, state),
            ],
          );
        },
      ),
    );
  }

  // STEP 0: Scan QR / Pilih daftar / Input darurat
  Widget _buildStep0(BuildContext context, ExitState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // QR Scanner
        SizedBox(
          height: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MobileScanner(
              onDetect: (capture) {
                final barcode = capture.barcodes.firstOrNull;
                final rawValue = barcode?.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  context.read<ExitBloc>().fetchByTicket(rawValue);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Scan QR karcis parkir', textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary)),

        const Divider(height: 32),

        // Cari manual
        const Text('Karcis Hilang?', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            // Pindah ke daftar parkir aktif
            context.push('/parking-active');
          },
          icon: const Icon(Icons.list),
          label: const Text('Cari dari Daftar Parkir Aktif'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
            backgroundColor: AppColors.warning,
          ),
        ),

        const SizedBox(height: 16),

        // Tidak tercatat
        const Text('Kendaraan Tidak Tercatat?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _showUnregisteredForm(context),
          icon: const Icon(Icons.warning),
          label: const Text('Input Kendaraan Darurat'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showUnregisteredForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Input Kendaraan Darurat',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: 'Plat Nomor'),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (v) => _plateNumber = v,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField(
                  value: _vehicleType,
                  items: const [
                    DropdownMenuItem(value: 'motor', child: Text('Motor')),
                    DropdownMenuItem(value: 'mobil', child: Text('Mobil')),
                    DropdownMenuItem(value: 'bus', child: Text('Bus')),
                    DropdownMenuItem(value: 'truk', child: Text('Truk')),
                  ],
                  onChanged: (v) => setDialogState(() => _vehicleType = v as String),
                  decoration: const InputDecoration(labelText: 'Jenis Kendaraan'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final photo = await picker.pickImage(source: ImageSource.camera, maxWidth: 1280, maxHeight: 960);
                    if (photo != null) {
                      setDialogState(() => _unregPhoto = File(photo.path));
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_unregPhoto != null ? '✓ Foto Tersimpan' : 'Foto Kendaraan'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _plateNumber.isEmpty
                      ? null
                      : () {
                          Navigator.pop(ctx);
                          setState(() {
                            _penaltyType = 'unregistered';
                            _step = 1;
                          });
                        },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
                  child: const Text('Lanjut Verifikasi'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // STEP 1: Verifikasi 4 foto + data pemilik
  Widget _buildStep1(BuildContext context, ExitState state) {
    final plate = _session?.plateNumber ?? _plateNumber;
    final verifKey = GlobalKey<VerificationStepState>();

    return VerificationStep(
      key: verifKey,
      plateNumber: _session?.plateNumber,
      initialPlate: plate,
      onVerified: () => _step = 2,
    );
  }

  // STEP 2: Rincian Denda + Bayar
  Widget _buildStep2(BuildContext context, ExitState state) {
    final session = _session;
    final parkingFee = session?.estimatedAmount ?? 45000;
    final penaltyFee = 5000;
    final totalFee = parkingFee + penaltyFee;

    return PenaltyReceipt(
      parkingFee: parkingFee,
      penaltyFee: penaltyFee,
      totalFee: totalFee,
      penaltyType: _penaltyType ?? 'card_lost',
      ownerName: 'Pemilik',
      onPayCash: () => _payCash(session!, totalFee),
      onPayQris: () => _payQris(session!, totalFee),
    );
  }
}
