import 'package:equatable/equatable.dart';

import '../../../data/models/parking_session_model.dart';

class ActiveSessionsState extends Equatable {
  const ActiveSessionsState({
    this.isLoading = false,
    this.sessions = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final List<ParkingSessionModel> sessions;
  final String? errorMessage;

  ActiveSessionsState copyWith({
    bool? isLoading,
    List<ParkingSessionModel>? sessions,
    String? errorMessage,
  }) {
    return ActiveSessionsState(
      isLoading: isLoading ?? this.isLoading,
      sessions: sessions ?? this.sessions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, sessions, errorMessage ?? ''];
}
