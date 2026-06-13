import '../datasources/remote/transaction_remote_ds.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  TransactionRepository({
    required TransactionRemoteDatasource remote,
  }) : _remote = remote;

  final TransactionRemoteDatasource _remote;

  Future<TransactionModel> createTransaction({
    int? parkingSessionId,
    required int zoneId,
    required String paymentMethod,
    required int amount,
    String? qrisPayload,
    String? localId,
    String? idempotencyKey,
  }) async {
    final data = await _remote.createTransaction({
      if (parkingSessionId != null) 'parking_session_id': parkingSessionId,
      'zone_id': zoneId,
      'payment_method': paymentMethod,
      'amount': amount,
      if (qrisPayload != null) 'qris_payload': qrisPayload,
      if (localId != null) 'local_id': localId,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
    });
    return TransactionModel.fromJson(data);
  }

  Future<List<TransactionModel>> getHistory() async {
    final data = await _remote.getHistory();
    return data.map((e) => TransactionModel.fromJson(e)).toList();
  }
}
