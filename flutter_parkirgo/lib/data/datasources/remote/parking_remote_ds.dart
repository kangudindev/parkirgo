import 'package:dio/dio.dart';

import '../../../core/constants/api_url.dart';
import '../../../core/network/api_exception.dart';

class ParkingRemoteDatasource {
  ParkingRemoteDatasource(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    try {
      final response = await _dio.get(
        ApiUrl.parkingSessions,
        queryParameters: {'status': 'active'},
      );
      final data = response.data;
      return (data['sessions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal memuat parkir aktif',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> createSession(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiUrl.parkingSessions, data: data);
      return response.data['session'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal mencatat kendaraan masuk',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> closeSession(
    String sessionId, {
    String? exitPhotoPath,
    String? exitAt,
  }) async {
    try {
      final response = await _dio.post(
        ApiUrl.closeParkingSession(sessionId),
        data: {
          if (exitPhotoPath != null) 'exit_photo_path': exitPhotoPath,
          if (exitAt != null) 'exit_at': exitAt,
        },
      );
      return response.data['session'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal menutup sesi parkir',
        statusCode: e.response?.statusCode,
      );
    }
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
    try {
      final response = await _dio.post(
        ApiUrl.forceExit(sessionId),
        data: {
          'owner_name': ownerName,
          'owner_nik': ownerNik,
          if (ownerAddress != null) 'owner_address': ownerAddress,
          'owner_ktp_photo': ownerKtpPhoto,
          'owner_stnk_photo': ownerStnkPhoto,
          'exit_vehicle_photo': exitVehiclePhoto,
          'driver_photo': driverPhoto,
          if (jukirNote != null) 'jukir_note': jukirNote,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal proses force exit',
        statusCode: e.response?.statusCode,
      );
    }
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
    try {
      final response = await _dio.post(
        ApiUrl.unregisteredExit,
        data: {
          'zone_id': zoneId,
          'plate_number': plateNumber,
          'vehicle_type': vehicleType,
          'owner_name': ownerName,
          'owner_nik': ownerNik,
          if (ownerAddress != null) 'owner_address': ownerAddress,
          'owner_ktp_photo': ownerKtpPhoto,
          'owner_stnk_photo': ownerStnkPhoto,
          'exit_vehicle_photo': exitVehiclePhoto,
          'driver_photo': driverPhoto,
          if (jukirNote != null) 'jukir_note': jukirNote,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal proses kendaraan tidak tercatat',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> getPenaltyByZoneAndType({
    required int zoneId,
    required String vehicleType,
    required String penaltyType,
  }) async {
    try {
      final response = await _dio.post(
        ApiUrl.penaltyByZoneType,
        data: {
          'zone_id': zoneId,
          'vehicle_type': vehicleType,
          'penalty_type': penaltyType,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal memuat denda',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> getSessionByTicket(String ticketNumber) async {
    try {
      final response = await _dio.get(ApiUrl.byTicketParkingSession(ticketNumber));
      return response.data['session'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Tiket tidak ditemukan',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getZones() async {
    try {
      final response = await _dio.get(ApiUrl.zones);
      final data = response.data;
      return (data['zones'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal memuat zona',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
