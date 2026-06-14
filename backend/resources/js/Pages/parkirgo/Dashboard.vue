<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import { Link, router } from "@inertiajs/vue3";

const currency = new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", maximumFractionDigits: 0 });

export default {
  components: { Layout, PageHeader, Link },
  props: {
    summary: { type: Object, default: () => ({}) },
    zones: { type: Array, default: () => [] },
    recentSessions: { type: Array, default: () => [] },
    recentTransactions: { type: Array, default: () => [] },
    period: { type: String, default: "today" },
  },
  computed: {
    periodLabel() {
      const labels = { today: "Hari Ini", week: "Minggu Ini", month: "Bulan Ini", year: "Tahun Ini" };
      return labels[this.period] || "Hari Ini";
    },
  },
  methods: {
    money(value) {
      return currency.format(Number(value || 0));
    },
    statusClass(status) {
      return { active: "success", paid: "success", unpaid: "warning", recorded: "info", verified: "primary", exited: "secondary" }[status] || "dark";
    },
    totalCap(zone) {
      return (zone.vehicle_types || []).reduce((s, vt) => s + (vt.pivot?.capacity || 0), 0);
    },
    usagePct(zone) {
      const cap = this.totalCap(zone);
      if (!cap) return null;
      return Math.round((zone.active_sessions_count || 0) / cap * 100);
    },
    vtCap(zone, vtId) {
      const vt = (zone.vehicle_types || []).find(v => v.id === vtId);
      return vt ? vt.pivot.capacity : 0;
    },
    duration(value) {
      if (!value) return "-";
      const min = Math.floor(value / 60);
      const sec = value % 60;
      return min > 0 ? `${min}m ${sec}s` : `${sec}s`;
    },
    switchPeriod(p) {
      router.get("/", { period: p }, { preserveState: true });
    },
    colorBy(idx) {
      const colors = ["primary", "success", "info", "warning", "danger", "secondary"];
      return colors[idx % colors.length];
    },
  },
};
</script>

