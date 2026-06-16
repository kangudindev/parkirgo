<script>
import Layout from "@/Layouts/main.vue";
import PageHeader from "@/Components/page-header.vue";
import { Link, router } from "@inertiajs/vue3";
import { VueEcharts } from "vue3-echarts";
import VueApexCharts from "vue3-apexcharts";

const currency = new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", maximumFractionDigits: 0 });

export default {
  components: { Layout, PageHeader, Link, VueEcharts, apexchart: VueApexCharts },
  props: {
    summary: { type: Object, default: () => ({}) },
    zones: { type: Array, default: () => [] },
    chartData: { type: Object, default: () => ({ labels: [], series: [] }) },
    recentSessions: { type: Array, default: () => [] },
    recentTransactions: { type: Array, default: () => [] },
    period: { type: String, default: "today" },
  },
  computed: {
    periodLabel() {
      return { today: "Hari Ini", week: "Minggu Ini", month: "Bulan Ini", year: "Tahun Ini" }[this.period] || "Hari Ini";
    },
    apexChartOptions() {
      return {
        chart: { height: 380, type: "line", zoom: { enabled: false }, toolbar: { show: false } },
        dataLabels: { 
          enabled: true, 
          style: { fontSize: '10px' },
          formatter: (v) => v ? v.toLocaleString("id-ID") : v
        },
        stroke: { width: 3, curve: "smooth" },
        markers: { size: 5 },
        xaxis: { categories: this.chartData.labels, title: { text: "Waktu" } },
        yaxis: { title: { text: "Pendapatan (Rp)" }, labels: { formatter: (v) => this.moneyShort(v) } },
        legend: { position: "top", horizontalAlign: "center" },
        tooltip: { y: { formatter: (v) => this.money(v) } }
      };
    }
  },
  methods: {
    money(v) { return currency.format(Number(v || 0)); },
    moneyShort(v) {
      if (v >= 1000000) return (v / 1000000).toFixed(1) + ' jt';
      if (v >= 1000) return (v / 1000).toFixed(0) + ' rb';
      return v;
    },
    statusClass(s) {
      return { active: "success", paid: "success", unpaid: "warning", recorded: "info", verified: "primary", exited: "secondary", completed: "primary" }[s] || "dark";
    },
    duration(v) {
      if (!v && v !== 0) return "-";
      const m = Math.floor(v / 60);
      const s = v % 60;
      return m > 0 ? `${m}j ${s}m` : `${m}m`;
    },
    formatDateShort(v) {
      if (!v) return "-";
      return new Intl.DateTimeFormat("id-ID", { 
        day: "2-digit", month: "2-digit", year: "numeric",
        hour: "2-digit", minute: "2-digit"
      }).format(new Date(v));
    },

    gaugeOption(active, capacity) {
      const pct = capacity ? (active / capacity) * 100 : 0;
      const color = pct > 90 ? "#f06548" : pct > 70 ? "#f7b84b" : "#0ab39c";
      return {
        series: [{
          type: "gauge",
          center: ["50%", "60%"],
          radius: "100%",
          startAngle: 200,
          endAngle: -20,
          min: 0,
          max: capacity || 100,
          progress: { show: true, width: 6, itemStyle: { color } },
          pointer: { show: true, length: '60%', width: 3, itemStyle: { color } },
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
        <BCard no-body class="border-0 overflow-hidden parkirgo-hero-card text-white h-100">
          <BCardBody>
            <div class="d-flex align-items-start justify-content-between">
              <div>
                <p class="text-white-75 mb-2">Pendapatan {{ periodLabel }}</p>
                <h3 class="text-white mb-1 fw-bold">{{ money(summary.revenue_period) }}</h3>
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
        <BCard no-body class="border-0 overflow-hidden parkirgo-hero-card text-white h-100">
          <BCardBody>
            <div class="d-flex align-items-start justify-content-between">
              <div>
                <p class="text-white-75 mb-2">Sesi Aktif</p>
                <h3 class="text-white mb-1 fw-bold">{{ summary.active_sessions || 0 }}</h3>
                <span class="badge bg-white text-primary">Monitoring</span>
              </div>
              <div class="avatar-sm rounded-circle bg-white bg-opacity-25 d-flex align-items-center justify-content-center">
                <i class="ri-parking-box-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol xl="3" md="6">
        <BCard no-body class="border-0 overflow-hidden parkirgo-hero-card text-white h-100">
          <BCardBody>
            <div class="d-flex align-items-start justify-content-between">
              <div>
                <p class="text-white-75 mb-2">Jukir Online</p>
                <h3 class="text-white mb-1 fw-bold">{{ summary.jukirs_online || 0 }}</h3>
                <span class="badge bg-white text-info">Petugas</span>
              </div>
              <div class="avatar-sm rounded-circle bg-white bg-opacity-25 d-flex align-items-center justify-content-center">
                <i class="ri-user-smile-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
      <BCol xl="3" md="6">
        <BCard no-body class="border-0 overflow-hidden parkirgo-hero-card text-white h-100">
          <BCardBody>
            <div class="d-flex align-items-start justify-content-between">
              <div>
                <p class="text-white-75 mb-2">Zona Aktif</p>
                <h3 class="text-white mb-1 fw-bold">{{ summary.zones_active || 0 }}</h3>
                <span class="badge bg-white text-success">Operasional</span>
              </div>
              <div class="avatar-sm rounded-circle bg-white bg-opacity-25 d-flex align-items-center justify-content-center">
                <i class="ri-map-pin-2-line fs-22"></i>
              </div>
            </div>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <BRow class="mb-4">
      <BCol lg="12">
        <BCard no-body class="border-0 shadow-sm">
          <BCardHeader>
            <BCardTitle class="mb-0">Tren Pendapatan per Zona ({{ periodLabel }})</BCardTitle>
          </BCardHeader>
          <BCardBody>
            <apexchart
              class="apex-charts"
              height="380"
              dir="ltr"
              :series="chartData.series"
              :options="apexChartOptions"
            ></apexchart>
          </BCardBody>
        </BCard>
      </BCol>
    </BRow>

    <BRow class="g-3 mb-4">
      <BCol v-for="zone in zones" :key="zone.id" xl="4" md="6">
        <BCard no-body class="border-0 shadow-sm h-100 zone-card">
          <BCardBody>
            <div class="d-flex justify-content-between align-items-start mb-3">
              <div>
                <h5 class="mb-0 fw-bold">{{ zone.name }}</h5>
                <span class="badge bg-primary-subtle text-primary">{{ zone.code }}</span>
                <span v-if="zone.city" class="ms-1 text-muted small">{{ zone.city }}</span>
              </div>
              <span class="badge bg-success-subtle text-success">{{ zone.status }}</span>
            </div>

            <div class="table-responsive mb-2">
              <table class="table table-sm table-borderless align-middle mb-0 text-center">
                <thead>
                  <tr class="text-muted small border-bottom">
                    <th class="pb-1">PENDAPATAN</th>
                    <th class="pb-1">KENDARAAN</th>
                    <th class="pb-1">JUKIR</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td class="pt-2">
                      <h4 class="fw-bold text-success mb-0">{{ money(zone.revenue_sum) }}</h4>
                    </td>
                    <td class="pt-2">
                      <h4 class="fw-semibold mb-0">{{ zone.parkir_out_count || 0 }}</h4>
                      <div class="d-flex gap-2 mt-1 justify-content-center flex-wrap">
                        <span v-for="vt in zone.vehicle_types" :key="vt.id" class="small text-muted d-inline-flex align-items-center gap-1">
                          <i :class="vt.icon || 'ri-car-line'" class="fs-13"></i>
                          <span>{{ vt.paid_count || 0 }}</span>
                        </span>
                      </div>
                    </td>
                    <td class="pt-2">
                      <h4 class="fw-semibold mb-0">{{ zone.jukirs_count || 0 }}</h4>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div class="d-flex align-items-center my-2">
              <hr class="flex-grow-1 m-0">
              <span class="px-2 text-muted" style="font-size: 10px; font-weight: 600; text-transform: uppercase;">Kendaraan Aktif</span>
              <hr class="flex-grow-1 m-0">
            </div>

            <div class="d-flex flex-wrap" style="gap:4px">
              <div v-for="vt in zone.vehicle_types" :key="vt.id" class="text-center px-1 mb-1" style="width: 19%; min-width: 75px; flex-grow: 1;">
                <div class="d-flex justify-content-center" style="height:60px">
                  <VueEcharts :option="gaugeOption(vt.active_count, vt.capacity)" style="width:75px;height:60px" />
                </div>
                <div class="small fw-semibold mt-n2 mb-1" style="font-size: 12px;">{{ vt.active_count || 0 }}<span class="text-muted fw-normal">/{{ vt.capacity }}</span></div>
                <i :class="vt.icon || 'ri-car-line'" class="fs-18 d-block mb-1 text-primary" :title="vt.name"></i>
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
                  <p class="text-muted mb-0 small">{{ formatDateShort(trx.created_at) }} · {{ trx.zone?.name }} · {{ trx.payment_method }}</p>
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
                  <p class="text-muted mb-0 small">{{ formatDateShort(session.entry_at) }} · {{ session.zone?.name }} · {{ session.plate_number }}</p>
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
.zone-card { transition: transform .2s ease, box-shadow .2s ease; border-radius: 12px; }
.zone-card:hover { transform: translateY(-4px); box-shadow: 0 18px 45px rgba(15, 23, 42, .12) !important; }
.avatar-xs { width: 32px; height: 32px; object-fit: cover; }
</style>
