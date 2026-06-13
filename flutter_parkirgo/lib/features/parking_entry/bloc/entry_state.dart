import 'package:equatable/equatable.dart';

import '../../../data/models/zone_model.dart';

class EntryState extends Equatable {
  const EntryState({
    this.isLoading = false,
    this.isSuccess = false,
    this.createdSessionId,
    this.ticketNumber,
    this.tariffInfo,
    this.zones = const [],
    this.selectedZone,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSuccess;
  final int? createdSessionId;
  final String? ticketNumber;
  final String? tariffInfo;
  final List<ZoneModel> zones;
  final ZoneModel? selectedZone;
  final String? errorMessage;

  EntryState copyWith({
    bool? isLoading,
    bool? isSuccess,
    int? createdSessionId,
    String? ticketNumber,
    String? tariffInfo,
    List<ZoneModel>? zones,
    ZoneModel? selectedZone,
    String? errorMessage,
  }) {
    return EntryState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      createdSessionId: createdSessionId ?? this.createdSessionId,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      tariffInfo: tariffInfo ?? this.tariffInfo,
      zones: zones ?? this.zones,
      selectedZone: selectedZone ?? this.selectedZone,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSuccess,
        createdSessionId,
        ticketNumber,
        tariffInfo ?? '',
        zones,
        selectedZone,
        errorMessage ?? '',
      ];
}
