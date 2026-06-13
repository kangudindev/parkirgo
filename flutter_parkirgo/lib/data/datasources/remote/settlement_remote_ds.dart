import 'package:dio/dio.dart';

import '../../../core/constants/api_url.dart';
import '../../../core/network/api_exception.dart';

class SettlementRemoteDatasource {
  SettlementRemoteDatasource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> store(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiUrl.settlements, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal kirim setoran',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
