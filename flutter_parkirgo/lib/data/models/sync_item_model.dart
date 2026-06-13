class SyncItemModel {
  SyncItemModel({
    required this.type,
    required this.localId,
    required this.idempotencyKey,
    required this.payload,
  });

  final String type;
  final String localId;
  final String idempotencyKey;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => {
        'type': type,
        'local_id': localId,
        'idempotency_key': idempotencyKey,
        'payload': payload,
      };
}
