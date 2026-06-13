import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthBloc extends Cubit<AuthState> {
  AuthBloc(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> checkSession() async {
    final token = _repository.token;
    final expiry = _repository.tokenExpiry;
    final user = _repository.currentUser;

    if (token == null || expiry == null || user == null) {
      emit(state.copyWith(isAuthenticated: false, role: null));
      return;
    }

    final expiryDate = DateTime.tryParse(expiry);
    if (expiryDate == null || DateTime.now().isAfter(expiryDate)) {
      await _repository.logout();
      emit(state.copyWith(isAuthenticated: false, role: null));
      return;
    }

    final zone = user['assigned_zone'] as Map<String, dynamic>?;
    emit(state.copyWith(
      isAuthenticated: true,
      role: user['role'] as String?,
      userId: user['id'] as int?,
      assignedZoneId: zone?['id'] as int?,
    ));
  }

  Future<void> loginWithQr(String qrToken) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final data = await _repository.loginWithQr(qrToken);
      final user = data['user'] as Map<String, dynamic>;
      final zone = user['assigned_zone'] as Map<String, dynamic>?;
      emit(state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        role: user['role'] as String?,
        userId: user['id'] as int?,
        assignedZoneId: zone?['id'] as int?,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState());
  }
}
