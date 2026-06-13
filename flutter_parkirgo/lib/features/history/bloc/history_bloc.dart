import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/transaction_repository.dart';
import 'history_state.dart';

class HistoryBloc extends Cubit<HistoryState> {
  HistoryBloc(this._repository) : super(const HistoryState());

  final TransactionRepository _repository;

  Future<void> loadHistory() async {
    emit(state.copyWith(isLoading: true));
    try {
      final transactions = await _repository.getHistory();
      emit(state.copyWith(isLoading: false, transactions: transactions));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
