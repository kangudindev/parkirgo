# ALUR APLIKASI PARKIRGO — Mobile App

## 1. LOGIN & ROLE ROUTING

```
[BUKA APP] → [SPLASH] → [CEK TOKEN LOKAL]
                │
                ├─ Token valid & belum expired → [HOME by role]
                │
                └─ Token expired/tidak ada → [SCAN QR ID CARD]
                        │
                        └─ Scan QR di Kartu Juru Parkir
                            → POST /api/v1/login/qr {qr_token}
                            │
                            ├─ success → simpan token → HOME
                            │
                            └─ gagal   → "Kartu tidak valid / tidak aktif"
```

**Login hanya via QR Code di ID Card Juru Parkir.**
- Setiap jukir/supervisor punya kartu fisik dgn QR Code unik (`qr_auth_token`)
- QR di-generate oleh Admin dari Web Dashboard
- Kartu hilang? Admin regenerate QR → kartu lama otomatis tidak berlaku
- Token JWT berlaku 8 jam (1 shift). Pas expired → scan QR lagi

Role dari response login menentukan UI:
- **jukir** → Dashboard Jukir (menu: parkir masuk, parkir aktif, riwayat, setoran)
- **supervisor** → Dashboard Jukir + Menu Supervisor (monitoring, verifikasi QRIS, verifikasi setoran)
- **admin** → **TOLAK AKSES** + Alert: "Login admin hanya melalui Web Dashboard"

---

## 2. ABSENSI MULAI SHIFT

```
[HOME DASHBOARD]
    │
    ├─ Status: BELUM ABSEN
    │   └─ [ABSEN MASUK]
    │       ├─ Buka kamera → Selfie
    │       ├─ Capture GPS (lat, lng) otomatis
    │       └─ POST /api/v1/attendances
    │           └─ Success → Status berubah jadi "HADIR"
    │
    └─ Status: SUDAH ABSEN
        └─ Tampilkan ringkasan shift
```

**Home Dashboard (setelah absen):**
```
┌─────────────────────────────────┐
│  ☀️ Selamat Pagi, Budi!         │
│  📍 Zona Monas Timur            │
│  🟢 Hadir sejak 07:02           │
│                                 │
│  ┌──────────┬──────────┐        │
│  │ Kendaraan│ Pendapatan│        │
│  │ Aktif    │ Hari Ini  │        │
│  │   12     │  Rp 87.000│        │
│  └──────────┴──────────┘        │
│                                 │
│  ┌──────────────────────┐       │
│  │  🚗 KENDARAAN MASUK  │       │
│  └──────────────────────┘       │
│          (tombol besar)         │
│                                 │
│  Daftar Parkir Aktif (3 terbaru)│
│  ┌─────────────────────────┐    │
│  │ B 1234 PGO · ⏱ 32 mnt  │    │
│  │ B 9876 GO  · ⏱ 2 jam   │    │
│  │ F 5678 AB  · ⏱ 5 mnt   │    │
│  └─────────────────────────┘    │
│  [Lihat Semua →]                │
└─────────────────────────────────┘
```

---

## 3. KENDARAAN MASUK + CETAK KARCIS QR

