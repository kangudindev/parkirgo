import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Variant determines the visual style of the button.
enum AppButtonVariant { primary, secondary, danger, ghost }

/// Reusable button widget. Default is full-width, 48px min height, with
/// a built-in loading state. All buttons render in Indonesian / brand
/// color per the design system.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final Widget? icon;
  final bool compact;

  bool get _isDisabled => isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (bg, fg) = _colorsFor(theme);

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelLarge(color: fg),
                ),
              ),
            ],
          );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );

    final button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: _isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            disabledBackgroundColor: bg.withValues(alpha: 0.5),
            disabledForegroundColor: fg.withValues(alpha: 0.7),
            minimumSize: Size(
              fullWidth ? double.infinity : 0,
              compact ? 40 : 48,
            ),
            shape: shape,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          child: child,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: _isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: fg,
            disabledForegroundColor: fg.withValues(alpha: 0.5),
            side: BorderSide(color: bg, width: 1.5),
            minimumSize: Size(
              fullWidth ? double.infinity : 0,
              compact ? 40 : 48,
            ),
            shape: shape,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          child: child,
        ),
      AppButtonVariant.danger => ElevatedButton(
          onPressed: _isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            disabledBackgroundColor: bg.withValues(alpha: 0.5),
            disabledForegroundColor: fg.withValues(alpha: 0.7),
            minimumSize: Size(
              fullWidth ? double.infinity : 0,
              compact ? 40 : 48,
            ),
            shape: shape,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          child: child,
        ),
      AppButtonVariant.ghost => TextButton(
          onPressed: _isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: fg,
            minimumSize: Size(
              fullWidth ? double.infinity : 0,
              compact ? 40 : 48,
            ),
            shape: shape,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
          child: child,
        ),
    };

    return button;
  }

  (Color, Color) _colorsFor(ThemeData theme) {
    if (variant == AppButtonVariant.primary) {
      return (AppColors.primary, AppColors.white);
    } else if (variant == AppButtonVariant.secondary) {
      return (AppColors.primary, AppColors.primary);
    } else if (variant == AppButtonVariant.danger) {
      return (AppColors.danger, AppColors.white);
    } else {
      return (Colors.transparent, AppColors.primary);
    }
  }
}
