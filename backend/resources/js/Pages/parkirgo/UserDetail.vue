<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import MemberIdCard from "@/Components/MemberIdCard.vue";
import { Link } from "@inertiajs/vue3";
import { ref } from "vue";

export default {
  components: { Layout, PageHeader, MemberIdCard, Link },
  setup() {
    const memberCardRef = ref(null);
    return { memberCardRef };
  },
  props: {
    user: { type: Object, required: true },
    shifts: { type: Array, default: () => [] },
    attendance: { type: Array, default: () => [] },
    parkingHistory: { type: Array, default: () => [] },
  },
  data() {
    return {
      showCardModal: false,
      cardSub: null,
    };
  },
  methods: {
    formatRp(v) {
      return "Rp " + Number(v).toLocaleString("id-ID");
    },
    formatDate(d) {
      if (!d) return "-";
      return new Intl.DateTimeFormat("id-ID", { dateStyle: "medium" }).format(new Date(d));
    },
    formatDateTime(dt) {
      if (!dt) return "-";
      return new Intl.DateTimeFormat("id-ID", { dateStyle: "medium", timeStyle: "short" }).format(new Date(dt));
    },
    roleLabel(role) {
      const labels = { admin: "Admin ParkirGo", supervisor: "Supervisor", jukir: "Juru Parkir", customer: "Member Langganan" };
      return labels[role] || role || "-";
    },
    statusBadgeClass(s) {
      return s === "active" ? "bg-success-subtle text-success" : "bg-danger-subtle text-danger";
    },
    statusLabel(s) {
      return s === "active" ? "Aktif" : "Nonaktif";
    },
    showMemberCard(sub) {
      // Attach the user info to the subscription object for the card template
      const formattedSub = {
        ...sub,
        user: this.user
      };
      this.cardSub = formattedSub;
      this.showCardModal = true;
    },
    downloadMemberCard() {
      if (this.memberCardRef) {
        this.memberCardRef.downloadCard();
      }
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader :title="`Detail ${roleLabel(user.role)}`" pageTitle="Manajemen User" />

    <!-- Profil Singkat Pengguna -->
    <BCard no-body class="border-0 shadow-sm mb-4">
      <BCardBody class="p-4">
        <div class="row align-items-center">
          <div class="col-md-auto text-center mb-3 mb-md-0">
            <img :src="user.profile_photo_url" :alt="user.name" class="rounded-circle avatar-xl img-thumbnail" style="width: 110px; height: 110px; object-fit: cover;" />
          </div>
          <div class="col-md ms-md-3 text-center text-md-start">
            <div class="d-flex flex-wrap align-items-center justify-content-center justify-content-md-start gap-2">
              <h3 class="mb-0 fw-bold">{{ user.name }}</h3>
              <span :class="`badge ${statusBadgeClass(user.status)} px-2.5 py-1`">{{ statusLabel(user.status) }}</span>
            </div>
            <p class="text-muted fs-14 mb-3 text-capitalize">{{ roleLabel(user.role) }}</p>
            
            <div class="row g-3">
              <div class="col-sm-6 col-md-3">
                <div class="text-muted mb-0.5 fs-12">EMAIL</div>
                <div class="fw-semibold text-dark">{{ user.email }}</div>
              </div>
              <div class="col-sm-6 col-md-3" v-if="user.phone">
                <div class="text-muted mb-0.5 fs-12">TELEPON/WA</div>
                <div class="fw-semibold text-dark">{{ user.phone }}</div>
              </div>
              <div class="col-sm-6 col-md-3" v-if="user.nik">
                <div class="text-muted mb-0.5 fs-12">NIK (NOMOR INDUK KARYAWAN)</div>
                <div class="fw-semibold text-dark">{{ user.nik }}</div>
              </div>
              <div class="col-sm-6 col-md-3">
                <div class="text-muted mb-0.5 fs-12">TERDAFTAR SEJAK</div>
                <div class="fw-semibold text-dark">{{ formatDate(user.created_at) }}</div>
              </div>
            </div>
          </div>
          <div class="col-md-auto text-center mt-3 mt-md-0">
            <Link href="/parkirgo/users" class="btn btn-outline-secondary btn-sm">
              <i class="ri-arrow-left-line me-1 align-bottom"></i> Kembali ke List
            </Link>
          </div>
        </div>
      </BCardBody>
    </BCard>

    <!-- KONDISI 1: JURU PARKIR (JUKIR) -->
    <div v-if="user.role === 'jukir'">
      <BRow class="g-4 mb-4">
        <!-- Statistik Jukir -->
        <BCol md="4">
          <BCard no-body class="border-0 shadow-sm card-animate h-100">
            <BCardBody class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1 fs-12 text-uppercase fw-semibold">Zona Tugas Utama</p>
                <h4 class="mb-0 fw-bold text-primary">{{ user.assigned_zone?.name || 'BELUM DITUGASKAN' }}</h4>
                <small class="text-muted mt-1 d-block" v-if="user.assigned_zone">Code: {{ user.assigned_zone.code }}</small>
              </div>
              <div class="avatar-md bg-primary-subtle text-primary rounded-circle d-flex align-items-center justify-content-center">
                <i class="ri-map-pin-2-line fs-28"></i>
              </div>
            </BCardBody>
          </BCard>
        </BCol>
        
        <BCol md="4">
          <BCard no-body class="border-0 shadow-sm card-animate h-100">
            <BCardBody class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1 fs-12 text-uppercase fw-semibold">Jumlah Shift Terbuku</p>
                <h3 class="mb-0 fw-bold">{{ shifts.length }} Sesi</h3>
                <small class="text-muted mt-1 d-block">Histori penugasan lapangan</small>
              </div>
              <div class="avatar-md bg-info-subtle text-info rounded-circle d-flex align-items-center justify-content-center">
                <i class="ri-time-line fs-28"></i>
              </div>
            </BCardBody>
          </BCard>
        </BCol>
        
        <BCol md="4">
          <BCard no-body class="border-0 shadow-sm card-animate h-100">
            <BCardBody class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1 fs-12 text-uppercase fw-semibold">Gelar QR Card</p>
                <span v-if="user.qr_auth_token" class="badge bg-success-subtle text-success fs-12 px-2 py-1"><i class="ri-checkbox-circle-line me-1"></i>QR Aktif</span>
                <span v-else class="badge bg-warning-subtle text-warning fs-12 px-2 py-1"><i class="ri-error-warning-line me-1"></i>Belum Dibuat</span>
                <small class="text-muted mt-1.5 d-block text-truncate" style="max-width: 170px;">Token: {{ user.qr_auth_token || '-' }}</small>
              </div>
              <div class="avatar-md bg-warning-subtle text-warning rounded-circle d-flex align-items-center justify-content-center">
                <i class="ri-qr-code-line fs-28"></i>
              </div>
            </BCardBody>
          </BCard>
        </BCol>
      </BRow>

      <BRow>
        <!-- Histori Shift Kerja -->
        <BCol lg="7">
          <BCard no-body class="border-0 shadow-sm mb-4">
            <BCardHeader class="bg-transparent">
              <h5 class="card-title mb-0"><i class="ri-calendar-todo-line text-primary me-2 align-middle fs-18"></i>Histori Shift Kerja Jukir</h5>
            </BCardHeader>
            <BCardBody class="p-0">
              <div class="table-responsive">
                <table class="table table-hover align-middle table-nowrap mb-0">
                  <thead class="table-light">
                    <tr>
                      <th>Tanggal Shift</th>
                      <th>Zona Tugas</th>
                      <th>Waktu Kerja</th>
                      <th>Penerimaan Jukir</th>
                      <th>Status Setoran</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="s in shifts" :key="s.id">
                      <td class="fw-semibold">{{ formatDate(s.shift_date) }}</td>
                      <td>{{ s.zone?.name || '-' }}</td>
                      <td>{{ s.start_time.substring(0,5) }} - {{ s.end_time ? s.end_time.substring(0,5) : 'Bertugas' }}</td>
                      <td>
                        <div class="fs-12 text-success fw-bold" v-if="s.settlement">
                          {{ formatRp(Number(s.settlement.cash_amount) + Number(s.settlement.qris_amount)) }}
                        </div>
                        <span v-else class="text-muted fs-11">Belum Setor</span>
                      </td>
                      <td>
                        <span v-if="s.status === 'active'" class="badge bg-success">Bertugas</span>
                        <span v-else-if="s.settlement?.status === 'approved'" class="badge bg-success-subtle text-success">Lunas & Disetujui</span>
                        <span v-else class="badge bg-warning-subtle text-warning">Selesai (Menunggu Setoran)</span>
                      </td>
                    </tr>
                    <tr v-if="shifts.length === 0">
                      <td colspan="5" class="text-center py-4 text-muted fst-italic">Belum ada riwayat shift untuk juru parkir ini.</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </BCardBody>
          </BCard>
        </BCol>

        <!-- Histori Absensi Geotagging -->
        <BCol lg="5">
          <BCard no-body class="border-0 shadow-sm mb-4">
            <BCardHeader class="bg-transparent">
              <h5 class="card-title mb-0"><i class="ri-user-follow-line text-primary me-2 align-middle fs-18"></i>Histori Absensi Terkini</h5>
            </BCardHeader>
            <BCardBody class="p-0">
              <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                  <thead class="table-light">
                    <tr>
                      <th>Check In</th>
                      <th>Check Out</th>
                      <th>Zona Lokasi</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="a in attendance" :key="a.id">
                      <td>
                        <span class="fw-medium fs-12">{{ formatDateTime(a.check_in_at) }}</span>
                      </td>
                      <td>
                        <span class="fs-12 text-danger" v-if="a.check_out_at">{{ formatDateTime(a.check_out_at) }}</span>
                        <span class="badge bg-success-subtle text-success" v-else>Active</span>
                      </td>
                      <td class="fs-12">{{ a.zone?.name || '-' }}</td>
                    </tr>
                    <tr v-if="attendance.length === 0">
                      <td colspan="3" class="text-center py-4 text-muted fst-italic">Belum ada riwayat absensi.</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </BCardBody>
          </BCard>
        </BCol>
      </BRow>
    </div>

    <!-- KONDISI 2: MEMBER BERLANGGANAN (CUSTOMER) -->
    <div v-if="user.role === 'customer'">
      <BRow class="g-4 mb-4">
        <!-- Statistik Member -->
        <BCol md="4">
          <BCard no-body class="border-0 shadow-sm card-animate h-100">
            <BCardBody class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1 fs-12 text-uppercase fw-semibold">Saldo Dompet Prabayar</p>
                <h3 class="mb-0 fw-bold text-success">{{ user.wallet ? formatRp(user.wallet.balance) : 'Rp 0' }}</h3>
                <small class="text-muted mt-1 d-block">Terpotong otomatis saat check-out</small>
              </div>
              <div class="avatar-md bg-success-subtle text-success rounded-circle d-flex align-items-center justify-content-center">
                <i class="ri-wallet-3-line fs-28"></i>
              </div>
            </BCardBody>
          </BCard>
        </BCol>

        <BCol md="4">
          <BCard no-body class="border-0 shadow-sm card-animate h-100">
            <BCardBody class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1 fs-12 text-uppercase fw-semibold">Paket Langganan Aktif</p>
                <h3 class="mb-0 fw-bold text-info">
                  {{ (user.user_subscriptions || []).filter(s => s.status === 'active').length }} Paket
                </h3>
                <small class="text-muted mt-1 d-block">Unlimited Pass & Kuota aktif</small>
              </div>
              <div class="avatar-md bg-info-subtle text-info rounded-circle d-flex align-items-center justify-content-center">
                <i class="ri-vip-crown-line fs-28"></i>
              </div>
            </BCardBody>
          </BCard>
        </BCol>

        <BCol md="4">
          <BCard no-body class="border-0 shadow-sm card-animate h-100">
            <BCardBody class="d-flex align-items-center justify-content-between">
              <div>
                <p class="text-muted mb-1 fs-12 text-uppercase fw-semibold">Kendaraan Terdaftar</p>
                <h3 class="mb-0 fw-bold text-warning">
                  {{ (user.user_subscriptions || []).reduce((acc, sub) => acc + (sub.vehicles || []).length, 0) }} Plat
                </h3>
                <small class="text-muted mt-1 d-block">Total plat nomor aktif terintegrasi</small>
              </div>
              <div class="avatar-md bg-warning-subtle text-warning rounded-circle d-flex align-items-center justify-content-center">
                <i class="ri-car-fill fs-28"></i>
              </div>
            </BCardBody>
          </BCard>
        </BCol>
      </BRow>

      <!-- Detail Layanan & Histori Langganan Member -->
      <BCard no-body class="border-0 shadow-sm mb-4">
        <BCardHeader class="bg-transparent border-bottom">
          <h5 class="card-title mb-0"><i class="ri-vip-diamond-line text-primary me-2 align-middle fs-18"></i>Detail Paket Berlangganan Member</h5>
        </BCardHeader>
        <BCardBody class="p-0">
          <div class="table-responsive">
            <table class="table align-middle table-nowrap mb-0">
              <thead class="table-light">
                <tr>
                  <th>Nama Paket</th>
                  <th>Jenis Manfaat</th>
                  <th>Kendaraan (Plat)</th>
                  <th>Masa Berlaku</th>
                  <th>Status Paket</th>
                  <th class="text-center">Aksi Kartu</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="sub in user.user_subscriptions" :key="sub.id">
                  <td>
                    <span class="fw-bold text-dark fs-14">{{ sub.package?.name || 'Paket Langganan' }}</span><br>
                    <small class="text-muted">ID: SUB-{{ sub.id }}</small>
                  </td>
                  <td>
                    <span v-if="sub.type === 'quota'" class="fw-semibold text-info">{{ sub.value_remaining }} Sesi Tersisa</span>
                    <span v-else class="text-muted">Unlimited Pass</span>
                  </td>
                  <td>
                    <div class="d-flex flex-wrap gap-1.5">
                      <span v-for="v in sub.vehicles" :key="v.id" class="badge bg-light text-dark border px-2 py-1">
                        <span class="fw-bold">{{ v.license_plate }}</span>
                        <span v-if="v.label" class="text-muted ms-1 fs-10">({{ v.label }})</span>
                      </span>
                    </div>
                  </td>
                  <td>
                    <small class="d-block">Mulai: {{ formatDate(sub.start_date) }}</small>
                    <small class="d-block text-danger">Akhir: {{ formatDate(sub.end_date) }}</small>
                  </td>
                  <td>
                    <span class="badge bg-success-subtle text-success fs-11 px-2 py-1" v-if="sub.status === 'active'">Aktif</span>
                    <span class="badge bg-warning-subtle text-warning fs-11 px-2 py-1" v-else-if="sub.status === 'used_up'">Kuota Habis</span>
                    <span class="badge bg-danger-subtle text-danger fs-11 px-2 py-1" v-else>Habis Masa Aktif</span>
                  </td>
                  <td class="text-center">
                    <button class="btn btn-primary btn-sm px-3" @click="showMemberCard(sub)" title="Cetak ID Card Member">
                      <i class="ri-printer-line me-1 align-middle"></i> Cetak Kartu Member
                    </button>
                  </td>
                </tr>
                <tr v-if="!user.user_subscriptions || user.user_subscriptions.length === 0">
                  <td colspan="6" class="text-center py-5 text-muted">
                    <i class="ri-vip-crown-2-line fs-32 d-block mb-2 text-secondary"></i>
                    Pelanggan ini belum pernah terdaftar paket langganan apapun.
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </BCardBody>
      </BCard>

      <!-- Histori Aktivitas Sesi Parkir Kendaraan Member -->
      <BCard no-body class="border-0 shadow-sm mb-4">
        <BCardHeader class="bg-transparent border-bottom">
          <h5 class="card-title mb-0"><i class="ri-parking-box-line text-primary me-2 align-middle fs-18"></i>Histori Parkir Kendaraan Member (10 Sesi Terakhir)</h5>
        </BCardHeader>
        <BCardBody class="p-0">
          <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th>No. Tiket</th>
                  <th>Plat Nomor</th>
                  <th>Jenis Kendaraan</th>
                  <th>Zona Parkir</th>
                  <th>Waktu Sesi</th>
                  <th>Jumlah Bayar</th>
                  <th>Metode / Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="ph in parkingHistory" :key="ph.id">
                  <td class="fw-bold">{{ ph.ticket_number }}</td>
                  <td><span class="badge bg-light text-dark fw-bold border px-2 py-1 fs-12">{{ ph.plate_number }}</span></td>
                  <td class="text-capitalize">{{ ph.vehicle_type }}</td>
                  <td>{{ ph.zone?.name || '-' }}</td>
                  <td>
                    <small class="d-block">Masuk: {{ formatDateTime(ph.entry_at) }}</small>
                    <small class="d-block text-danger" v-if="ph.exit_at">Keluar: {{ formatDateTime(ph.exit_at) }}</small>
                    <small class="d-block text-success fw-semibold" v-else>Masih Parkir</small>
                  </td>
                  <td>
                    <span class="fw-bold text-dark">{{ ph.final_amount !== null ? formatRp(ph.final_amount) : formatRp(ph.estimated_amount) }}</span>
                  </td>
                  <td>
                    <span class="badge bg-success-subtle text-success py-1 px-2.5 fs-11" v-if="ph.payment_status === 'paid'">
                      <i class="ri-checkbox-circle-line me-1 align-middle"></i> Lunas
                    </span>
                    <span class="badge bg-warning-subtle text-warning py-1 px-2.5 fs-11" v-else>
                      <i class="ri-error-warning-line me-1 align-middle"></i> Belum Bayar
                    </span>
                    <small class="d-block text-muted text-uppercase fs-10 mt-1" v-if="ph.transactions && ph.transactions.length">
                      {{ ph.transactions[0].payment_method }}
                    </small>
                  </td>
                </tr>
                <tr v-if="parkingHistory.length === 0">
                  <td colspan="7" class="text-center py-5 text-muted">
                    <i class="ri-history-line fs-32 d-block mb-2 text-secondary"></i>
                    Belum ada riwayat aktivitas parkir untuk plat nomor milik member ini.
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </BCardBody>
      </BCard>
    </div>

    <!-- Modal Preview Kartu Member VIP -->
    <BModal v-model="showCardModal" title="Preview Kartu VIP Member" hide-footer centered size="xl">
      <div v-if="cardSub" class="text-center py-3">
        <div class="d-flex justify-content-center mb-4">
          <MemberIdCard ref="memberCardRef" :subscription="cardSub" />
        </div>
        <div class="d-flex justify-content-center gap-3">
          <BButton variant="light" @click="showCardModal=false">Tutup</BButton>
          <BButton variant="primary" @click="downloadMemberCard">
            <i class="ri-download-2-line me-1"></i>Download Kartu VIP (PNG)
          </BButton>
        </div>
        <p class="text-muted small mt-3">Kartu VIP Member ini dapat dicetak langsung atau disimpan sebagai kartu elektronik.</p>
      </div>
    </BModal>
  </Layout>
</template>

<style scoped>
.card-animate {
  transition: transform 0.25s ease, box-shadow 0.25s ease;
}
.card-animate:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 20px rgba(0,0,0,0.1) !important;
}
</style>
