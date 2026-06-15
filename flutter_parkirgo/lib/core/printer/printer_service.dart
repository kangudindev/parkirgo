import 'dart:io';

class PrinterService {
  PrinterService._();
  static final PrinterService instance = PrinterService._();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<List<Map<String, dynamic>>> scanDevices() async {
    // Bluetooth printer not available on web
    return [];
  }

  Future<bool> connect(dynamic device) async {
    return false;
  }

  Future<void> disconnect() async {}

  Future<bool> printBytes(List<int> bytes) async {
    return false;
  }

  void dispose() {}
}
