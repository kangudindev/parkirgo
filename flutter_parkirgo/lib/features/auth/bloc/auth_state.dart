import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.role,
    this.userId,
    this.assignedZoneId,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final String? role;
  final int? userId;
  final int? assignedZoneId;
  final String? errorMessage;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? role,
    int? userId,
    int? assignedZoneId,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      assignedZoneId: assignedZoneId ?? this.assignedZoneId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isAuthenticated,
        role ?? '',
        userId,
        assignedZoneId,
        errorMessage ?? '',
      ];
}
