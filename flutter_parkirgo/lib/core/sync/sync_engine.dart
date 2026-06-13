import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../data/datasources/remote/sync_remote_ds.dart';
import '../../data/repositories/auth_repository.dart';

class SyncEngine {
  SyncEngine({
    required SyncRemoteDatasource remote,
    required SyncLocalDatasource local,
    required AuthRepository authRepo,
  })  : _remote = remote,
        _local = local,
        _authRepo = authRepo;

  final SyncRemoteDatasource _remote;
  final SyncLocalDatasource _local;
  final AuthRepository _authRepo;
  StreamSubscription? _connectivitySub;
  bool _isSyncing = false;

  void start() {
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((results) async {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline && _authRepo.token != null) {
        await syncPending();
      }
    });
  }

  void stop() {
    _connectivitySub?.cancel();
  }

  Future<void> addToQueue(SyncItemModel item) async {
    await _local.addItem(item);
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pending = _local.getPendingItems();
      if (pending.isEmpty) {
        _isSyncing = false;
        return;
      }

      final results = await _remote.syncBatch(pending);

      for (final result in results) {
        final idempotencyKey = result['idempotency_key'] as String?;
        final status = result['status'] as String?;

        if (status == 'synced' && idempotencyKey != null) {
          await _local.removeItem(idempotencyKey);
        }
      }
    } catch (e) {
      // Sync gagal, coba lagi nanti
    } finally {
      _isSyncing = false;
    }
  }
}
