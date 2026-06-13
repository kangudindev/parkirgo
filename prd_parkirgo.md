# PRODUCT REQUIREMENTS DOCUMENT (PRD)

## Aplikasi Parkir Digital (On-Street Parking Management)

---

| **Dokumen** | Detail |
|---|---|
| **Nama Produk** | ParkirGo |
| **Versi Dokumen** | v1.0 |
| **Tanggal** | Juni 2026 |
| **Target Pengguna** | Juru Parkir, Supervisor, Admin Pengelola Parkir |

---

## 1. LATAR BELAKANG & TUJUAN

### 1.1 Latar Belakang

Pengelolaan parkir tepi jalan (*on-street parking*) di perkotaan Indonesia masih menghadapi tantangan signifikan, antara lain: kebocoran retribusi akibat pencatatan manual yang tidak transparan, tidak adanya data akurat jumlah kendaraan yang parkir, serta minimnya pengawasan terhadap petugas di lapangan [6][9]. Banyak daerah mengandalkan sistem karcis kertas dan pencatatan tangan yang rentan manipulasi dan sulit diaudit.[9].

### 1.2 Tujuan Produk

Membangun aplikasi digital untuk juru parkir yang:

1. **Mendigitalisasi** pencatatan kendaraan masuk/keluar pada parkir tepi jalan.
2. **Meningkatkan transparansi** retribusi parkir dan meminimalkan kebocoran pendapatan.
3. **Memfasilitasi pembayaran non-tunai (cashless)** untuk kenyamanan pengendara dan akuntabilitas.
4. **Memberikan dashboard real-time** kepada pengelola untuk monitoring dan audit.
5. **Memudahkan absensi dan tracking** juru parkir di lapangan.
6. **Menggunakan antar muka bahasa Indonesia**. semua UI menggunakan bahasa Indonesia.

> **Catatan Penting:** Aplikasi ini **TIDAK** ditujukan untuk mencari/menemukan lokasi parkir oleh pengendara. Fokus utama adalah **manajemen operasional parkir jalanan** dari sisi petugas dan pengelola.

---

## 2. GAMBARAN PRODUK (PRODUCT OVERVIEW)

### 2.1 Deskripsi Singkat

ParkirGo adalah aplikasi mobile (Flutter) dan dashboard web admin (Laravel) yang digunakan oleh juru parkir untuk mencatat masuk dan keluar kendaraan di lahan parkir tepi jalan. Sistem ini mendukung pencatatan kendaraan berbasis input plat nomor manual, QR Code kendaraan terdaftar, pembayaran tunai maupun non-tunai menggunakan **QRIS statis per zona** (gambar/payload QRIS dikelola admin), serta menyediakan laporan pendapatan harian yang real-time dan transparan [2][10].

### 2.2 Platform

| Layer | Teknologi |
|---|---|
| **Mobile App** | Flutter (iOS & Android) — untuk Juru Parkir & Supervisor |
| **Backend API** | Laravel 12 (REST API) Vue + Inertia + Vite |
| **Dashboard Admin** | Web-based (blade, satu ekosistem Laravel) |
| **Template Admin Panel** | Velzon Admin Panel v4.4.1 | [template_velzon_v4.4.1/minimal] |
| **Database** | MySQL |
| **Infrastruktur** | homelab (cloudflare tunnel) + docker |

### 2.3 Arsitektur High-Level

```
[Flutter App Juru Parkir] ──► REST API ◄── [Laravel Backend]
                                    │
[Flutter App Supervisor]   ────────►│
                                    │
[Dashboard Web Admin]      ────────►│
                                    │
                              [Database]
```

---

## 3. PERSONA PENGGUNA

| # | Persona | Deskripsi | Tujuan Utama |
|---|---|---|---|
| **P1** | **Juru Parkir (Jukir)** | Petugas di lapangan yang menangani kendaraan masuk dan keluar, menerima pembayaran retribusi. | Mencatat kendaraan dengan cepat, menerima pembayaran, melihat riwayat transaksi shift. |
| **P2** | **Supervisor** | Pengawas lapangan yang membawahi beberapa juru parkir dalam satu zona/wilayah. | Memantau kehadiran jukir, memeriksa laporan pendapatan zona, menangani keluhan. |
| **P3** | **Admin ParkirGo** | Administrator sistem yang mengelola keseluruhan aplikasi ParkirGo. | Mengelola data master, melihat dashboard Pendapatan, melakukan audit, tarik laporan periodik. |

