import 'package:dio/dio.dart';

import '../../../core/constants/api_url.dart';
import '../../../core/network/api_exception.dart';

class SupervisorRemoteDatasource {
  SupervisorRemoteDatasource(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> getMonitoring() async {
    try {
      final response = await _dio.get(ApiUrl.supervisorMonitoring);
      return ((response.data['jukirs'] as List?) ?? []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal memuat monitoring',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getPendingQris() async {
    try {
      final response = await _dio.get(ApiUrl.supervisorQrisPending);
      final data = response.data['transactions'] as Map<String, dynamic>?;
      return (data?['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal memuat QRIS pending',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> verifyQris(int transactionId, String action, {String? note}) async {
    try {
      await _dio.post(ApiUrl.supervisorVerifyQris, data: {
        'transaction_id': transactionId,
        'action': action,
        if (note != null) 'note': note,
      });
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal verifikasi QRIS',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getPendingSettlements() async {
    try {
      final response = await _dio.get(ApiUrl.supervisorSettlementsPending);
      final data = response.data['settlements'] as Map<String, dynamic>?;
      return (data?['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal memuat setoran pending',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> approveSettlement(int settlementId, String action, {String? note}) async {
    try {
      await _dio.post(ApiUrl.supervisorApproveSettlement, data: {
        'settlement_id': settlementId,
        'action': action,
        if (note != null) 'note': note,
      });
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal approve setoran',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