```
[KENDARAAN MASUK]
    │
    ├─ Opsi Input Plat:
    │   ├─ [📝 Manual] → Keyboard + format plat Indonesia otomatis
    │   │   (contoh: B 1234 XX)
    │   │
    │   └─ [📷 Scan QR] → Buka kamera → Scan QR kendaraan terdaftar
    │       └─ Validasi ke backend → auto-fill data kendaraan (US-008)
    │
    ├─ Pilih Jenis Kendaraan (Motor/Mobil/Bus/Truk)
    │
    ├─ [📸 Ambil Foto Kendaraan] — WAJIB
    │
    ├─ POST /api/v1/parking-sessions
    │   └─ Response: data session + info tipe tarif zona
    │
    ├─ ════════════ TIPE TARIF ════════════
    │
    ├─ 🔵 TARIF FLAT (payment_timing = entry):
    │   ├─ Tampilkan: "Tarif Motor: Rp 3.000 (Bayar di Awal)"
    │   ├─ Pilih Metode Bayar:
    │   │   ├─ [💰 Bayar Tunai] → input nominal → POST /transactions
    │   │   └─ [📱 Bayar QRIS] → tampilkan QRIS statis zona → POST /transactions
    │   └─ Status: LUNAS
    │
    ├─ 🟠 TARIF PROGRESIF (payment_timing = exit):
    │   └─ Status: BELUM BAYAR (bayar pas keluar)
    │
    ├─ ════════════ CETAK KARCIS ════════════
    │
    ├─ 🖨 Cetak Karcis Parkir (Bluetooth thermal):
    │   ┌─────────────────────────────┐
    │   │         PARKIRGO            │
    │   │   Zona Monas Timur          │
    │   │                             │
    │   │   No Tiket: TMR-250613-0001 │
    │   │   Masuk: 07:30:45           │
    │   │   Jenis: MOTOR              │
    │   │   Tarif: Rp 3.000 (Flat)    │
    │   │   Status: ✅ LUNAS          │
    │   │        / ⏳ BELUM           │
    │   │                             │
    │   │   ┌─────────────────────┐   │
    │   │   │   ██ QR CODE ██     │   │
    │   │   │ ticket_number       │   │
    │   │   └─────────────────────┘   │
    │   │                             │
    │   │        B 1234 PGO           │
    │   │     (font besar, 28px)      │
    │   │                             │
    │   │   Scan QR saat keluar       │
    │   │   📅 13 Juni 2026 07:30    │
    │   │   👤 Jukir: Budi            │
    │   └─────────────────────────────┘
    │
    ├─ [📤 Bagikan Struk Digital] — via WhatsApp (opsional) (US-013)
    │
    └─ Selesai → Kembali ke Home
```

**QR Code di Karcis:** berisi `ticket_number` (format: `{KODEZONA}-{YYMMDD}-{0001}`) → untuk scan pas kendaraan keluar.

---

## 4. DAFTAR PARKIR AKTIF

```
[DAFTAR PARKIR AKTIF]
    │
    ├─ List semua kendaraan dgn status ACTIVE
    │   └─ Tiap card:
    │       ┌─────────────────────────────────┐
    │       │ 🚗 B 1234 PGO      ⏱ 32 menit  │
    │       │ Motor · Masuk 07:30             │
    │       │ Estimasi: Rp 3.000              │
    │       │ Status: ✅ LUNAS / ⏳ BELUM     │
    │       │              [⏹ KELUARKAN]      │
    │       └─────────────────────────────────┘
    │
    ├─ Timer real-time (update per detik)
    ├─ Pull-to-refresh
    ├─ Search by plat nomor
    └─ Tap card → detail kendaraan
```

---

## 5. KENDARAAN KELUAR + PEMBAYARAN

