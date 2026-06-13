import 'package:equatable/equatable.dart';

class ExitState extends Equatable {
  const ExitState({
    this.isLoading = false,
    this.isSuccess = false,
    this.fetchedSession,
    this.finalAmount,
    this.penaltyFee = 0,
    this.parkingFee = 0,
    this.totalFee = 0,
    this.penaltyType, // card_lost / unregistered
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSuccess;
  final dynamic fetchedSession;
  final int? finalAmount;
  final int penaltyFee;
  final int parkingFee;
  final int totalFee;
  final String? penaltyType;
  final String? errorMessage;

  ExitState copyWith({
    bool? isLoading,
    bool? isSuccess,
    dynamic fetchedSession,
    int? finalAmount,
    int? penaltyFee,
    int? parkingFee,
    int? totalFee,
    String? penaltyType,
    String? errorMessage,
  }) {
    return ExitState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      fetchedSession: fetchedSession ?? this.fetchedSession,
      finalAmount: finalAmount ?? this.finalAmount,
      penaltyFee: penaltyFee ?? this.penaltyFee,
      parkingFee: parkingFee ?? this.parkingFee,
      totalFee: totalFee ?? this.totalFee,
      penaltyType: penaltyType ?? this.penaltyType,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSuccess,
        fetchedSession,
        finalAmount,
        penaltyFee,
        parkingFee,
        totalFee,
        penaltyType ?? '',
        errorMessage ?? '',
      ];
}
