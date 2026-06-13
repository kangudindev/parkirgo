class AttendanceModel {
  AttendanceModel({
    required this.id,
    this.userId,
    this.zoneId,
    this.shiftId,
    this.checkInAt,
    this.checkOutAt,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
    this.selfiePath,
    this.syncStatus,
    this.localId,
    this.idempotencyKey,
  });

  final int id;
  final int? userId;
  final int? zoneId;
  final int? shiftId;
  final String? checkInAt;
  final String? checkOutAt;
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;
  final String? selfiePath;
  final String? syncStatus;
  final String? localId;
  final String? idempotencyKey;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      zoneId: json['zone_id'] as int?,
      shiftId: json['shift_id'] as int?,
      checkInAt: json['check_in_at'] as String?,
      checkOutAt: json['check_out_at'] as String?,
      checkInLat: (json['check_in_latitude'] as num?)?.toDouble(),
      checkInLng: (json['check_in_longitude'] as num?)?.toDouble(),
      checkOutLat: (json['check_out_latitude'] as num?)?.toDouble(),
      checkOutLng: (json['check_out_longitude'] as num?)?.toDouble(),
      selfiePath: json['selfie_path'] as String?,
      syncStatus: json['sync_status'] as String?,
      localId: json['local_id'] as String?,
      idempotencyKey: json['idempotency_key'] as String?,
    );
  }
}
