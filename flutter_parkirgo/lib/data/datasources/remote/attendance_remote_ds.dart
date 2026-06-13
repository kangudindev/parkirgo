import 'package:dio/dio.dart';

import '../../../core/constants/api_url.dart';
import '../../../core/network/api_exception.dart';

class AttendanceRemoteDatasource {
  AttendanceRemoteDatasource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> store(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiUrl.attendances, data: data);
      return response.data['attendance'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal absen',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
