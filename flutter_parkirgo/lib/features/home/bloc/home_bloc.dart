import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/parking_repository.dart';
import 'home_state.dart';

class HomeBloc extends Cubit<HomeState> {
  HomeBloc(this._repository) : super(const HomeState());

  final ParkingRepository _repository;

  Future<void> loadDashboard() async {
    emit(state.copyWith(isLoading: true));
    try {
      final sessions = await _repository.getActiveSessions();
      final total = sessions.fold<int>(0, (sum, s) => sum + (s.estimatedAmount ?? 0));
      emit(state.copyWith(
        isLoading: false,
        activeSessionsCount: sessions.length,
        totalRevenue: total,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