---

## 4. FITUR UTAMA (EPIC & USER STORIES)

### 4.1 Epic 1: Autentikasi & Manajemen Pengguna

| ID | User Story | Acceptance Criteria |
|---|---|---|
| **US-001** | Sebagai Jukir, saya ingin login dengan NIK dan password agar dapat mengakses aplikasi. | — Terima NIK & password. <br>— Token JWT berlaku 8 jam (1 shift). <br>— Gagal login 3x → akun terkunci 15 menit. |
| **US-002** | Sebagai Admin, saya ingin membuat, mengedit, menonaktifkan akun jukir & supervisor. | — CRUD akun (NIK, nama, zona, foto profil). <br>— Status aktif/nonaktif. |
| **US-003** | Sebagai Jukir, saya bisa reset password melalui supervisor atau admin. | — Admin/supervisor trigger reset ke default. |

### 4.2 Epic 2: Absensi & Tracking Lokasi

| ID | User Story | Acceptance Criteria |
|---|---|---|
| **US-004** | Sebagai Jukir, saya ingin absen masuk (check-in) dan absen pulang (check-out) melalui aplikasi. | — Absen menggunakan tap tombol + foto selfie. <br>— GPS terekam saat absen (latitude, longitude). <br>— Waktu tercatat server-side. |
| **US-005** | Sebagai Supervisor, saya ingin melihat status kehadiran jukir di zona saya secara real-time. | — List jukir dengan status: Hadir / Tidak Hadir / Terlambat. <br>— Tampilkan lokasi terakhir di peta. |
| **US-006** | Sebagai Admin, saya ingin melihat riwayat absensi seluruh jukir filterable per tanggal & zona. | — Tabel riwayat absensi. <br>— Ekspor CSV/Excel. |

### 4.3 Epic 3: Pencatatan Kendaraan Masuk

| ID | User Story | Acceptance Criteria |
|---|---|---|
| **US-007** | Sebagai Jukir, saya ingin mencatat kendaraan masuk dengan input plat nomor manual dan foto kendaraan agar kendaraan dapat tercatat cepat dan akurat. | — Input plat nomor (format Indonesia). <br>— Jukir memilih jenis kendaraan secara manual (Motor/Mobil/Bus/Truk/jenis lain sesuai konfigurasi admin). <br>— Timestamp masuk otomatis. <br>— Foto kendaraan (wajib). |
| **US-008** | Sebagai Jukir, saya ingin scan QR Code kendaraan (bila pengendara memiliki QR yang terdaftar). | — Buka kamera → scan QR. <br>— Validasi QR ke backend. <br>— Auto-populate data kendaraan. |
| **US-009** | Sebagai Jukir, saya ingin melihat daftar kendaraan yang sedang parkir di zona saya (aktif). | — List kendaraan "sedang parkir". <br>— Indikator durasi parkir real-time. |

### 4.4 Epic 4: Pencatatan Kendaraan Keluar & Pembayaran

