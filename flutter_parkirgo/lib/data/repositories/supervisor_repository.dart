import '../datasources/remote/supervisor_remote_ds.dart';

class SupervisorRepository {
  SupervisorRepository({required SupervisorRemoteDatasource remote}) : _remote = remote;

  final SupervisorRemoteDatasource _remote;

  Future<List<Map<String, dynamic>>> getMonitoring() => _remote.getMonitoring();
  Future<List<Map<String, dynamic>>> getPendingQris() => _remote.getPendingQris();
  Future<void> verifyQris(int transactionId, String action, {String? note}) =>
      _remote.verifyQris(transactionId, action, note: note);
}
