import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'solar_icon.dart';

/// Vehicle type catalog. The `id` matches the backend `vehicle_type` enum.
enum VehicleType { motor, mobil, bus, truck }

extension VehicleTypeX on VehicleType {
  String get id => switch (this) {
    VehicleType.motor => 'motorcycle',
    VehicleType.mobil => 'car',
    VehicleType.bus => 'bus',
    VehicleType.truck => 'truck',
  };

  String get label => switch (this) {
    VehicleType.motor => 'Motor',
    VehicleType.mobil => 'Mobil',
    VehicleType.bus => 'Bus',
    VehicleType.truck => 'Truk',
  };

  String get iconName => switch (this) {
    VehicleType.motor => SolarIcon.motorcycle,
    VehicleType.mobil => SolarIcon.car,
    VehicleType.bus => SolarIcon.bus,
    VehicleType.truck => SolarIcon.truck,
  };
}

/// 2×2 grid of vehicle type cards. User picks one; the selected card
/// gets a primary-color border + tinted background.
class VehicleTypePicker extends StatelessWidget {
  const VehicleTypePicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final VehicleType? selected;
  final ValueChanged<VehicleType> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: VehicleType.values
          .map((t) => _VehicleCard(
                type: t,
                selected: selected == t,
                enabled: enabled,
                onTap: () => onChanged(t),
              ))
          .toList(),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.type,
    required this.selected,
    required this.onTap,
    required this.enabled,
  });

  final VehicleType type;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = selected
        ? AppColors.primary.withValues(alpha: isLight ? 0.10 : 0.20)
        : (isLight ? AppColors.white : AppColors.cardDark);
    final borderColor = selected
        ? AppColors.primary
        : (isLight ? AppColors.neutral200 : AppColors.neutral700);
    final iconColor = selected
        ? AppColors.primary
        : (isLight ? AppColors.neutral700 : AppColors.neutral200);
    final textColor = selected
        ? AppColors.primary
        : (isLight ? AppColors.neutral800 : AppColors.neutral100);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: borderColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SolarIcon.render(context, type.iconName, size: 36, color: iconColor),
              const SizedBox(height: AppSpacing.sm),
              Text(type.label, style: AppTypography.titleSmall(color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}