| ID | User Story | Acceptance Criteria |
|---|---|---|
| **US-010** | Sebagai Jukir, saya ingin mencatat kendaraan keluar dan menghitung tarif otomatis berdasarkan durasi & jenis kendaraan. | — Pilih kendaraan dari daftar "sedang parkir". <br>— Sistem hitung durasi (masuk → keluar). <br>— Sistem hitung tarif sesuai aturan tarif progresif per zona. |
| **US-011** | Sebagai Jukir, saya ingin menerima pembayaran **tunai** dan mencatatnya. | — Tombol "Bayar Tunai". <br>— Input nominal (validasi >= tarif). <br>— Cetak struk via Bluetooth thermal printer. |
| **US-012** | Sebagai Jukir, saya ingin menerima pembayaran **non-tunai (QRIS statis zona)** agar transaksi cashless tetap dapat dicatat bahkan saat koneksi tidak stabil. | — Tampilkan QRIS statis sesuai zona (gambar/payload). <br>— QRIS dapat digunakan saat offline. <br>— Jukir mencatat pembayaran QRIS sebagai transaksi `recorded`. <br>— Supervisor/Admin dapat melakukan verifikasi/rekonsiliasi manual menjadi `verified` atau `rejected`. |
| **US-013** | Sebagai Jukir, saya ingin memberikan opsi karcis digital ke pengendara (share via WhatsApp). | — Generate struk digital PDF/gambar. <br>— Share via intent share Android/iOS. |
| **US-022** | Sebagai Jukir, saya ingin menangani kendaraan yang **kehilangan karcis parkir** saat keluar. | — Tombol "Karcis Hilang" di exit screen. <br>— Cari kendaraan dari daftar parkir aktif. <br>— Verifikasi 4 foto: KTP, STNK, kendaraan tampak depan, dan pengendara. <br>— Input data pemilik: nama, NIK, alamat, plat STNK. <br>— Sistem hitung tarif + denda `card_lost` per zona & jenis. <br>— Wajib bayar sebelum keluar. <br>— Semua foto & data tersimpan sebagai bukti audit. |
| **US-023** | Sebagai Jukir, saya ingin menangani **kendaraan yang tidak tercatat** di sistem saat akan keluar. | — Tombol "Kendaraan Tidak Tercatat" di exit screen. <br>— Input plat manual + foto kendaraan. <br>— Verifikasi 4 foto: KTP, STNK, kendaraan tampak depan, dan pengendara. <br>— Input data pemilik: nama, NIK, alamat, plat STNK. <br>— Sistem buat session + langsung close. <br>— Tarif = tarif maksimum harian. <br>— Sistem hitung denda `unregistered` per zona & jenis. <br>— Wajib bayar sebelum keluar. |
| **US-024** | Sebagai Admin, saya ingin mengkonfigurasi **denda** per zona, jenis kendaraan, dan tipe pelanggaran. | — CRUD denda di halaman zona. <br>— Tipe denda: `card_lost` (karcis hilang) dan `unregistered` (tidak tercatat). <br>— Nominal denda bisa berbeda per jenis kendaraan. <br>— Status aktif/nonaktif. |

### 4.5 Epic 5: Manajemen Tarif & Zona

| ID | User Story | Acceptance Criteria |
|---|---|---|
| **US-014** | Sebagai Admin, saya ingin mengelola zona parkir (nama, koordinat boundary, kapasitas). | — CRUD zona. <br>— Tentukan koordinat polygon zona (via peta Leaflet/Google Maps). |
| **US-015** | Sebagai Admin, saya ingin mengkonfigurasi tarif parkir per zona, jenis kendaraan, tipe tarif, dan aturan progresif. | — Tipe tarif: flat atau progresif. <br>— Tarif flat dibayar saat kendaraan masuk. <br>— Tarif progresif dibayar saat kendaraan keluar berdasarkan durasi. <br>— Tarif maksimum per hari. <br>— Grace period dan pembulatan durasi dapat dikonfigurasi. <br>— Jam operasional zona. |

### 4.6 Epic 6: Dashboard & Laporan

| ID | User Story | Acceptance Criteria |
|---|---|---|
| **US-016** | Sebagai Admin, saya ingin melihat dashboard pendapatan harian real-time per zona. | — Total pendapatan hari ini. <br>— Jumlah kendaraan parkir. <br>— Perbandingan tunai vs non-tunai. <br>— Grafik tren mingguan. |
| **US-017** | Sebagai Supervisor, saya ingin melihat laporan pendapatan shift jukir di zona saya. | — Rincian transaksi per jukir. <br>— Rekap setoran vs target. |
| **US-018** | Sebagai Admin, saya ingin mengekspor laporan pendapatan harian/mingguan/bulanan dalam format PDF & Excel. | — Filter tanggal, zona, tipe pembayaran. <br>— Ekspor CSV/Excel/PDF. |
| **US-019** | Sebagai Jukir, saya ingin melihat ringkasan pendapatan pribadi selama shift berjalan. | — Total transaksi, total nominal, jumlah kendaraan. <br>— Estimasi setoran akhir shift. |

### 4.7 Epic 7: Notifikasi & Alert

| ID | User Story | Acceptance Criteria |
|---|---|---|
| **US-020** | Sebagai Supervisor, saya ingin menerima notifikasi bila ada jukir yang tidak absen tepat waktu. | — Push notifikasi via Firebase. <br>— Notifikasi in-app. |
| **US-021** | Sebagai Admin, saya ingin alert bila ada anomali pendapatan (di bawah threshold) pada suatu zona. | — Threshold configurable. <br>— Alert via dashboard. |

