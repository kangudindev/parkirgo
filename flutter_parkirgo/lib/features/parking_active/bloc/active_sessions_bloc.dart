import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/parking_repository.dart';
import 'active_sessions_state.dart';

class ActiveSessionsBloc extends Cubit<ActiveSessionsState> {
  ActiveSessionsBloc(this._repository) : super(const ActiveSessionsState());

  final ParkingRepository _repository;

  Future<void> loadSessions() async {
    emit(state.copyWith(isLoading: true));
    try {
      final sessions = await _repository.getActiveSessions();
      emit(state.copyWith(isLoading: false, sessions: sessions));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
