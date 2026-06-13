class ZoneModel {
  ZoneModel({
    required this.id,
    required this.name,
    this.code,
    this.city,
    this.qrisPayload,
    this.qrisImagePath,
    this.tariffs,
  });

  final int id;
  final String name;
  final String? code;
  final String? city;
  final String? qrisPayload;
  final String? qrisImagePath;
  final List<ZoneTariffModel>? tariffs;

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '-',
      code: json['code'] as String?,
      city: json['city'] as String?,
      qrisPayload: json['qris_payload'] as String?,
      qrisImagePath: json['qris_image_path'] as String?,
      tariffs: (json['tariffs'] as List?)?.map((e) => ZoneTariffModel.fromJson(e)).toList(),
    );
  }
}

class ZoneTariffModel {
  ZoneTariffModel({
    required this.id,
    required this.zoneId,
    this.vehicleType,
    this.pricingType,
    this.paymentTiming,
    this.baseMinutes,
    this.baseRate,
    this.incrementMinutes,
    this.incrementRate,
    this.dailyMaxRate,
    this.gracePeriodMinutes,
  });

  final int id;
  final int zoneId;
  final String? vehicleType;
  final String? pricingType;
  final String? paymentTiming;
  final int? baseMinutes;
  final int? baseRate;
  final int? incrementMinutes;
  final int? incrementRate;
  final int? dailyMaxRate;
  final int? gracePeriodMinutes;

  factory ZoneTariffModel.fromJson(Map<String, dynamic> json) {
    return ZoneTariffModel(
      id: json['id'] as int,
      zoneId: json['zone_id'] as int,
      vehicleType: json['vehicle_type'] as String?,
      pricingType: json['pricing_type'] as String?,
      paymentTiming: json['payment_timing'] as String?,
      baseMinutes: json['base_minutes'] as int?,
      baseRate: json['base_rate'] as int?,
      incrementMinutes: json['increment_minutes'] as int?,
      incrementRate: json['increment_rate'] as int?,
      dailyMaxRate: json['daily_max_rate'] as int?,
      gracePeriodMinutes: json['grace_period_minutes'] as int?,
    );
  }
}
