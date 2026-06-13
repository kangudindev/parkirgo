import '../datasources/local/auth_local_ds.dart';
import '../datasources/remote/auth_remote_ds.dart';

class AuthRepository {
  AuthRepository({
    required AuthRemoteDatasource remote,
    required AuthLocalDatasource local,
  })  : _remote = remote,
        _local = local;

  final AuthRemoteDatasource _remote;
  final AuthLocalDatasource _local;

  Future<Map<String, dynamic>> loginWithQr(String qrToken) async {
    final data = await _remote.loginWithQr(qrToken);
    await _local.saveAuth(
      token: data['token'] as String,
      expiresAt: data['expires_at'] as String,
      user: data['user'] as Map<String, dynamic>,
    );
    return data;
  }

  Future<Map<String, dynamic>> me() => _remote.me();

  Map<String, dynamic>? get currentUser => _local.user;
  String? get token => _local.token;
  String? get tokenExpiry => _local.tokenExpiry;

  Future<void> logout() => _local.clearAuth();
}
