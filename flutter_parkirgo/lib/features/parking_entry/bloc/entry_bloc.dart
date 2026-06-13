import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/parking_repository.dart';
import 'entry_state.dart';

class EntryBloc extends Cubit<EntryState> {
  EntryBloc(this._repository) : super(const EntryState());

  final ParkingRepository _repository;

  Future<void> loadZones() async {
    try {
      final zones = await _repository.getZones();
      emit(state.copyWith(zones: zones));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void selectZone(ZoneModel zone) {
    emit(state.copyWith(selectedZone: zone));
  }

  Future<void> submitEntry({
    required int zoneId,
    required String plateNumber,
    required String vehicleType,
    String? entryPhotoPath,
  }) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, errorMessage: null));
    try {
      final session = await _repository.createSession(
        zoneId: zoneId,
        plateNumber: plateNumber,
        vehicleType: vehicleType,
        entryPhotoPath: entryPhotoPath,
      );
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        createdSessionId: session.id,
        ticketNumber: session.ticketNumber,
        tariffInfo: _buildTariffInfo(session),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  String _buildTariffInfo(dynamic session) {
    final paymentTiming = session.paymentTiming;
    final amount = session.estimatedAmount;
    if (paymentTiming == 'entry' && amount != null) {
      return 'Bayar di awal: Rp ${_formatRupiah(amount)}';
    }
    return 'Bayar saat keluar (tarif progresif)';
  }

  String _formatRupiah(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match.group(1)}.',
        );
  }

  void reset() {
    emit(const EntryState());
  }
}
