import 'package:uuid/uuid.dart';

import '../datasources/remote/attendance_remote_ds.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  AttendanceRepository({
    required AttendanceRemoteDatasource remote,
  }) : _remote = remote;

  final AttendanceRemoteDatasource _remote;

  Future<AttendanceModel> checkIn({
    required int zoneId,
    double? checkInLat,
    double? checkInLng,
    String? selfiePath,
    String? idempotencyKey,
  }) async {
    final data = await _remote.store({
      'zone_id': zoneId,
      if (checkInLat != null) 'check_in_latitude': checkInLat,
      if (checkInLng != null) 'check_in_longitude': checkInLng,
      if (selfiePath != null) 'selfie_path': selfiePath,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      'local_id': const Uuid().v4(),
    });
    return AttendanceModel.fromJson(data);
  }

  Future<AttendanceModel> checkOut({
    required int zoneId,
    double? checkOutLat,
    double? checkOutLng,
    String? selfiePath,
    String? idempotencyKey,
  }) async {
    final data = await _remote.store({
      'zone_id': zoneId,
      if (checkOutLat != null) 'check_out_latitude': checkOutLat,
      if (checkOutLng != null) 'check_out_longitude': checkOutLng,
      if (selfiePath != null) 'selfie_path': selfiePath,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      'local_id': const Uuid().v4(),
    });
    return AttendanceModel.fromJson(data);
  }
}
