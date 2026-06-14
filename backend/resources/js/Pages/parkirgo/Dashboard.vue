<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import { Link, router } from "@inertiajs/vue3";
import { VueEcharts } from "vue3-echarts";

const currency = new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", maximumFractionDigits: 0 });

export default {
  components: { Layout, PageHeader, Link, VueEcharts },
  props: {
    summary: { type: Object, default: () => ({}) },
    zones: { type: Array, default: () => [] },
    recentSessions: { type: Array, default: () => [] },
    recentTransactions: { type: Array, default: () => [] },
    period: { type: String, default: "today" },
  },
  computed: {
    periodLabel() {
      return { today: "Hari Ini", week: "Minggu Ini", month: "Bulan Ini", year: "Tahun Ini" }[this.period] || "Hari Ini";
    },
  },
  methods: {
    money(v) { return currency.format(Number(v || 0)); },
    statusClass(s) {
      return { active: "success", paid: "success", unpaid: "warning", recorded: "info", verified: "primary", exited: "secondary" }[s] || "dark";
    },
    duration(v) {
      if (!v) return "-";
      const m = Math.floor(v / 60);
      const s = v % 60;
      return m > 0 ? `${m}m ${s}s` : `${s}s`;
    },
    gaugeOption(active, capacity) {
      const pct = capacity ? (active / capacity) * 100 : 0;
      const color = pct > 90 ? "#f06548" : pct > 70 ? "#f7b84b" : "#0ab39c";
      return {
        series: [{
          type: "gauge",
          center: ["50%", "55%"],
          radius: "100%",
          startAngle: 200,
          endAngle: -20,
          min: 0,
          max: capacity || 100,
          progress: { show: true, width: 6, itemStyle: { color: color } },
          pointer: { show: true, length: '60%', width: 3, itemStyle: { color: color } },
          axisLine: { lineStyle: { width: 6, color: [[1, "#e9ebec"]] } },
          axisTick: { show: false },
          splitLine: { show: false },
          axisLabel: { show: false },
          detail: { show: false },
          data: [{ value: active || 0 }]
        }]
      };
    },
    switchPeriod(p) {
      router.get("/", { period: p }, { preserveState: true });
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
      <BCol v-for="zone in zones" :key="zone.id" xl="4" md="6">
        <BCard no-body class="border-0 shadow-sm h-100 zone-card">
          <BCardBody>
            <div class="d-flex justify-content-between align-items-start mb-2">
              <div>
                <h5 class="mb-0">{{ zone.name }}</h5>
                <span class="badge bg-primary-subtle text-primary">{{ zone.code }}</span>
                <span v-if="zone.city" class="ms-1 text-muted small">{{ zone.city }}</span>
              </div>
              <div class="text-end">
                <span class="badge bg-success-subtle text-success d-block mb-1">{{ zone.status }}</span>
                <small class="text-muted"><i class="ri-user-smile-line me-1"></i>Jukir: {{ zone.jukirs_count || 0 }}</small>
              </div>
            </div>

            <div class="mb-3 border-bottom pb-3">
              <div class="text-muted small mb-1">Pendapatan</div>
              <h3 class="fw-bold text-success mb-1">{{ money(zone.revenue_sum) }}</h3>
              <div class="text-danger small">
                <i class="ri-error-warning-line me-1"></i>Denda: {{ money(zone.penalty_sum) }}
              </div>
            </div>

            <div class="d-flex" style="gap:1px;overflow-x:auto">
              <div v-for="vt in zone.vehicle_types" :key="vt.id" class="text-center flex-fill px-1">
                <i :class="vt.icon || 'ri-car-line'" class="fs-22 d-block mb-1"></i>
                <span class="small fw-medium d-block">{{ vt.name }}</span>
                <div class="d-flex justify-content-center" style="height:55px">
                  <VueEcharts :option="gaugeOption(vt.active_count, vt.pivot.capacity)" style="width:60px;height:55px" />
                </div>
                <div class="small fw-semibold mt-1">{{ vt.active_count || 0 }}<span class="text-muted fw-normal">/{{ vt.pivot.capacity }}</span></div>
                <div class="small" :class="(vt.pivot.capacity - vt.active_count) > 0 ? 'text-success' : 'text-danger'">
                  {{ (vt.pivot.capacity - vt.active_count) || 0 }} sisa
                </div>
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
            <template v-if="recentTransactions.length">
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
            </template>
            <div v-if="!recentTransactions.length" class="text-center text-muted py-3">Belum ada transaksi.</div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol xl="6">
        <BCard no-body class="border-0 shadow-sm mb-3">
          <BCardHeader>
            <BCardTitle class="mb-0">Sesi Aktif Terbaru</BCardTitle>
          </BCardHeader>
          <BCardBody>
            <template v-if="recentSessions.length">
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
            </template>
            <div v-if="!recentSessions.length" class="text-center text-muted py-3">Belum ada sesi.</div>
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
