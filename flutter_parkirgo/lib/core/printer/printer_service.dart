import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class PrinterService {
  PrinterService._();
  static final PrinterService instance = PrinterService._();

  BluetoothDevice? _connectedDevice;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<List<BluetoothDevice>> scanDevices() async {
    final devices = <BluetoothDevice>[];

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        if (r.device.name.isNotEmpty &&
            (r.device.name.toLowerCase().contains('printer') ||
                r.device.name.toLowerCase().contains('bt') ||
                r.device.name.toLowerCase().contains('thermal') ||
                r.device.name.toLowerCase().contains('58') ||
                r.device.name.toLowerCase().contains('80'))) {
          if (!devices.any((d) => d.remoteId == r.device.remoteId)) {
            devices.add(r.device);
          }
        }
      }
    });

    await Future.delayed(const Duration(seconds: 8));
    await FlutterBluePlus.stopScan();
    return devices;
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      _isConnected = true;
      return true;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _isConnected = false;
    }
  }

  Future<bool> printBytes(List<int> bytes) async {
    if (!_isConnected || _connectedDevice == null) return false;

    try {
      final services = await _connectedDevice!.discoverServices();
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            // ESC/POS biasanya pakai MTU 512, kirim chunk by chunk
            const chunkSize = 500;
            for (var i = 0; i < bytes.length; i += chunkSize) {
              final end = (i + chunkSize > bytes.length) ? bytes.length : i + chunkSize;
              await characteristic.write(bytes.sublist(i, end));
            }
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    disconnect();
  }
}
