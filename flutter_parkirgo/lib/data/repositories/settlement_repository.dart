import '../datasources/remote/settlement_remote_ds.dart';

class SettlementRepository {
  SettlementRepository({
    required SettlementRemoteDatasource remote,
  }) : _remote = remote;

  final SettlementRemoteDatasource _remote;

  Future<Map<String, dynamic>> submit({
    required int shiftId,
    required int zoneId,
    required int cashAmount,
    required int qrisAmount,
    String? proofImagePath,
    String? idempotencyKey,
  }) async {
    return _remote.store({
      'shift_id': shiftId,
      'zone_id': zoneId,
      'cash_amount': cashAmount,
      'qris_amount': qrisAmount,
      if (proofImagePath != null) 'proof_image_path': proofImagePath,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
    });
  }
}
