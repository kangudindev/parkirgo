import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/settlement_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import 'settlement_state.dart';

class SettlementBloc extends Cubit<SettlementState> {
  SettlementBloc(
    this._settlementRepository,
    this._transactionRepository,
  ) : super(const SettlementState());

  final SettlementRepository _settlementRepository;
  final TransactionRepository _transactionRepository;

  Future<void> loadSummary() async {
    emit(state.copyWith(isLoading: true));
    try {
      final transactions = await _transactionRepository.getHistory();
      int cash = 0;
      int qris = 0;
      for (final trx in transactions) {
        if (trx.paymentMethod == 'cash') cash += trx.amount ?? 0;
        if (trx.paymentMethod == 'qris') qris += trx.amount ?? 0;
      }
      emit(state.copyWith(
        isLoading: false,
        totalCash: cash,
        totalQris: qris,
        totalTransactions: transactions.length,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> submitSettlement({
    required int shiftId,
    required String? proofImagePath,
  }) async {
    emit(state.copyWith(isLoading: true, isSuccess: false));
    try {
      final result = await _settlementRepository.submit(
        shiftId: shiftId,
        cashAmount: state.totalCash,
        qrisAmount: state.totalQris,
        proofImagePath: proofImagePath,
      );
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        settlementNumber: result['settlement_number'] as String?,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void reset() {
    emit(const SettlementState());
  }
}
