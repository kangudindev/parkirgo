import 'package:equatable/equatable.dart';

class PaymentState extends Equatable {
  const PaymentState({
    this.isLoading = false,
    this.isSuccess = false,
    this.transactionNumber,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSuccess;
  final String? transactionNumber;
  final String? errorMessage;

  PaymentState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? transactionNumber,
    String? errorMessage,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      transactionNumber: transactionNumber ?? this.transactionNumber,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, transactionNumber ?? '', errorMessage ?? ''];
}
