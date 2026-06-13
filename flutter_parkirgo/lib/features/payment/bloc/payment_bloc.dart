import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/transaction_repository.dart';
import 'payment_state.dart';

class PaymentBloc extends Cubit<PaymentState> {
  PaymentBloc(this._repository) : super(const PaymentState());

  final TransactionRepository _repository;

  Future<void> payCash({
    required int zoneId,
    required int amount,
    int? parkingSessionId,
  }) async {
    emit(state.copyWith(isLoading: true, isSuccess: false));
    try {
      final trx = await _repository.createTransaction(
        parkingSessionId: parkingSessionId,
        zoneId: zoneId,
        paymentMethod: 'cash',
        amount: amount,
      );
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        transactionNumber: trx.transactionNumber,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> payQris({
    required int zoneId,
    required int amount,
    int? parkingSessionId,
    String? qrisPayload,
  }) async {
    emit(state.copyWith(isLoading: true, isSuccess: false));
    try {
      final trx = await _repository.createTransaction(
        parkingSessionId: parkingSessionId,
        zoneId: zoneId,
        paymentMethod: 'qris',
        amount: amount,
        qrisPayload: qrisPayload,
      );
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        transactionNumber: trx.transactionNumber,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void reset() {
    emit(const PaymentState());
  }
}
