import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/components/loading_overlay.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_state.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  XFile? _selfie;
  Position? _position;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() => _isLocating = true);
    try {
      _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      // GPS gagal, lewatkan
    }
    if (mounted) setState(() => _isLocating = false);
  }

  Future<void> _takeSelfie() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 640,
      maxHeight: 640,
    );
    if (photo != null && mounted) {
      setState(() => _selfie = photo);
    }
  }

  Future<void> _submit() async {
    final zoneId = 1;
    if (zoneId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zona tidak ditemukan')),
      );
      return;
    }

    final bloc = context.read<AttendanceBloc>();
    final currentState = bloc.state;
    if (currentState.isCheckedIn) {
      await bloc.checkOut(
        zoneId: zoneId,
        latitude: _position?.latitude,
        longitude: _position?.longitude,
        selfiePath: _selfie?.path,
      );
    } else {
      await bloc.checkIn(
        zoneId: zoneId,
        latitude: _position?.latitude,
        longitude: _position?.longitude,
        selfiePath: _selfie?.path,
      );
    }

    if (mounted && bloc.state.errorMessage == null) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            state.isCheckedIn
                                ? Icons.check_circle
                                : Icons.access_time,
                            size: 64,
                            color: state.isCheckedIn ? AppColors.success : AppColors.warning,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.isCheckedIn ? 'Sudah Absen Masuk' : 'Belum Absen',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (_position != null)
                            Text(
                              '📍 ${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            )
                          else if (_isLocating)
                            const Text('Mendeteksi lokasi...',
                                style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _takeSelfie,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_selfie == null ? 'Ambil Selfie' : 'Ambil Ulang Selfie'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLight),
                  ),
                  if (_selfie != null) ...[
                    const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_selfie!.path),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _selfie == null ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.isCheckedIn ? AppColors.error : AppColors.success,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      state.isCheckedIn ? 'Absen Pulang' : 'Absen Masuk',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  if (state.isCheckedIn)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: () => context.pop(),
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
}
