import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class PlateOcrService {
  PlateOcrService()
      : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  /// Regex untuk plat nomor Indonesia:
  /// 1-2 huruf, spasi opsional, 1-4 angka, spasi opsional, 1-3 huruf
  static final RegExp _plateRegex = RegExp(
    r'[A-Za-z]{1,2}\s?\d{1,4}\s?[A-Za-z]{1,3}',
  );

  Future<String?> detectPlate(InputImage inputImage) async {
    try {
      final RecognizedText recognizedText =
          await _recognizer.processImage(inputImage);

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final text = line.text.trim();
          final match = _plateRegex.firstMatch(text);
          if (match != null) {
            final plate = _normalizePlate(match.group(0)!);
            if (_isValidPlate(plate)) return plate;
          }

          // Coba cocokkan kombinasi dari beberapa element dalam block
          final combined = block.lines.map((l) => l.text.trim()).join(' ');
          final combinedMatch = _plateRegex.firstMatch(combined);
          if (combinedMatch != null) {
            final plate = _normalizePlate(combinedMatch.group(0)!);
            if (_isValidPlate(plate)) return plate;
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  String _normalizePlate(String raw) {
    // Hapus spasi berlebih, uppercase
    return raw.toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _isValidPlate(String plate) {
    // Validasi tambahan: minimal panjang
    if (plate.length < 5 || plate.length > 12) return false;

    // Cek format: huruf, angka, huruf
    final parts = plate.split(' ');
    if (parts.length < 2) return false;

    // Minimal 1 digit angka di tengah
    final angka = parts.firstWhere(
      (p) => RegExp(r'^\d+$').hasMatch(p),
      orElse: () => '',
    );
    if (angka.isEmpty) return false;

    return true;
  }

  void dispose() {
    _recognizer.close();
  }
}
