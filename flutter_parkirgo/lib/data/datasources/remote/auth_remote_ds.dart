import 'package:dio/dio.dart';

import '../../../core/constants/api_url.dart';
import '../../../core/network/api_exception.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> loginWithQr(String qrToken) async {
    try {
      final response = await _dio.post(
        ApiUrl.loginQr,
        data: {
          'qr_token': qrToken,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? ((e.response?.data['message'] as String?) ?? 'Login gagal')
          : 'Login gagal';
      throw ApiException(message, statusCode: e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> me() async {
    try {
      final response = await _dio.get(ApiUrl.me);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal memuat profil',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