<template>
  <Layout>
    <PageHeader title="Dashboard" pageTitle="ParkirGo" />

    <BCard no-body class="border-0 shadow-sm mb-4">
      <BCardBody class="py-2">
        <div class="d-flex flex-wrap gap-1" role="group">
          <button type="button" class="btn btn-sm" :class="period === 'today' ? 'btn-primary' : 'btn-soft-primary'" @click="switchPeriod('today')">Hari Ini</button>
          <button type="button" class="btn btn-sm" :class="period === 'week' ? 'btn-primary' : 'btn-soft-primary'" @click="switchPeriod('week')">Minggu Ini</button>
          <button type="button" class="btn btn-sm" :class="period === 'month' ? 'btn-primary' : 'btn-soft-primary'" @click="switchPeriod('month')">Bulan Ini</button>
          <button type="button" class="btn btn-sm" :class="period === 'year' ? 'btn-primary' : 'btn-soft-primary'" @click="switchPeriod('year')">Tahun Ini</button>
        </div>
      </BCardBody>
    </BCard>

    <BRow class="g-3 mb-4">
      <BCol xl="3" md="6">
        <BCard no-body class="border-0 overflow-hidden parkirgo-hero-card text-white">
          <BCardBody>
            <div class="d-flex align-items-start justify-content-between">
              <div>
                <p class="text-white-75 mb-2">Pendapatan {{ periodLabel }}</p>
                <h3 class="text-white mb-1">{{ money(summary.revenue_period) }}</h3>
                <span class="badge bg-white text-success">Live Ops</span>
              </div>
              <div class="avatar-sm rounded-circle bg-white bg-opacity-25 d-flex align-items-center justify-content-center">
                <i class="ri-wallet-3-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol xl="3" md="6">
        <BCard no-body class="border-0 shadow-sm">
          <BCardBody>
            <div class="d-flex justify-content-between">
              <div>
                <p class="text-muted mb-1">Sesi Aktif</p>
                <h3 class="mb-0">{{ summary.active_sessions || 0 }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-primary-subtle text-primary d-flex align-items-center justify-content-center">
                <i class="ri-parking-box-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol xl="3" md="6">
        <BCard no-body class="border-0 shadow-sm">
          <BCardBody>
            <div class="d-flex justify-content-between">
              <div>
                <p class="text-muted mb-1">Jukir Online</p>
                <h3 class="mb-0">{{ summary.jukirs_online || 0 }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-info-subtle text-info d-flex align-items-center justify-content-center">
                <i class="ri-user-smile-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol xl="3" md="6">
        <BCard no-body class="border-0 shadow-sm">
          <BCardBody>
            <div class="d-flex justify-content-between">
              <div>
                <p class="text-muted mb-1">Zona Aktif</p>
                <h3 class="mb-0">{{ summary.zones_active || 0 }}</h3>
              </div>
              <div class="avatar-sm rounded-circle bg-success-subtle text-success d-flex align-items-center justify-content-center">
                <i class="ri-map-pin-2-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <BRow class="g-3 mb-4">
      <BCol v-for="(zone, idx) in zones" :key="zone.id" xl="4" md="6">
        <BCard no-body class="border-0 shadow-sm h-100 zone-card">
          <BCardBody>
            <div class="d-flex justify-content-between align-items-start mb-2">
              <div>
                <h5 class="mb-0">{{ zone.name }}</h5>
                <span class="badge bg-primary-subtle text-primary">{{ zone.code }}</span>
                <span v-if="zone.city" class="ms-1 text-muted small">{{ zone.city }}</span>
              </div>
              <span class="badge bg-success-subtle text-success">{{ zone.status }}</span>
            </div>

            <div class="row g-2 mb-3">
              <div class="col-6">
                <div class="p-2 rounded bg-light">
                  <small class="text-muted">Pendapatan</small>
                  <div class="fw-bold text-success">{{ money(zone.revenue_sum) }}</div>
                </div>
              </div>
              <div class="col-3">
                <div class="p-2 rounded bg-light text-center">
                  <small class="text-muted">Shift</small>
                  <div class="fw-bold">{{ zone.shifts_count || 0 }}</div>
                </div>
              </div>
              <div class="col-3">
                <div class="p-2 rounded bg-light text-center">
                  <small class="text-muted">Jukir</small>
                  <div class="fw-bold">{{ zone.jukirs_count || 0 }}</div>
                </div>
              </div>
            </div>

            <div v-for="vt in zone.vehicle_types || []" :key="vt.id" class="mb-2">
              <div class="d-flex justify-content-between small mb-1">
                <span>{{ vt.name }}</span>
                <span class="text-muted">{{ vt.pivot.capacity }} slot</span>
              </div>
              <div class="d-flex align-items-center gap-2">
                <div class="progress flex-grow-1" style="height:8px">
                  <div class="progress-bar" :class="`bg-${colorBy(idx)}`" :style="{ width: Math.min(100, (zone.active_sessions_count || 0) / (vt.pivot.capacity || 1) * 100) + '%' }"></div>
                </div>
                <small class="fw-medium">{{ zone.active_sessions_count || 0 }}/{{ vt.pivot.capacity }}</small>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <BRow>
      <BCol xl="6">
        <BCard no-body class="border-0 shadow-sm mb-3">
          <BCardHeader>
            <BCardTitle class="mb-0">Transaksi Terbaru</BCardTitle>
          </BCardHeader>
          <BCardBody>
            <div v-for="trx in recentTransactions" :key="trx.id" class="d-flex align-items-center border-bottom pb-3 mb-3">
              <div class="avatar-xs me-3 rounded-circle bg-info-subtle text-info d-flex align-items-center justify-content-center">
                <i class="ri-bank-card-line"></i>
              </div>
              <div class="flex-grow-1">
                <h6 class="mb-1">{{ trx.transaction_number }}</h6>
                <p class="text-muted mb-0">{{ trx.zone?.name }} · {{ trx.payment_method }}</p>
              </div>
              <div class="text-end">
                <div class="fw-semibold">{{ money(trx.amount) }}</div>
                <span class="badge" :class="`bg-${statusClass(trx.status)}-subtle text-${statusClass(trx.status)}`">{{ trx.status }}</span>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol xl="6">
        <BCard no-body class="border-0 shadow-sm mb-3">
          <BCardHeader>
            <BCardTitle class="mb-0">Sesi Aktif Terbaru</BCardTitle>
          </BCardHeader>
          <BCardBody>
            <div v-for="session in recentSessions" :key="session.id" class="d-flex align-items-center border-bottom pb-3 mb-3">
              <div class="avatar-xs me-3 rounded-circle bg-primary-subtle text-primary d-flex align-items-center justify-content-center">
                <i class="ri-parking-box-line"></i>
              </div>
              <div class="flex-grow-1">
                <h6 class="mb-1">{{ session.ticket_number }}</h6>
                <p class="text-muted mb-0">{{ session.zone?.name }} · {{ session.plate_number }}</p>
              </div>
              <div class="text-end">
                <div class="small">{{ duration(session.duration_minutes) }}</div>
                <span class="badge" :class="`bg-${statusClass(session.status)}-subtle text-${statusClass(session.status)}`">{{ session.status }}</span>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>
  </Layout>
</template>

<style scoped>
.parkirgo-hero-card {
  background: linear-gradient(135deg, #0f9f6e, #0ea5e9 55%, #4f46e5);
  box-shadow: 0 18px 45px rgba(14, 165, 233, 0.22);
}
.text-white-75 { color: rgba(255,255,255,.75); }
.zone-card { transition: transform .2s ease, box-shadow .2s ease; }
.zone-card:hover { transform: translateY(-4px); box-shadow: 0 18px 45px rgba(15, 23, 42, .12) !important; }
.avatar-xs { width: 32px; height: 32px; object-fit: cover; }
</style>
