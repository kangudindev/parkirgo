import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Visual status pill for parking-session / transaction states.
enum StatusKind { lunas, belum, recorded, rejected, pending, success, warning, danger, info }

extension StatusKindX on StatusKind {
  Color _bg(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final base = switch (this) {
      StatusKind.lunas => AppColors.success,
      StatusKind.belum => AppColors.warning,
      StatusKind.recorded => AppColors.info,
      StatusKind.rejected => AppColors.danger,
      StatusKind.pending => AppColors.warning,
      StatusKind.success => AppColors.success,
      StatusKind.warning => AppColors.warning,
      StatusKind.danger => AppColors.danger,
      StatusKind.info => AppColors.info,
    };
    return base.withValues(alpha: isLight ? 0.12 : 0.22);
  }

  Color _fg() {
    return switch (this) {
      StatusKind.lunas => AppColors.successDark,
      StatusKind.belum => AppColors.warningDark,
      StatusKind.recorded => AppColors.info,
      StatusKind.rejected => AppColors.dangerDark,
      StatusKind.pending => AppColors.warningDark,
      StatusKind.success => AppColors.successDark,
      StatusKind.warning => AppColors.warningDark,
      StatusKind.danger => AppColors.dangerDark,
      StatusKind.info => AppColors.info,
    };
  }

  String get defaultLabel => switch (this) {
    StatusKind.lunas => 'LUNAS',
    StatusKind.belum => 'BELUM',
    StatusKind.recorded => 'RECORDED',
    StatusKind.rejected => 'DITOLAK',
    StatusKind.pending => 'MENUNGGU',
    StatusKind.success => 'SUKSES',
    StatusKind.warning => 'PERINGATAN',
    StatusKind.danger => 'GAGAL',
    StatusKind.info => 'INFO',
  };
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.kind,
    this.label,
    this.compact = false,
  });

  /// Convenience constructor: build from a backend status string.
  factory StatusBadge.fromString(String status, {String? label}) {
    final kind = switch (status.toLowerCase()) {
      'paid' || 'lunas' || 'verified' || 'success' => StatusKind.lunas,
      'unpaid' || 'belum' || 'pending' => StatusKind.belum,
      'recorded' || 'rec' => StatusKind.recorded,
      'rejected' || 'failed' || 'tolak' => StatusKind.rejected,
      'submitted' || 'menunggu' => StatusKind.pending,
      'warning' => StatusKind.warning,
      'info' => StatusKind.info,
      _ => StatusKind.info,
    };
    return StatusBadge(kind: kind, label: label);
  }

  final StatusKind kind;
  final String? label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bg = kind._bg(context);
    final fg = kind._fg();
    final text = label ?? kind.defaultLabel;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? 2 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall(color: fg).copyWith(
          fontSize: compact ? 10 : 11,
        ),
      ),
    );
  }
}