```
[KENDARAAN KELUAR]
    │
    ├─ ═══════ CARI KENDARAAN ═══════
    │
    ├─ 🔵 SCAN QR KARCIS (PRIMARY):
    │   ├─ Buka kamera → scan QR di karcis
    │   ├─ GET /api/v1/parking-sessions/by-ticket/{ticket_number}
    │   └─ Auto-fill data kendaraan + durasi
    │
    ├─ 🟠 KARCIS HILANG?:
    │   ├─ Cari dari daftar parkir aktif
    │   └─ Lanjut ke verifikasi 4 foto + data pemilik + denda
    │
    ├─ 🔴 TIDAK TERCATAT?:
    │   ├─ Input plat manual + foto kendaraan
    │   └─ Lanjut ke verifikasi 4 foto + data pemilik + denda
    │
    ├─ ═══════ VERIFIKASI (karcis hilang / tidak tercatat) ═══════
    │
    │   ┌──────────────────────────────────┐
    │   │ 📸 FOTO KTP                      │
    │   │ 📸 FOTO STNK                     │
    │   │ 📸 FOTO KENDARAAN (tampak depan) │
    │   │ 📸 FOTO PENGENDARA               │
    │   │                                  │
    │   │ Data Pemilik:                    │
    │   │ ├─ Nama (dari KTP)              │
    │   │ ├─ NIK (dari KTP)               │
    │   │ ├─ Alamat                        │
    │   │ └─ Plat STNK                     │
    │   │                                  │
    │   │ Catatan Jukir (opsional)         │
    │   └──────────────────────────────────┘
    │
    │   → POST /api/v1/parking-sessions/{id}/force-exit (karcis hilang)
    │   → POST /api/v1/parking-sessions/unregistered-exit (tdk tercatat)
    │   → Response: { parking_fee, penalty_fee, total_fee }
    │
    ├─ ═══════ RINCIAN denda ═══════
    │   ┌─────────────────────────────┐
    │   │ Tarif Parkir    Rp 9.000    │
    │   │ Denda Karcis    Rp 5.000    │ ← merah
    │   │ ─────────────────────────   │
    │   │ TOTAL           Rp 14.000   │ ← bold + merah
    │   └─────────────────────────────┘
    │
    ├─ ═══════ DETAIL & FOTO ═══════
    │
    ├─ Detail Kendaraan:
    │   ├─ Plat: B 1234 PGO
    │   ├─ Jenis: Motor
    │   ├─ Masuk: 07:30
    │   ├─ Durasi: 35 menit
    │   └─ Tarif: Rp 3.000
    │
    ├─ [📸 Ambil Foto Kendaraan Keluar] — WAJIB
    │
    ├─ POST /api/v1/parking-sessions/{id}/close
    │   └─ Response: final_amount, duration
    │
    ├─ ═══════ PEMBAYARAN ═══════
    │
    ├─ (Kalo payment_timing = exit / masih BELUM BAYAR)
    │   ├─ [💰 TUNAI]
    │   │   ├─ Input nominal bayar
    │   │   └─ Kembalian otomatis
    │   │
    │   └─ [📱 QRIS STATIS ZONA]
    │       ├─ Tampilkan QRIS statis zona (gambar dari backend)
    │       ├─ Pengendara scan & bayar
    │       └─ Jukir catat → status "recorded"
    │
    ├─ POST /api/v1/transactions
    │
    ├─ ═══════ STRUK ═══════
    │
    ├─ 🖨 Cetak Struk Pembayaran (Bluetooth thermal)
    ├─ [📤 Bagikan Struk Digital] — via WhatsApp
    │
    └─ Selesai
```

**Payment Status Lifecycle:**
```
TUNAI → langsung "verified" (selesai)
QRIS  → "recorded" → Supervisor/Admin verifikasi → "verified" / "rejected"
```

---

## 6. RIWAYAT TRANSAKSI

```
[RIWAYAT]
    │
    ├─ Header: Total Pendapatan Hari Ini — Rp 87.000
    ├─ Filter: Hari Ini | Minggu Ini | Bulan Ini
    │
    └─ List Transaksi:
        ┌─────────────────────────────────┐
        │ 08:05 · B 1234 PGO    Rp 3.000  │
        │ Motor · Tunai      ✅ verified   │
        ├─────────────────────────────────┤
        │ 07:45 · B 9876 GO     Rp 9.000  │
        │ Mobil · QRIS        ⏳ recorded  │
        └─────────────────────────────────┘
```

---

## 7. SETORAN AKHIR SHIFT

```
[SETORAN AKHIR SHIFT]
    │
    ├─ Ringkasan Shift:
    │   ├─ Total Transaksi: 24
    │   ├─ Tunai: Rp 45.000
    │   ├─ QRIS: Rp 42.000
    │   └─ Total: Rp 87.000
    │
    ├─ [📸 Foto Bukti Setor] — foto uang yang disetor
    │
    └─ [KIRIM SETORAN] → POST /api/v1/settlements
        └─ Status: "submitted" → nunggu approve supervisor
```

---

## 8. ABSEN PULANG

```
[ABSEN PULANG] (tombol kecil di pojok)
    │
    ├─ Selfie (opsional)
    ├─ Capture GPS otomatis
    └─ POST /api/v1/attendances (isi check_out_at, check_out_lat, check_out_lng)
        └─ Success → Status "HADIR" → "SELESAI"
```

---

## 9. SUPERVISOR — FITUR TAMBAHAN

Supervisor login → role detection → menu navigasi tambahan muncul:

