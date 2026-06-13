# STRUKTUR FLUTTER PROJECT — ParkirGo Mobile App

## 📁 STRUKTUR FOLDER

```
flutter_parkirgo/
├── lib/
│   ├── main.dart                          # Entry point, BlocProvider, GoRouter
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_url.dart               # Base URL, endpoint paths
│   │   │   └── constants.dart             # Storage key, timeouts, dll
│   │   ├── theme/
│   │   │   ├── app_theme.dart             # Tema utama
│   │   │   ├── app_colors.dart            # Palet warna
│   │   │   └── app_typography.dart        # Font styles
│   │   ├── components/                    # Reusable widgets
│   │   │   ├── app_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── app_card.dart
│   │   │   ├── status_badge.dart          # Lunas/Belum/Recorded badge
│   │   │   ├── vehicle_type_picker.dart   # Dropdown jenis kendaraan
│   │   │   ├── camera_capture.dart        # Widget kamera + crop
│   │   │   ├── qr_scanner_overlay.dart
│   │   │   ├── timer_widget.dart          # Timer real-time durasi parkir
│   │   │   ├── loading_overlay.dart
│   │   │   └── empty_state.dart
│   │   ├── network/
│   │   │   ├── dio_client.dart            # Dio instance + interceptor
│   │   │   ├── auth_interceptor.dart      # Inject token, handle 401
│   │   │   └── api_exception.dart         # Error mapping
│   │   ├── storage/
│   │   │   ├── local_database.dart        # SQLite/Hive init
│   │   │   └── daos/                      # Data access objects
│   │   │       ├── session_dao.dart
│   │   │       ├── transaction_dao.dart
│   │   │       └── attendance_dao.dart
│   │   ├── sync/
│   │   │   ├── sync_engine.dart           # Background sync logic
│   │   │   └── sync_queue.dart            # Antrian data pending
│   │   ├── printer/
│   │   │   ├── printer_service.dart       # Bluetooth scan + connect
│   │   │   └── receipt_builder.dart       # ESC/POS format (karcis + struk)
│   │   └── router/
│   │       ├── app_router.dart            # GoRouter config
│   │       └── auth_guard.dart            # Cek login + role
│   │
│   ├── data/
│   │   ├── models/                        # Data classes + JSON serialization
│   │   │   ├── user_model.dart
│   │   │   ├── zone_model.dart
│   │   │   ├── zone_tariff_model.dart
│   │   │   ├── parking_session_model.dart
│   │   │   ├── transaction_model.dart
│   │   │   ├── attendance_model.dart
│   │   │   ├── settlement_model.dart
│   │   │   └── sync_item_model.dart
│   │   ├── datasources/
│   │   │   ├── remote/
│   │   │   │   ├── auth_remote_ds.dart
│   │   │   │   ├── parking_remote_ds.dart
│   │   │   │   ├── transaction_remote_ds.dart
│   │   │   │   ├── attendance_remote_ds.dart
│   │   │   │   └── settlement_remote_ds.dart
│   │   │   └── local/
│   │   │       ├── auth_local_ds.dart
│   │   │       ├── parking_local_ds.dart
│   │   │       └── sync_local_ds.dart
│   │   └── repositories/
│   │       ├── auth_repository.dart
│   │       ├── parking_repository.dart
│   │       ├── transaction_repository.dart
│   │       ├── attendance_repository.dart
│   │       ├── settlement_repository.dart
│   │       └── sync_repository.dart
│   │
│   └── features/
│       ├── auth/
│       │   ├── bloc/
│       │   │   ├── auth_bloc.dart
│       │   │   ├── auth_event.dart
│       │   │   └── auth_state.dart
│       │   ├── pages/
│       │   │   ├── splash_page.dart
│       │   │   └── scan_qr_page.dart          # Ganti: login via QR ID Card
│       │   └── widgets/
│       │       └── qr_scanner_fullscreen.dart
│       │
│       ├── attendance/
│       │   ├── bloc/
│       │   │   ├── attendance_bloc.dart
│       │   │   └── attendance_state.dart
│       │   └── pages/
│       │       └── attendance_page.dart      # Selfie + GPS + confirm
│       │
│       ├── home/
│       │   ├── bloc/
│       │   │   ├── home_bloc.dart
│       │   │   └── home_state.dart
│       │   ├── pages/
│       │   │   ├── home_jukir_page.dart      # Dashboard jukir
│       │   │   └── home_supervisor_page.dart # Dashboard supervisor
│       │   └── widgets/
│       │       ├── summary_card.dart
│       │       ├── active_session_card.dart
│       │       └── quick_actions.dart
│       │
│       ├── parking_entry/
│       │   ├── bloc/
│       │   │   ├── entry_bloc.dart
│       │   │   └── entry_state.dart
│       │   ├── pages/
│       │   │   └── parking_entry_page.dart   # Input plat + foto + pilih jenis
│       │   └── widgets/
│       │       ├── plate_input.dart
│       │       ├── vehicle_type_selector.dart
│       │       └── tariff_info_card.dart     # Info flat/progresif + bayar
│       │
│       ├── parking_active/
│       │   ├── bloc/
│       │   │   ├── active_sessions_bloc.dart
│       │   │   └── active_sessions_state.dart
│       │   ├── pages/
│       │   │   └── active_sessions_page.dart  # Daftar parkir aktif + timer
│       │   └── widgets/
│       │       ├── session_card.dart
│       │       └── timer_text.dart
│       │
│       ├── parking_exit/
│       │   ├── bloc/
│       │   │   ├── exit_bloc.dart
│       │   │   └── exit_state.dart
│       │   ├── pages/
│       │   │   └── parking_exit_page.dart    # Scan QR / pilih manual
│       │   └── widgets/
│       │       ├── qr_scanner.dart
│       │       ├── session_detail_card.dart
│       │       └── payment_method_selector.dart
│       │
│       ├── payment/
│       │   ├── bloc/
│       │   │   ├── payment_bloc.dart
│       │   │   └── payment_state.dart
│       │   ├── pages/
│       │   │   ├── cash_payment_page.dart    # Input nominal + kembalian
│       │   │   └── qris_payment_page.dart    # Tampilkan QRIS zona
│       │   └── widgets/
│       │       ├── cash_input.dart
│       │       └── qris_display.dart
│       │
│       ├── history/
│       │   ├── bloc/
│       │   │   ├── history_bloc.dart
│       │   │   └── history_state.dart
│       │   ├── pages/
│       │   │   └── history_page.dart
│       │   └── widgets/
│       │       └── transaction_tile.dart
│       │
│       ├── settlement/
│       │   ├── bloc/
│       │   │   ├── settlement_bloc.dart
│       │   │   └── settlement_state.dart
│       │   ├── pages/
│       │   │   └── settlement_page.dart      # Ringkasan shift + foto setor
│       │   └── widgets/
│       │       └── summary_section.dart
│       │
│       ├── supervisor/
│       │   ├── monitoring/
│       │   │   ├── bloc/
│       │   │   │   ├── monitoring_bloc.dart
│       │   │   │   └── monitoring_state.dart
│       │   │   ├── pages/
│       │   │   │   └── monitoring_page.dart   # List jukir + status
│       │   │   └── widgets/
│       │   │       └── jukir_map.dart
│       │   ├── verification/
│       │   │   ├── bloc/
│       │   │   │   ├── verification_bloc.dart
│       │   │   │   └── verification_state.dart
│       │   │   ├── pages/
│       │   │   │   ├── verify_qris_page.dart
│       │   │   │   └── verify_settlement_page.dart
│       │   │   └── widgets/
│       │   │       └── verification_card.dart
│       │   └── reports/
│       │       ├── pages/
│       │       │   └── zone_report_page.dart
│       │       └── widgets/
│       │           └── report_chart.dart
│       │
│       └── profile/
│           ├── pages/
│           │   └── profile_page.dart
│           └── widgets/
│               └── logout_button.dart
│
├── assets/
│   ├── images/
│   │   ├── logo_parkirgo.png
│   │   ├── empty_state.svg
│   │   └── illustrations/
│   └── fonts/
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
└── pubspec.yaml
```

