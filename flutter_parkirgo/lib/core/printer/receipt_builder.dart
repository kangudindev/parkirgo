import 'dart:convert';

enum PaperSize { mm58, mm80 }

class ReceiptBuilder {
  ReceiptBuilder._();

  static const _esc = 0x1B;
  static const _gs = 0x1D;
  static const _lf = 0x0A;

  static int _lineWidth(PaperSize size) => size == PaperSize.mm80 ? 48 : 32;

  static List<int> _text(String text, {bool bold = false, bool large = false, PaperSize size = PaperSize.mm80}) {
    final bytes = <int>[];
    if (bold) bytes.addAll([_esc, 0x45, 1]);
    if (large) bytes.addAll([_gs, 0x21, 0x11]);
    final maxLen = large ? _lineWidth(size) ~/ 2 : _lineWidth(size);
    final truncated = text.length > maxLen ? '${text.substring(0, maxLen - 1)}.' : text;
    bytes.addAll(utf8.encode(truncated));
    if (large) bytes.addAll([_gs, 0x21, 0x00]);
    if (bold) bytes.addAll([_esc, 0x45, 0]);
    bytes.add(_lf);
    return bytes;
  }

  static List<int> _center(String text, {bool bold = false, PaperSize size = PaperSize.mm80}) {
    final bytes = <int>[];
    bytes.addAll([_esc, 0x61, 1]);
    bytes.addAll(_text(text, bold: bold, size: size));
    bytes.addAll([_esc, 0x61, 0]);
    return bytes;
  }

  static List<int> _separator(PaperSize size) {
    final line = '─' * _lineWidth(size);
    return utf8.encode('$line\n');
  }

  static List<int> _spacer({int lines = 1}) {
    return utf8.encode('\n' * lines);
  }

  static List<int> _qrcode(String data) {
    final bytes = <int>[];
    final qrData = utf8.encode(data);
    final length = qrData.length + 3;

    // Model QR
    bytes.addAll([_gs, 0x28, 0x6B, 0x04, 0x00, 0x31, 0x41, 0x32, 0x00]);
    // Size module (8 = cukup besar terlihat)
    bytes.addAll([_gs, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, 0x08]);
    // Store data
    bytes.addAll([_gs, 0x28, 0x6B, length & 0xFF, (length >> 8) & 0xFF, 0x31, 0x50, 0x30]);
    bytes.addAll(qrData);
    // Print
    bytes.addAll([_gs, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30]);
    return bytes;
  }

  /// Karcis Parkir — saat kendaraan MASUK
  static List<int> karcisMasuk({
    required String zoneName,
    required String ticketNumber,
    required String plateNumber,
    required String entryTime,
    required String vehicleType,
    required String tariffInfo,
    required String paymentStatus,
    required String jukirName,
    PaperSize paperSize = PaperSize.mm80,
  }) {
    final s = paperSize;
    final bytes = <int>[];

    bytes.addAll([_esc, 0x40]); // init

    // Header
    bytes.addAll(_center('PARKIRGO', bold: true, size: s));
    bytes.addAll(_spacer());
    bytes.addAll(_center(zoneName, size: s));
    bytes.addAll(_separator(s));

    // Info
    bytes.addAll(_text('No Tiket: $ticketNumber', size: s));
    bytes.addAll(_text('Masuk: $entryTime', size: s));
    bytes.addAll(_text('Jenis: $vehicleType', size: s));
    bytes.addAll(_text('Tarif: $tariffInfo', size: s));
    bytes.addAll(_text('Status: $paymentStatus', size: s));
    bytes.addAll(_separator(s));

    // QR
    if (ticketNumber.isNotEmpty) {
      bytes.addAll(_qrcode(ticketNumber));
      bytes.addAll(_spacer(lines: 2));
    }

    // Plat — font besar, tanpa label
    final plateCharLimit = s == PaperSize.mm80 ? 24 : 16;
    final plateDisplay = plateNumber.length > plateCharLimit
        ? plateNumber
        : plateNumber;
    bytes.addAll(_center(plateDisplay, bold: true, size: s));
    bytes.addAll(_spacer());

    // Footer
    bytes.addAll(_center('Scan QR saat keluar', size: s));
    bytes.addAll(_spacer());
    bytes.addAll(_text('Jukir: $jukirName', size: s));
    bytes.addAll(_spacer());
    bytes.addAll(_center('-- Terima Kasih --', size: s));
    bytes.addAll(_spacer(lines: 3));
    bytes.addAll([_gs, 0x56, 0x00]); // cut

    return bytes;
  }

  /// Struk Pembayaran — saat kendaraan KELUAR
  static List<int> strukBayar({
    required String zoneName,
    required String ticketNumber,
    required String plateNumber,
    required String entryTime,
    required String exitTime,
    required String duration,
    required String amount,
    required String paymentMethodLabel,
    required String jukirName,
    PaperSize paperSize = PaperSize.mm58,
  }) {
    final s = paperSize;
    final bytes = <int>[];

    bytes.addAll([_esc, 0x40]);

    bytes.addAll(_center('PARKIRGO', bold: true, size: s));
    bytes.addAll(_center(zoneName, size: s));
    bytes.addAll(_separator(s));

    bytes.addAll(_text('Tiket: $ticketNumber', size: s));
    bytes.addAll(_text('Plat:  $plateNumber', size: s));
    bytes.addAll(_text('Masuk: $entryTime', size: s));
    bytes.addAll(_text('Keluar: $exitTime', size: s));
    bytes.addAll(_text('Durasi: $duration', size: s));
    bytes.addAll(_separator(s));

    bytes.addAll(_center('Total: $amount', bold: true, size: s));
    bytes.addAll(_spacer());
    bytes.addAll(_center(paymentMethodLabel, size: s));
    bytes.addAll(_separator(s));

    bytes.addAll(_spacer());
    bytes.addAll(_text('Jukir: $jukirName', size: s));
    bytes.addAll(_spacer());
    bytes.addAll(_center('-- Terima Kasih --', size: s));
    bytes.addAll(_spacer(lines: 3));
    bytes.addAll([_gs, 0x56, 0x00]);

    return bytes;
  }

  /// Setoran Shift
  static List<int> strukSetoran({
    required String shiftDate,
    required String totalTransactions,
    required String cashAmount,
    required String qrisAmount,
    required String totalAmount,
    required String jukirName,
    PaperSize paperSize = PaperSize.mm58,
  }) {
    final s = paperSize;
    final bytes = <int>[];
    bytes.addAll([_esc, 0x40]);

    bytes.addAll(_center('PARKIRGO', bold: true, size: s));
    bytes.addAll(_center('SETORAN AKHIR SHIFT', bold: true, size: s));
    bytes.addAll(_separator(s));

    bytes.addAll(_text('Tanggal: $shiftDate', size: s));
    bytes.addAll(_spacer());
    bytes.addAll(_text('Transaksi: $totalTransactions', size: s));
    bytes.addAll(_text('Tunai:    $cashAmount', size: s));
    bytes.addAll(_text('QRIS:     $qrisAmount', size: s));
    bytes.addAll(_separator(s));
    bytes.addAll(_center('Total: $totalAmount', bold: true, size: s));
    bytes.addAll(_separator(s));

    bytes.addAll(_spacer());
    bytes.addAll(_text('Jukir: $jukirName', size: s));
    bytes.addAll(_spacer(lines: 3));
    bytes.addAll([_gs, 0x56, 0x00]);
    return bytes;
  }
}
