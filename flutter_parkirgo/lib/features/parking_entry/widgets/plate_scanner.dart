import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../core/services/plate_ocr_service.dart';
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
  CameraController? _controller;
  CameraImage? _latestImage;
  final _ocrService = PlateOcrService();
  bool _isDetecting = false;
  bool _isInitialized = false;
  bool _detected = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(camera, ResolutionPreset.medium);

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
        _startImageStream();
      }
    } catch (e) {
      // handle error
    }
  }

  void _startImageStream() {
    _controller?.startImageStream((image) {
      if (_isDetecting || _detected) return;
      _isDetecting = true;
      _latestImage = image;
      _processImage(image);
    });
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      final inputImage = _buildInputImage(image);
      if (inputImage == null) {
        _isDetecting = false;
        return;
      }

      final plate = await _ocrService.detectPlate(inputImage);
      if (plate != null && plate.isNotEmpty && !_detected) {
        setState(() => _detected = true);

        HapticFeedback.heavyImpact();

        // Brief delay then return result
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          widget.onPlateDetected(plate);
        }
      }
    } catch (e) {
      // ignore frame errors
    } finally {
      _isDetecting = false;
    }
  }

  InputImage? _buildInputImage(CameraImage image) {
    final camera = _controller?.description;
    if (camera == null) return null;

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    // Gunakan sensor orientation bawaan camera
    rotation = InputImageRotation.values.firstWhere(
      (r) => r.rawValue == sensorOrientation,
      orElse: () => InputImageRotation.rotation0deg,
    );

    final format = InputImageFormat.values.firstWhere(
      (f) => f.rawValue == image.format.raw,
      orElse: () => InputImageFormat.nv21,
    );

    final planeData = image.planes.map(
      (plane) => InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      ),
    ).toList();

    final inputImageData = InputImageData(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      imageRotation: rotation,
      inputImageFormat: format,
      planeData: planeData,
    );

    final inputImage = InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      inputImageData: inputImageData,
    );

    return inputImage;
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final plateWidth = screenSize.width * 0.85;
    final plateHeight = plateWidth * 0.28; // rasio 4:1

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Scan Plat Nomor', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _controller?.stopImageStream();
              _controller?.dispose();
              Navigator.of(context).pop();
            },
            child: const Text('Input Manual', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: _isInitialized
          ? Stack(
              children: [
                // Camera preview full screen
                SizedBox(
                  width: screenSize.width,
                  height: screenSize.height,
                  child: CameraPreview(_controller!),
                ),

                // Overlay gelap + area scan plat
                CustomPaint(
                  size: screenSize,
                  painter: _PlateOverlayPainter(
                    plateRect: Rect.fromCenter(
                      center: Offset(screenSize.width / 2, screenSize.height / 2.5),
                      width: plateWidth,
                      height: plateHeight,
                    ),
                  ),
                ),

                // Guide text
                Positioned(
                  top: screenSize.height / 2.5 + plateHeight / 2 + 24,
                  left: 0,
                  right: 0,
                  child: const Column(
                    children: [
                      Text(
                        'Arahkan ke plat nomor kendaraan',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'OCR akan mendeteksi secara otomatis',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Detected indicator
                if (_detected)
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Card(
                      color: AppColors.success,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Plat terdeteksi!',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Manual fallback button
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: TextButton.icon(
                    onPressed: () {
                      _controller?.stopImageStream();
                      _controller?.dispose();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.edit, color: Colors.white54),
                    label: const Text(
                      'Input Manual',
                      style: TextStyle(color: Colors.white54, fontSize: 15),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Mengaktifkan kamera...', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
    );
  }
}

class _PlateOverlayPainter extends CustomPainter {
  _PlateOverlayPainter({required this.plateRect});

  final Rect plateRect;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.5);

    // Area luar plat — gelapkan
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(plateRect);

    canvas.drawPath(
      Path.combine(PathOperation.difference, path, Path()..addRect(plateRect)),
      paint,
    );

    // Corner markers
    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final cornerLength = 24.0;
    final gap = 2.0;

    // Top-left
    canvas.drawLine(
      Offset(plateRect.left - gap, plateRect.top - gap + cornerLength),
      Offset(plateRect.left - gap, plateRect.top - gap),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(plateRect.left - gap, plateRect.top - gap),
      Offset(plateRect.left - gap + cornerLength, plateRect.top - gap),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(plateRect.right + gap - cornerLength, plateRect.top - gap),
      Offset(plateRect.right + gap, plateRect.top - gap),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(plateRect.right + gap, plateRect.top - gap),
      Offset(plateRect.right + gap, plateRect.top - gap + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(plateRect.left - gap, plateRect.bottom + gap - cornerLength),
      Offset(plateRect.left - gap, plateRect.bottom + gap),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(plateRect.left - gap, plateRect.bottom + gap),
      Offset(plateRect.left - gap + cornerLength, plateRect.bottom + gap),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(plateRect.right + gap - cornerLength, plateRect.bottom + gap),
      Offset(plateRect.right + gap, plateRect.bottom + gap),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(plateRect.right + gap, plateRect.bottom + gap - cornerLength),
      Offset(plateRect.right + gap, plateRect.bottom + gap),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PlateOverlayPainter oldDelegate) {
    return oldDelegate.plateRect != plateRect;
  }
}