---

## 5. KEBUTUHAN NON-FUNGSIONAL (NFR)

| Aspek | Requirement |
|---|---|
| **Performa** | Response API < 500ms untuk 95% request. Flutter app startup < 3 detik. |
| **Offline Mode** | Jukir tetap bisa mencatat kendaraan masuk/keluar dan pembayaran tunai/QRIS statis meski tidak ada koneksi. Data disimpan lokal (Hive/SQLite) dan disinkronisasi saat koneksi pulih. Setiap data offline wajib memiliki `local_id`, `idempotency_key`, dan `sync_status` untuk mencegah duplikasi. |
| **Keamanan** | Semua API endpoint menggunakan HTTPS + JWT Auth. Role-based access control (RBAC). PIN/biometric untuk transaksi refund/void. |
| **Skalabilitas** | Arsitektur mendukung minimal 5.000 juru parkir konkuren dengan 500 transaksi/detik. |
| **Kompatibilitas** | Flutter app support Android 7+ & iOS 14+. |
| **Ukuran APK** | < 50 MB (Android), < 60 MB (iOS). |

---

## 6. DESAIN SISTEM & DATA MODEL

### 6.1 Entity Relationship Diagram (Konseptual)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────────┐
│    users     │────→│   shifts     │←────│   attendance     │
│ (jukir, sup, │     │ (jadwal)     │     │ (absen in/out)   │
│  admin)      │     └─────────────┘     └─────────────────┘
└──────┬───────┘
       │
       │  ┌─────────────┐     ┌────────────────────────┐
       ├─→│   vehicles   │────→│   parking_sessions      │
       │  │ (plat, jenis)│     │ (in_time, out_time,      │
       │  └─────────────┘     │  duration, total_fee)     │
       │                      └────────┬───────────────┘
       │                               │
       │                      ┌────────▼───────────────┐
       │                      │   transactions           │
       │                      │ (amount, method, status) │
       │                      └──────────────────────────┘
       │
       │  ┌─────────────┐     ┌─────────────────┐
       ├─→│    zones     │────→│   zone_tariffs    │
       │  │ (name, coord)│     │ (vehicle_type,    │
       │  └─────────────┘     │  rate_flat,        │
       │                      │  rate_progressive)  │
       │                      └─────────────────┘
       │
       │  ┌──────────────┐
       └─→│  settlements  │ (setoran akhir shift)
          │  (amount,     │
          │   proof_img)  │
          └──────────────┘
