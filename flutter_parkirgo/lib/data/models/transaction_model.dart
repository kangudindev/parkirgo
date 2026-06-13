class TransactionModel {
  TransactionModel({
    required this.id,
    this.parkingSessionId,
    this.zoneId,
    this.jukirId,
    this.transactionNumber,
    this.paymentMethod,
    this.amount,
    this.status,
    this.qrisPayload,
    this.proofImagePath,
    this.transactionTime,
    this.syncStatus,
    this.localId,
    this.idempotencyKey,
  });

  final int id;
  final int? parkingSessionId;
  final int? zoneId;
  final int? jukirId;
  final String? transactionNumber;
  final String? paymentMethod;
  final int? amount;
  final String? status;
  final String? qrisPayload;
  final String? proofImagePath;
  final String? transactionTime;
  final String? syncStatus;
  final String? localId;
  final String? idempotencyKey;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      parkingSessionId: json['parking_session_id'] as int?,
      zoneId: json['zone_id'] as int?,
      jukirId: json['jukir_id'] as int?,
      transactionNumber: json['transaction_number'] as String?,
      paymentMethod: json['payment_method'] as String?,
      amount: json['amount'] as int?,
      status: json['status'] as String?,
      qrisPayload: json['qris_payload'] as String?,
      proofImagePath: json['proof_image_path'] as String?,
      transactionTime: json['created_at'] as String? ?? json['transaction_time'] as String?,
      syncStatus: json['sync_status'] as String?,
      localId: json['local_id'] as String?,
      idempotencyKey: json['idempotency_key'] as String?,
    );
  }
}
