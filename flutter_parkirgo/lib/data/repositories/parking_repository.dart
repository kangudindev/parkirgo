import 'package:dio/dio.dart';

import '../datasources/remote/parking_remote_ds.dart';
import '../datasources/remote/transaction_remote_ds.dart';
import '../models/parking_session_model.dart';
import '../models/zone_model.dart';

class ParkingRepository {
  ParkingRepository({
    required ParkingRemoteDatasource remote,
  }) : _remote = remote;

  final ParkingRemoteDatasource _remote;

  Future<List<ParkingSessionModel>> getActiveSessions() async {
    final data = await _remote.getActiveSessions();
    return data.map((e) => ParkingSessionModel.fromJson(e)).toList();
  }

  Future<ParkingSessionModel> createSession({
    required int zoneId,
    required String plateNumber,
    required String vehicleType,
    String? entryPhotoPath,
    String? localId,
    String? idempotencyKey,
  }) async {
    final data = await _remote.createSession({
      'zone_id': zoneId,
      'plate_number': plateNumber,
      'vehicle_type': vehicleType,
      if (entryPhotoPath != null) 'entry_photo_path': entryPhotoPath,
      if (localId != null) 'local_id': localId,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
    });
    return ParkingSessionModel.fromJson(data);
  }

  Future<ParkingSessionModel> closeSession(
    String sessionId, {
    String? exitPhotoPath,
    String? exitAt,
  }) async {
    final data = await _remote.closeSession(sessionId, exitPhotoPath: exitPhotoPath, exitAt: exitAt);
    return ParkingSessionModel.fromJson(data);
  }

  Future<Map<String, dynamic>> forceExit(
    String sessionId, {
    required String ownerName,
    required String ownerNik,
    String? ownerAddress,
    required String ownerKtpPhoto,
    required String ownerStnkPhoto,
    required String exitVehiclePhoto,
    required String driverPhoto,
    String? jukirNote,
  }) async {
    return _remote.forceExit(
      sessionId,
      ownerName: ownerName,
      ownerNik: ownerNik,
      ownerAddress: ownerAddress,
      ownerKtpPhoto: ownerKtpPhoto,
      ownerStnkPhoto: ownerStnkPhoto,
      exitVehiclePhoto: exitVehiclePhoto,
      driverPhoto: driverPhoto,
      jukirNote: jukirNote,
    );
  }

  Future<Map<String, dynamic>> unregisteredExit({
    required int zoneId,
    required String plateNumber,
    required String vehicleType,
    required String ownerName,
    required String ownerNik,
    String? ownerAddress,
    required String ownerKtpPhoto,
    required String ownerStnkPhoto,
    required String exitVehiclePhoto,
    required String driverPhoto,
    String? jukirNote,
  }) async {
    return _remote.unregisteredExit(
      zoneId: zoneId,
      plateNumber: plateNumber,
      vehicleType: vehicleType,
      ownerName: ownerName,
      ownerNik: ownerNik,
      ownerAddress: ownerAddress,
      ownerKtpPhoto: ownerKtpPhoto,
      ownerStnkPhoto: ownerStnkPhoto,
      exitVehiclePhoto: exitVehiclePhoto,
      driverPhoto: driverPhoto,
      jukirNote: jukirNote,
    );
  }

  Future<int> getPenaltyAmount(int zoneId, String vehicleType, String penaltyType) async {
    final data = await _remote.getPenaltyByZoneAndType(
      zoneId: zoneId,
      vehicleType: vehicleType,
      penaltyType: penaltyType,
    );
    return data['amount'] as int? ?? 0;
  }

  Future<ParkingSessionModel> getSessionByTicket(String ticket) async {
    final data = await _remote.getSessionByTicket(ticket);
    return ParkingSessionModel.fromJson(data);
  }

  Future<List<ZoneModel>> getZones() async {
    final data = await _remote.getZones();
    return data.map((e) => ZoneModel.fromJson(e)).toList();
  }
}