```

### 6.2 Tabel Database Kunci

| Tabel | Kolom Utama |
|---|---|
| `users` | id, nik, name, role (jukir/supervisor/admin), zone_id, phone, photo, status, password, device_id |
| `zones` | id, name, city, polygon_coordinates (JSON), capacity, qris_image, qris_payload, qris_merchant_name, qris_is_active, is_active |
| `zone_tariffs` | id, zone_id, vehicle_type (motor/mobil/bus/truk), pricing_type (flat/progressive), payment_timing (entry/exit), flat_rate, progressive_rate, max_daily, grace_period_minutes, rounding_strategy, start_hour, end_hour |
| `shifts` | id, user_id, zone_id, date, start_time, end_time, status |
| `attendances` | id, local_id, user_id, shift_id, check_in_time, check_in_lat, check_in_lng, check_in_photo, check_out_time, check_out_lat, check_out_lng, sync_status |
| `parking_sessions` | id, local_id, vehicle_plate, vehicle_type, zone_id, jukir_id, entry_time, exit_time, entry_photo, exit_photo, duration_minutes, total_fee, pricing_type, payment_timing, status (active/completed/void), sync_status, idempotency_key, **owner_name, owner_nik, owner_address, owner_ktp_photo, owner_stnk_photo, exit_vehicle_photo, driver_photo, is_card_lost, penalty_fee, jukir_note** |
| `transactions` | id, local_id, session_id, amount, payment_method (cash/qris_static), payment_status (recorded/verified/rejected/refunded), qris_ref_id, verification_by, verification_at, transaction_time, sync_status, idempotency_key |
| `settlements` | id, user_id, shift_id, total_transactions, total_cash, total_qris, total_amount, proof_image, status |
| `zone_penalties` | id, zone_id, vehicle_type (nullable), penalty_type (card_lost/unregistered), amount, status |
| `audit_logs` | id, user_id, action, entity_type, entity_id, old_values, new_values, ip_address, device_id, created_at |

---

## 7. DESAIN UI/UX — KEY SCREENS (FLUTTER APP)

### 7.1 Juru Parkir App

| Screen | Elemen Kunci |
|---|---|
| **Login** | Input NIK, password, tombol login. Logo instansi. |
| **Home / Dashboard Jukir** | Status absensi (check-in/check-out button), ringkasan pendapatan shift, jumlah kendaraan aktif, tombol "Kendaraan Masuk". |
| **Kendaraan Masuk** | Input plat manual, dropdown jenis kendaraan, tombol ambil foto, informasi tipe tarif zona. Jika tarif flat: tampilkan tarif dan pilihan bayar saat masuk. |
| **Daftar Parkir Aktif** | List card kendaraan yang sedang parkir, tampilkan plat, durasi, timer real-time. Swipe/tap untuk "Kendaraan Keluar". |
| **Kendaraan Keluar** | Detail kendaraan, hitungan tarif otomatis. Jika tarif progresif: pilih metode bayar (Tunai/QRIS statis), lalu konfirmasi keluar. |
| **Riwayat Transaksi** | List transaksi hari ini, filterable. Total pendapatan di header. |
| **Setoran Akhir Shift** | Ringkasan shift (total transaksi, cash, non-cash), upload foto setoran, tombol submit. |
| **Profil** | Nama, NIK, foto, zona. Tombol logout. |

### 7.2 Supervisor App (subset fitur Jukir + pengawasan)

| Screen | Elemen Kunci |
|---|---|
| **Dashboard Zona** | Total pendapatan zona hari ini, jumlah jukir aktif, alert anomali. |
| **Monitoring Kehadiran** | List jukir + status + lokasi di peta mini. |
| **Laporan Shift** | Rekap per jukir, approval setoran. |

### 7.3 Admin Dashboard (Web)

| Halaman | Elemen Kunci |
|---|---|
| **Dashboard Utama** | Grafik Pendapatan real-time, total kendaraan, heatmap zona tersibuk, rasio cash vs cashless. |
| **Manajemen Zona** | Tabel zona, CRUD, peta interaktif untuk boundary. |
| **Manajemen Tarif** | Form konfigurasi tarif per zona + jenis kendaraan, tipe tarif flat/progresif, waktu pembayaran, grace period, dan aturan pembulatan. |
| **Manajemen Pengguna** | Tabel user, CRUD, assign zona. |
| **Laporan** | Filter multi-kriteria, tabel data, tombol ekspor Excel/PDF. |
| **Audit Log** | Log semua transaksi & perubahan data. |

---

## 8. ALUR BISNIS UTAMA (USER FLOW)

### 8.1 Flow Parkir Kendaraan (Happy Path)

```
1. Jukir Absen Masuk → Selfie + GPS
2. Kendaraan Datang → Jukir: Input Plat Manual / Scan QR kendaraan terdaftar → Pilih Jenis Kendaraan → Ambil Foto
3. Sistem: Deteksi tipe tarif zona & jenis kendaraan
   a. Tarif Flat: Sistem tampilkan tarif → Jukir pilih pembayaran Tunai/QRIS Statis → Simpan → Cetak/Bagikan Struk
   b. Tarif Progresif: Sistem buat parking_session aktif tanpa pembayaran awal
4. Kendaraan Pulang → Jukir: Pilih kendaraan aktif / Scan QR → Konfirmasi Keluar
5. Sistem: Hitung durasi dan tarif otomatis untuk tarif progresif
6. Pembayaran tarif progresif:
   a. Tunai: Jukir terima uang → Input nominal → Konfirmasi → Selesai
   b. QRIS Statis: Jukir tampilkan QRIS zona → Pengendara scan & bayar → Jukir catat transaksi sebagai recorded
