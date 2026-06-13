import 'package:equatable/equatable.dart';

import '../../../data/models/transaction_model.dart';

class HistoryState extends Equatable {
  const HistoryState({
    this.isLoading = false,
    this.transactions = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final List<TransactionModel> transactions;
  final String? errorMessage;

  HistoryState copyWith({
    bool? isLoading,
    List<TransactionModel>? transactions,
    String? errorMessage,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, transactions, errorMessage ?? ''];
}