```
[HOME DASHBOARD SUPERVISOR]
    │
    ├─ (sama kayak Jukir) Ringkasan pribadi + tombol Kendaraan Masuk
    │
    └─ Menu Tambahan:
        │
        ├─ 📋 MONITORING JUKIR (US-005)
        │   ├─ List jukir di zona: Nama · Status (Hadir/Tdk Hadir/Terlambat)
        │   └─ Tap → Lihat lokasi di peta mini
        │
        ├─ ✅ VERIFIKASI QRIS (US-012)
        │   ├─ List transaksi QRIS dgn status "recorded"
        │   └─ [Verifikasi] / [Tolak] → update status
        │
        ├─ 📊 VERIFIKASI SETORAN
        │   ├─ List setoran jukir dgn status "submitted"
        │   └─ [Setujui] / [Tolak]
        │
        └─ 📈 LAPORAN ZONA (US-017)
            ├─ Total pendapatan zona hari ini
            ├─ Perbandingan tunai vs non-tunai
            └─ Rincian transaksi per jukir
```

---

## 10. OFFLINE MODE

Semua operasi bisa jalan offline (PRD section 8.2 + NFR):

```
ONLINE:
    ├─ Semua request → langsung API
    └─ Data disimpan lokal sebagai cache

OFFLINE DETECTED (connectivity_plus):
    ├─ ☑ Kendaraan Masuk → simpan lokal
    │   ├─ local_id: UUID
    │   ├─ idempotency_key: hash(plate + timestamp)
    │   └─ sync_status: "pending"
    │
    ├─ ☑ Kendaraan Keluar → simpan lokal + hitung tarif offline
    │
    ├─ ☑ Pembayaran QRIS:
    │   └─ QRIS statis zona udah di-cache → bisa dipake offline
    │
    ├─ ☑ Semua transaksi → lokal dulu
    │
    └── Saat koneksi pulih:
        └─ Background sync → POST /api/v1/sync/batch
            ├─ Kirim batch items (attendance, parking_session, transaction, settlement)
            ├─ Server validasi idempotency_key → skip duplikat
            └─ Response → update sync_status → "synced"
```

---

## 11. RINGKASAN API CALLS

| Aksi | Method | Endpoint |
|---|---|---|
| Login via QR ID Card | POST | `/api/v1/login/qr` |
| Ambil data user | GET | `/api/v1/me` |
| Ambil zona + tarif | GET | `/api/v1/zones` |
| Absen masuk/pulang | POST | `/api/v1/attendances` |
| Catat kendaraan masuk | POST | `/api/v1/parking-sessions` |
| List parkir aktif | GET | `/api/v1/parking-sessions?status=active` |
| Cari kendaraan by tiket | GET | `/api/v1/parking-sessions/by-ticket/{ticket}` |
| Keluarkan kendaraan | POST | `/api/v1/parking-sessions/{id}/close` |
| Catat pembayaran | POST | `/api/v1/transactions` |
| Kirim setoran | POST | `/api/v1/settlements` |
| Force exit (karcis hilang) | POST | `/api/v1/parking-sessions/{id}/force-exit` |
| Unregistered exit | POST | `/api/v1/parking-sessions/unregistered-exit` |
| Cek denda | POST | `/api/v1/penalties/by-zone-type` |
| Sinkronisasi offline | POST | `/api/v1/sync/batch` |

---

## 12. FLOW CHART (Ringkasan Visual)

```
[SCAN QR ID CARD]
      │
      ├─ role = admin → TOLAK (pake web)
      │
      └─ role = jukir/supervisor
            │
            ▼
      [ABSEN MASUK] ← Selfie + GPS
            │
            ▼
      ┌─────────────────────────────────────┐
      │         LOOP UTAMA                   │
      │                                       │
      │  Kendaraan Datang                     │
      │    → Input plat / Scan QR kendaraan  │
      │    → Pilih jenis + foto              │
      │    → POST parking-sessions           │
      │    → 🔵 FLAT? Bayar sekarang         │
      │    → 🖨 CETAK KARCIS (TMR-250613-0001)   │
      │    → Bagikan struk (opsional)        │
      │                                       │
      │  Kendaraan Pergi                      │
      │    → 📷 SCAN QR karcis               │
      │    → Foto kendaraan keluar           │
      │    → POST close → hitung tarif       │
      │    → 🟠 PROGRESIF? Bayar sekarang    │
      │    → 🖨 Cetak struk                  │
      └─────────────────────────────────────┘
            │
            ▼
      [SETORAN AKHIR SHIFT]
            │
            ▼
      [ABSEN PULANG]
            │
            ▼
      [LOGOUT]
```
