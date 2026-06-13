import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/attendance_repository.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Cubit<AttendanceState> {
  AttendanceBloc(this._repository) : super(const AttendanceState());

  final AttendanceRepository _repository;

  Future<void> checkIn({
    required int zoneId,
    double? latitude,
    double? longitude,
    String? selfiePath,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.checkIn(
        zoneId: zoneId,
        checkInLat: latitude,
        checkInLng: longitude,
        selfiePath: selfiePath,
      );
      emit(state.copyWith(isLoading: false, isCheckedIn: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> checkOut({
    required int zoneId,
    double? latitude,
    double? longitude,
    String? selfiePath,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.checkOut(
        zoneId: zoneId,
        checkOutLat: latitude,
        checkOutLng: longitude,
        selfiePath: selfiePath,
      );
      emit(state.copyWith(isLoading: false, isCheckedIn: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
