import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Full-screen modal overlay with a backdrop blur and centered spinner.
/// Use via [LoadingOverlay.show] / [LoadingOverlay.hide] from any context.
class LoadingOverlay {
  LoadingOverlay._();

  static OverlayEntry? _current;

  /// Show the overlay. Safe to call multiple times — only the first call
  /// actually mounts; later calls are no-ops.
  static void show(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    if (_current != null) return;
    final overlay = Overlay.of(context, rootOverlay: true);
    _current = OverlayEntry(
      builder: (ctx) => _OverlayView(
        message: message,
        barrierDismissible: barrierDismissible,
        onDismiss: hide,
      ),
    );
    overlay.insert(_current!);
  }

  /// Hide the overlay if it is currently visible.
  static void hide() {
    _current?.remove();
    _current = null;
  }

  static bool get isVisible => _current != null;
}

class _OverlayView extends StatelessWidget {
  const _OverlayView({
    required this.message,
    required this.barrierDismissible,
    required this.onDismiss,
  });

  final String? message;
  final bool barrierDismissible;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: AppColors.black.withValues(alpha: 0.35),
              ),
            ),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 220),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (barrierDismissible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: onDismiss,
                  behavior: HitTestBehavior.translucent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