---

## 📦 DEPENDENCIES

```yaml
dependencies:
  flutter_bloc: ^8.1.6         # State management
  dio: ^5.4.3+1                # HTTP client
  go_router: ^14.2.0           # Routing + auth guard
  hive_flutter: ^1.1.0         # Local DB (offline)
  mobile_scanner: ^5.0.0       # Scan QR karcis
  qr_flutter: ^4.1.0           # Generate QR buat cetak karcis
  image_picker: ^1.1.0         # Foto kendaraan + selfie
  geolocator: ^11.1.0          # GPS
  flutter_blue_plus: ^1.32.7   # Bluetooth thermal printer
  esc_pos_bluetooth: ^2.1.1    # ESC/POS protocol
  connectivity_plus: ^6.0.5    # Deteksi offline/online
  share_plus: ^9.0.0           # Share struk via WA/intent
  path_provider: ^2.1.3        # Path file lokal
  intl: ^0.19.0                # Format tanggal, rupiah
  equatable: ^2.0.5            # Value equality buat state
  freezed_annotation: ^2.4.1   # Immutable model generator
  json_annotation: ^4.8.1      # JSON serialization
  cached_network_image: ^3.3.1 # Cache gambar QRIS zona

dev_dependencies:
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.7.1
  bloc_test: ^9.1.7
  mocktail: ^1.0.3
```