7. Supervisor/Admin melakukan verifikasi/rekonsiliasi QRIS bila diperlukan
8. Struk digital tersedia untuk dibagikan
9. Akhir Shift: Jukir submit setoran → cetak struk pencatatan parkir → Supervisor verifikasi
```

### 8.2 Flow Offline

```
1. Saat offline, jukir tetap bisa input kendaraan masuk/keluar.
2. Pembayaran tunai dan QRIS statis tetap dapat dicatat.
3. Data disimpan di local storage (Hive/SQLite) dengan `local_id`, `idempotency_key`, dan `sync_status`.
4. Saat koneksi pulih → background sync ke server.
5. Konflik resolusi: server timestamp diutamakan, client data di-merge, dan `idempotency_key` digunakan untuk mencegah duplikasi transaksi.
```

---

## 9. INTEGRASI EKSTERNAL

| Integrasi | Tujuan | Provider |
|---|---|---|
| **QRIS Statis Zona** | Pembayaran non-tunai offline-capable menggunakan gambar/payload QRIS per zona | Upload gambar/payload QRIS oleh Admin |
| **Firebase Cloud Messaging** | Push notification | Google Firebase |
| **OCR Plat Nomor** | Fitur lanjutan setelah MVP bila dibutuhkan | Google ML Kit / Tesseract / PlateRecognizer API |
| **Google Maps / Mapbox** | Peta zona & tracking | Google Maps SDK |
| **WhatsApp Share Intent** | Share struk digital dari aplikasi | Native Android/iOS Share Intent |
| **Bluetooth Printing** | Cetak struk thermal | Flutter Blue Plus (ESC/POS) |

---

## 10. MILESTONE & TIMELINE

| Fase | Durasi | Deliverable |
|---|---|---|
| **Phase 1: Discovery & Design** | 2 Minggu | Wireframe, desain UI, arsitektur backend, DB schema final |
| **Phase 2: Core Backend** | 4 Minggu | REST API (auth, zones, tariffs, users, attendance) |
| **Phase 3: Flutter App - Jukir Core** | 6 Minggu | Login, absensi, kendaraan masuk/keluar, pembayaran tunai, QRIS statis zona, offline mode |
| **Phase 4: Flutter App - Supervisor** | 2 Minggu | Dashboard zona, monitoring kehadiran |
| **Phase 5: Admin Dashboard** | 4 Minggu | Dashboard, manajemen data, laporan |
| **Phase 6: Integrasi Lanjutan & Optimasi** | 3 Minggu | QRIS rekonsiliasi, OCR plat nomor opsional, optimasi performa, anomaly alert awal |
| **Phase 7: Testing & UAT** | 3 Minggu | QA, UAT dengan perwakilan jukir, bug fixing |
| **Phase 8: Pilot & Go-Live** | 2 Minggu | Deployment, training jukir, go-live 1 zona percontohan |
| **Total** | **±26 Minggu (~6 Bulan)** | |

---

## 11. RISIKO & MITIGASI

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Jukir gagap teknologi | Adopsi rendah | UI sesederhana mungkin, training intensif, panduan video, fitur terbatas di awal. |
| Koneksi internet tidak stabil | Gagal sinkronisasi data | **Offline-first architecture** wajib. Sinkronisasi background. |
| Kecurangan oleh jukir | Kebocoran Pendapatan | Foto kendaraan wajib masuk & keluar. GPS tracking. Audit log tidak bisa dihapus. |
| Pembayaran QRIS tidak bisa diverifikasi otomatis saat offline | Potensi transaksi QRIS tidak valid | Gunakan QRIS statis zona dengan status `recorded`, lalu Supervisor/Admin melakukan verifikasi/rekonsiliasi manual. Fallback ke tunai tetap tersedia. |
| Perbedaan aturan tarif antar daerah | Sistem tidak fleksibel | Tarif engine configurable per zona, per jenis kendaraan, aturan progresif dinamis. |

---

## 12. DEFINISI SUKSES (SUCCESS METRICS)

| Metrik | Target (6 bulan pasca-launch) |
|---|---|
| Jumlah juru parkir aktif menggunakan aplikasi | ≥ 80% dari total jukir terdaftar |
| Persentase transaksi tercatat digital | ≥ 90% |
| Peningkatan Pendapatan retribusi parkir | ≥ 20% dibanding periode manual |
| Waktu pencatatan per kendaraan | < 15 detik |
| Uptime sistem | ≥ 99,5% |
| Keluhan pengguna terkait aplikasi | < 5 per bulan |

---