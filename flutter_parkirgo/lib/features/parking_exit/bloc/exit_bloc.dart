import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/parking_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import 'exit_state.dart';

class ExitBloc extends Cubit<ExitState> {
  ExitBloc(
    this._parkingRepository,
    this._transactionRepository,
  ) : super(const ExitState());

  final ParkingRepository _parkingRepository;
  final TransactionRepository _transactionRepository;

  Future<void> fetchByTicket(String ticketNumber) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, errorMessage: null));
    try {
      final session = await _parkingRepository.getSessionByTicket(ticketNumber);
      if (session.status == 'exited') {
        emit(state.copyWith(isLoading: false, errorMessage: 'Kendaraan sudah keluar sebelumnya'));
        return;
      }
      emit(state.copyWith(isLoading: false, fetchedSession: session));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void reset() {
    emit(const ExitState());
  }
}
