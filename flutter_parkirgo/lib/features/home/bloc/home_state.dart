import 'package:equatable/equatable.dart';

import '../../../data/models/parking_session_model.dart';

class HomeState extends Equatable {
  const HomeState({
    this.isLoading = false,
    this.activeSessionsCount = 0,
    this.totalRevenue = 0,
    this.errorMessage,
  });

  final bool isLoading;
  final int activeSessionsCount;
  final int totalRevenue;
  final String? errorMessage;

  HomeState copyWith({
    bool? isLoading,
    int? activeSessionsCount,
    int? totalRevenue,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      activeSessionsCount: activeSessionsCount ?? this.activeSessionsCount,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, activeSessionsCount, totalRevenue, errorMessage];
}
