class ParkingSessionModel {
  ParkingSessionModel({
    required this.id,
    this.zoneId,
    this.jukirId,
    this.tariffId,
    this.ticketNumber,
    this.plateNumber,
    this.vehicleType,
    this.entryAt,
    this.exitAt,
    this.durationMinutes,
    this.estimatedAmount,
    this.finalAmount,
    this.entryPhotoPath,
    this.exitPhotoPath,
    this.status,
    this.paymentStatus,
    this.paymentTiming,
    this.pricingType,
    this.syncStatus,
    this.localId,
    this.idempotencyKey,
    // Denda & Verifikasi
    this.isCardLost = false,
    this.penaltyFee = 0,
    this.ownerName,
    this.ownerNik,
    this.ownerAddress,
    this.ownerKtpPhoto,
    this.ownerStnkPhoto,
    this.exitVehiclePhoto,
    this.driverPhoto,
    this.jukirNote,
    this.zone,
  });

  final int id;
  final int? zoneId;
  final int? jukirId;
  final int? tariffId;
  final String? ticketNumber;
  final String? plateNumber;
  final String? vehicleType;
  final String? entryAt;
  final String? exitAt;
  final int? durationMinutes;
  final int? estimatedAmount;
  final int? finalAmount;
  final String? entryPhotoPath;
  final String? exitPhotoPath;
  final String? status;
  final String? paymentStatus;
  final String? paymentTiming;
  final String? pricingType;
  final String? syncStatus;
  final String? localId;
  final String? idempotencyKey;
  // Denda & Verifikasi
  final bool isCardLost;
  final int penaltyFee;
  final String? ownerName;
  final String? ownerNik;
  final String? ownerAddress;
  final String? ownerKtpPhoto;
  final String? ownerStnkPhoto;
  final String? exitVehiclePhoto;
  final String? driverPhoto;
  final String? jukirNote;
  final Map<String, dynamic>? zone;

  int get totalFee => (finalAmount ?? 0) + penaltyFee;

  factory ParkingSessionModel.fromJson(Map<String, dynamic> json) {
    return ParkingSessionModel(
      id: json['id'] as int,
      zoneId: json['zone_id'] as int?,
      jukirId: json['jukir_id'] as int?,
      tariffId: json['tariff_id'] as int?,
      ticketNumber: json['ticket_number'] as String?,
      plateNumber: json['plate_number'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      entryAt: json['entry_at'] as String?,
      exitAt: json['exit_at'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      estimatedAmount: json['estimated_amount'] as int?,
      finalAmount: json['final_amount'] as int?,
      entryPhotoPath: json['entry_photo_path'] as String?,
      exitPhotoPath: json['exit_photo_path'] as String?,
      status: json['status'] as String?,
      paymentStatus: json['payment_status'] as String?,
      paymentTiming: json['payment_timing'] as String?,
      pricingType: json['pricing_type'] as String?,
      syncStatus: json['sync_status'] as String?,
      localId: json['local_id'] as String?,
      idempotencyKey: json['idempotency_key'] as String?,
      isCardLost: json['is_card_lost'] as bool? ?? false,
      penaltyFee: json['penalty_fee'] as int? ?? 0,
      ownerName: json['owner_name'] as String?,
      ownerNik: json['owner_nik'] as String?,
      ownerAddress: json['owner_address'] as String?,
      ownerKtpPhoto: json['owner_ktp_photo'] as String?,
      ownerStnkPhoto: json['owner_stnk_photo'] as String?,
      exitVehiclePhoto: json['exit_vehicle_photo'] as String?,
      driverPhoto: json['driver_photo'] as String?,
      jukirNote: json['jukir_note'] as String?,
      zone: json['zone'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'zone_id': zoneId,
        'jukir_id': jukirId,
        'tariff_id': tariffId,
        'ticket_number': ticketNumber,
        'plate_number': plateNumber,
        'vehicle_type': vehicleType,
        'entry_at': entryAt,
        'exit_at': exitAt,
        'duration_minutes': durationMinutes,
        'estimated_amount': estimatedAmount,
        'final_amount': finalAmount,
        'entry_photo_path': entryPhotoPath,
        'exit_photo_path': exitPhotoPath,
        'status': status,
        'payment_status': paymentStatus,
        'payment_timing': paymentTiming,
        'pricing_type': pricingType,
      };
}
