class PlateOcrService {
  PlateOcrService();

  Future<String?> detectPlate(dynamic inputImage) async {
    // OCR not available on web
    return null;
  }

  void dispose() {}
}