---

## 🧭 ROUTING (GoRouter + AuthGuard)

```
/ → splash_page (cek token lokal)

/scan-qr → scan_qr_page (scan QR ID Card → login)

Scope: JUKIR & SUPERVISOR
/attendance          → attendance_page        (selfie + GPS)

Scope: JUKIR
/home-jukir          → home_jukir_page        (dashboard)
/parking-entry       → parking_entry_page     (input kendaraan)
/parking-active      → active_sessions_page   (daftar parkir)
/parking-exit        → parking_exit_page      (scan QR + bayar)
/parking-exit/cash   → cash_payment_page      (bayar tunai)
/parking-exit/qris   → qris_payment_page      (bayar QRIS)
/history             → history_page           (riwayat transaksi)
/settlement          → settlement_page        (setoran shift)

Tambahan scope: SUPERVISOR
/monitoring          → monitoring_page        (lokasi jukir)
/verify-qris         → verify_qris_page       (verifikasi QRIS)
/verify-settlement   → verify_settlement_page (approve setoran)
/report              → zone_report_page       (laporan zona)

Shared:
/profile             → profile_page           (profil + logout)
```

---

## 📋 SCREEN-BY-SCREEN

| # | Screen | Input Data | Cetak? | API |
|---|---|---|---|---|
| 1 | **Scan QR ID Card** | Scan QR (`qr_auth_token`) | - | POST `/login/qr` |
| 2 | **Absen Masuk** | Selfie, GPS | - | POST `/attendances` |
| 3 | **Home Jukir** | Summary dari `/me` | - | GET `/me`, GET `/zones` |
| 4 | **Parkir Masuk** | Plat, jenis, foto | ✅ Karcis QR | POST `/parking-sessions` |
| 5 | **Parkir Masuk (bayar flat)** | Nominal tunai / QRIS | ✅ Karcis QR (LUNAS) | POST `/transactions` |
| 6 | **Parkir Aktif** | List sessions | - | GET `/parking-sessions` |
| 7 | **Parkir Keluar (scan QR)** | Scan QR karcis | - | GET `/by-ticket/{ticket}` |
| 8 | **Parkir Keluar (manual)** | Pilih dari daftar | - | - |
| 9 | **Parkir Keluar (foto)** | Foto keluar | - | POST `/close` |
| 10 | **Bayar tunai** | Nominal bayar | ✅ Struk | POST `/transactions` |
| 11 | **Bayar QRIS** | Scan QRIS zona | ✅ Struk | POST `/transactions` |
| 12 | **Riwayat** | Filter date | - | GET `/transactions` |
| 13 | **Setoran** | Ringkasan, foto setor | ✅ Struk setoran | POST `/settlements` |
| 14 | **Absen Pulang** | Selfie, GPS | - | POST `/attendances` |
| 15 | **Monitoring (sup)** | List jukir + peta | - | GET `/attendances` |
| 16 | **Verifikasi QRIS (sup)** | List pending | - | POST `/transactions/verify` |
| 17 | **Verifikasi Setoran (sup)** | List pending | - | POST `/settlements/approve` |
| 18 | **Laporan Zona (sup)** | Filter | - | GET `/reports` |

---

## 🗂️ PRIORITAS BUILD FLUTTER

| Phase | Fitur | Screen | Estimasi |
|---|---|---|---|
| **P1** | Splash + Scan QR ID Card + Auth guard + Profile | 1 | 3 hari |
| **P2** | Absen Masuk/Pulang + GPS + Selfie | 2, 14 | 3 hari |
| **P3** | Home Dashboard + Summary | 3 | 2 hari |
| **P4** | Parkir Masuk + Cetak Karcis QR | 4, 5 | 5 hari |
| **P5** | Parkir Aktif + Timer Real-time | 6 | 2 hari |
| **P6** | Parkir Keluar (Scan QR + Manual) + Bayar | 7, 8, 9, 10, 11 | 5 hari |
| **P7** | Riwayat Transaksi | 12 | 2 hari |
| **P8** | Setoran Shift | 13 | 2 hari |
| **P9** | Offline Mode + Sync Engine | semua | 4 hari |
| **P10** | Supervisor: Monitoring | 15 | 3 hari |
| **P11** | Supervisor: Verifikasi QRIS + Setoran | 16, 17 | 3 hari |
| **P12** | Supervisor: Laporan Zona | 18 | 2 hari |
| | **Total** | | **~36 hari kerja** |
