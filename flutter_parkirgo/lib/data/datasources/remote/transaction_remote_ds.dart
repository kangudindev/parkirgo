import 'package:dio/dio.dart';

import '../../../core/constants/api_url.dart';
import '../../../core/network/api_exception.dart';

class TransactionRemoteDatasource {
  TransactionRemoteDatasource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> createTransaction(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiUrl.transactions, data: data);
      return response.data['transaction'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal mencatat transaksi',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final response = await _dio.get(ApiUrl.transactions);
      final data = response.data;
      return (data['transactions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal memuat riwayat',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
