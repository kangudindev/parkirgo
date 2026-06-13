import 'package:equatable/equatable.dart';

class SettlementState extends Equatable {
  const SettlementState({
    this.isLoading = false,
    this.isSuccess = false,
    this.totalCash = 0,
    this.totalQris = 0,
    this.totalTransactions = 0,
    this.settlementNumber,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSuccess;
  final int totalCash;
  final int totalQris;
  final int totalTransactions;
  final String? settlementNumber;
  final String? errorMessage;

  int get totalAmount => totalCash + totalQris;

  SettlementState copyWith({
    bool? isLoading,
    bool? isSuccess,
    int? totalCash,
    int? totalQris,
    int? totalTransactions,
    String? settlementNumber,
    String? errorMessage,
  }) {
    return SettlementState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      totalCash: totalCash ?? this.totalCash,
      totalQris: totalQris ?? this.totalQris,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      settlementNumber: settlementNumber ?? this.settlementNumber,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSuccess,
        totalCash,
        totalQris,
        totalTransactions,
        settlementNumber ?? '',
        errorMessage ?? '',
      ];
}
