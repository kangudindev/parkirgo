import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/api_url.dart';
import '../../../core/network/api_exception.dart';
import '../../models/sync_item_model.dart';

class SyncRemoteDatasource {
  SyncRemoteDatasource(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> syncBatch(
    List<SyncItemModel> items, {
    String? deviceId,
    String? clientBatchId,
  }) async {
    try {
      final response = await _dio.post(ApiUrl.syncBatch, data: {
        if (clientBatchId != null) 'client_batch_id': clientBatchId,
        if (deviceId != null) 'device_id': deviceId,
        'items': items.map((e) => e.toJson()).toList(),
      });
      final data = response.data;
      return (data['results'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data['message'] as String? ?? 'Gagal sinkronisasi',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

class SyncLocalDatasource {
  SyncLocalDatasource(this._box);

  final Box _box;

  List<SyncItemModel> getPendingItems() {
    final keys = _box.keys.where((k) => k.toString().startsWith('sync_'));
    return keys.map((key) {
      final raw = _box.get(key) as String?;
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return SyncItemModel(
        type: map['type'] as String,
        localId: map['local_id'] as String,
        idempotencyKey: map['idempotency_key'] as String,
        payload: map['payload'] as Map<String, dynamic>,
      );
    }).whereType<SyncItemModel>().toList();
  }

  Future<void> addItem(SyncItemModel item) async {
    await _box.put('sync_${item.idempotencyKey}', jsonEncode(item.toJson()));
  }

  Future<void> removeItem(String idempotencyKey) async {
    await _box.delete('sync_$idempotencyKey');
  }

  Future<void> clearPending() async {
    final keys = _box.keys.where((k) => k.toString().startsWith('sync_'));
    for (final key in keys) {
      await _box.delete(key);
    }
  }
}
