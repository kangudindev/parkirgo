import 'package:equatable/equatable.dart';

class AttendanceState extends Equatable {
  const AttendanceState({
    this.isLoading = false,
    this.isCheckedIn = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isCheckedIn;
  final String? errorMessage;

  AttendanceState copyWith({
    bool? isLoading,
    bool? isCheckedIn,
    String? errorMessage,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, isCheckedIn, errorMessage];
}
